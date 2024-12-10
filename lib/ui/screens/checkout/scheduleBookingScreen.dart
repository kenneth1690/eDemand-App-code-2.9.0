import 'package:e_demand/app/generalImports.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: prefer_typing_uninitialized_variables
import 'package:intl/intl.dart' as intl;

class ScheduleBookingScreen extends StatefulWidget {
  const ScheduleBookingScreen({
    required this.companyName,
    required this.providerAdvanceBookingDays,
    required this.providerName,
    required this.providerId,
    final Key? key,
    required this.isFrom,
    this.orderID,
  }) : super(key: key);

  //
  final String providerName;
  final String isFrom;
  final String providerId;
  final String companyName;
  final String providerAdvanceBookingDays;
  final String? orderID;

  @override
  State<ScheduleBookingScreen> createState() => _ScheduleBookingScreenState();

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => Builder(
        builder: (final context) => MultiBlocProvider(
          providers: [
            BlocProvider<PlaceOrderCubit>(
              create: (final BuildContext context) =>
                  PlaceOrderCubit(cartRepository: CartRepository()),
            ),
            BlocProvider(
              create: (context) => AddTransactionCubit(bookingRepository: BookingRepository()),
            ),
            BlocProvider<ValidateCustomTimeCubit>(
              create: (context) => ValidateCustomTimeCubit(cartRepository: CartRepository()),
            ),
            BlocProvider<CheckProviderAvailabilityCubit>(
              create: (final BuildContext context) =>
                  CheckProviderAvailabilityCubit(providerRepository: ProviderRepository()),
            )
          ],
          child: ScheduleBookingScreen(
            orderID: arguments["orderID"],
            companyName: arguments["companyName"],
            isFrom: arguments["isFrom"],
            providerName: arguments['providerName'],
            providerId: arguments['providerId'],
            providerAdvanceBookingDays: arguments['providerAdvanceBookingDays'],
          ),
        ),
      ),
    );
  }
}

class _ScheduleBookingScreenState extends State<ScheduleBookingScreen> {
  //
  PaymentGatewaysSettings? paymentGatewaySetting;
  String? placedOrderId;

  int? selectedAddressIndex;
  GetAddressModel? selectedAddress;
  dynamic selectedDate, selectedTime;
  String? message;
  Promocode? appliedPromocode;
  double promoCodeDiscount = 0;
  late List<Map<String, dynamic>> enabledPaymentMethods = context
      .read<SystemSettingCubit>()
      .getEnabledPaymentMethods(
          isPayLaterAllowed: context.read<CartCubit>().isPayLaterAllowed(isFrom: widget.isFrom));

  //
  ValueNotifier<String> paymentButtonName = ValueNotifier("");

  String? selectedPaymentMethod;
  final TextEditingController _instructionController = TextEditingController();

  late final List<Map<String, String>> deliverableOptions = [
    {"title": 'atHome', "description": 'atHomeDescription', "image": AppAssets.home},
    {"title": 'atStore', "description": 'atStoreDescription', "image": AppAssets.store},
  ];
  late String selectedDeliverableOption = deliverableOptions[0]['title']!;

  //----------------------------------- Razorpay Payment Gateway Start ----------------------------
  final Razorpay _razorpay = Razorpay();

  void initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorPayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorPayExternalWallet);
  }

  void _handleRazorPayPaymentSuccess(final PaymentSuccessResponse response) {
    _navigateToOrderConfirmation(isSuccess: true);
  }

  void _handleRazorPayPaymentError(final PaymentFailureResponse response) {
    _navigateToOrderConfirmation(isSuccess: false);
  }

  void _handleRazorPayExternalWallet(final ExternalWalletResponse response) {}

  Future<void> openRazorPayGateway({
    required final double orderAmount,
    required final String placedOrderId,
    required final String razorpayOrderId,
  }) async {
    final options = <String, Object?>{
      'key': paymentGatewaySetting!.razorpayKey,
      //this should be come from server
      'amount': (orderAmount * 100).toInt(),
      'name': appName,
      'description': '',
      'currency': paymentGatewaySetting!.razorpayCurrency,
      'notes': {'order_id': placedOrderId},
      'order_id': razorpayOrderId,
    };

    _razorpay.open(options);
  }

  //----------------------------------- Razorpay Payment Gateway End ----------------------------

  //----------------------------------- Stripe Payment Gateway Start ----------------------------

  Future<void> openStripePaymentGateway({
    required final double orderAmount,
    required final String placedOrderId,
  }) async {
    try {
      StripeService.secret = paymentGatewaySetting!.stripeSecretKey;
      StripeService.init(
        paymentGatewaySetting!.stripePublishableKey,
        paymentGatewaySetting!.stripeMode,
      );

      final response = await StripeService.payWithPaymentSheet(
        amount: (orderAmount * 100).ceil(),
        currency: paymentGatewaySetting!.stripeCurrency,
        isTestEnvironment: paymentGatewaySetting!.stripeMode == "test",
        awaitedOrderId: placedOrderId,
        from: 'order',
      );

      if (response.status == 'succeeded') {
        _navigateToOrderConfirmation(isSuccess: true);
      } else {
        _navigateToOrderConfirmation(isSuccess: false);
      }
    } catch (_) {}
  }

  //----------------------------------- Stripe Payment Gateway End ----------------------------

  void _navigateToOrderConfirmation({required final bool isSuccess}) {
    if (!isSuccess) {
      paymentButtonName.value = "rePayment";
      UiUtils.showMessage(
          context, "bookingFailureMessage".translate(context: context), MessageType.error);
      //
      context
          .read<AddTransactionCubit>()
          .addTransaction(status: "cancelled", orderID: placedOrderId ?? "0");
      //
      context.read<BookingCubit>().fetchBookingDetails(status: "");
      return;
    }

    Navigator.pushNamed(
      context,
      orderConfirmation,
      arguments: {'isSuccess': isSuccess, "orderId": placedOrderId},
    );
  }

  void getPaymentGatewaySetting() {
    paymentGatewaySetting = context.read<SystemSettingCubit>().getPaymentMethodSettings();

    if (context.read<CartCubit>().isOnlinePaymentAllowed(isFrom: widget.isFrom)) {
      paymentButtonName = ValueNotifier("makePayment");
    } else {
      paymentButtonName = ValueNotifier("bookService");
    }
  }

  @override
  void initState() {
    super.initState();

    getPaymentGatewaySetting();
    initializeRazorpay();

    context.read<GetAddressCubit>().fetchAddress();

    selectedDeliverableOption =
        context.read<CartCubit>().checkAtDoorstepProviderAvailable(isFrom: widget.isFrom)
            ? deliverableOptions[0]['title']!
            : deliverableOptions[1]['title']!;

    if (context.read<CartCubit>().isOnlinePaymentAllowed(isFrom: widget.isFrom)) {
      selectedPaymentMethod = enabledPaymentMethods[0]['paymentType'];
    } else {
      selectedPaymentMethod = "cod";
    }
  }

  Widget getServiceDeliverableOptions() {
    return Column(
      children: List.generate(
        deliverableOptions.length,
        (index) => CustomRadioOptionsWidget(
            onChanged: (final Object? selectedValue) {
              selectedDeliverableOption = selectedValue.toString();
              setState(() {});
            },
            groupValue: selectedDeliverableOption,
            isFirst: index == 0,
            isLast: index == deliverableOptions.length - 1,
            value: deliverableOptions[index]["title"]!,
            image: deliverableOptions[index]["image"]!,
            title: deliverableOptions[index]["title"]!,
            subTitle: deliverableOptions[index]["description"]!),
      ),
    );
  }

  Widget getHeadingTimeSelector() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomText(
          'scheduleTime'.translate(context: context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.colorScheme.blackColor,
        ),
      );

  Widget verticalSpacing() {
    return const CustomSizedBox(
      height: 10,
    );
  }

  Widget buildProviderInstructionField() => TextFormField(
        controller: _instructionController,
        style: const TextStyle(fontSize: 12),
        minLines: 4,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colorScheme.secondaryColor,
          hintText: 'writeDescriptionForProvider'.translate(context: context),
          hintStyle: const TextStyle(fontSize: 12.6),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.colorScheme.secondaryColor, width: 2),
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.colorScheme.secondaryColor),
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
          ),
        ),
      );

  Widget buildAddressSelector() => BlocListener<AddAddressCubit, AddAddressState>(
        listener: (final BuildContext context, final AddAddressState addAddressState) {
          if (addAddressState is AddAddressSuccess) {
            final getAddressModel = GetAddressModel.fromJson(addAddressState.result["data"][0]);
            context.read<AddressesCubit>().addAddress(getAddressModel);
          }
        },
        child: BlocListener<DeleteAddressCubit, DeleteAddressState>(
          listener: (final BuildContext context, final DeleteAddressState state) {
            if (state is DeleteAddressSuccess) {
              for (int i = 0; i < state.data.length; i++) {
                if (state.data[i].isDefault == "1") {
                  selectedAddressIndex = i;
                  selectedAddress = state.data[i];
                  setState(() {});
                }
              }

              context.read<AddressesCubit>().load(state.data);
              context.read<AddressesCubit>().removeAddress(state.id);
            }
          },
          child: BlocConsumer<GetAddressCubit, GetAddressState>(
            listener: (final BuildContext context, final GetAddressState getAddressState) {
              if (getAddressState is GetAddressSuccess) {
                for (var i = 0; i < getAddressState.data.length; i++) {
                  //we will make default address as selected address
                  //so we will take index of selected address and address data
                  if (getAddressState.data[i].isDefault == "1") {
                    selectedAddressIndex = i;
                    selectedAddress = getAddressState.data[i];
                    setState(() {});
                  }
                }
                context.read<AddressesCubit>().load(getAddressState.data);
              }
            },
            builder: (final BuildContext context, final GetAddressState getAddressState) {
              if (getAddressState is GetAddressSuccess) {
                //inserting because there are Plus Button in ListView at 0 index
                //
                // if (getAddressState.data.isNotEmpty) {
                //   if (getAddressState.data[0].id != null) {
                //     getAddressState.data.insert(0, GetAddressModel.fromJson({}));
                //   }
                // }

                return BlocConsumer<AddressesCubit, AddressesState>(
                  listener: (context, state) {
                    if (state is Addresses) {
                      for (var i = 0; i < state.addresses.length; i++) {
                        //we will make default address as selected address
                        //so we will take index of selected address and address data
                        if (state.addresses[i].isDefault == "1") {
                          selectedAddressIndex = i;
                          selectedAddress = state.addresses[i];
                          setState(() {});
                        }
                      }
                    }
                  },
                  builder: (final context, AddressesState addressesState) {
                    if (addressesState is Addresses) {
                      return getAddressState.data.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: GeneralCardContainer(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    googleMapRoute,
                                    arguments: {
                                      "defaultLatitude": HiveRepository.getLatitude,
                                      "defaultLongitude": HiveRepository.getLongitude,
                                      'showAddressForm': true
                                    },
                                  ).then((final Object? value) {
                                    context.read<GetAddressCubit>().fetchAddress();
                                  });
                                },
                                imageName: AppAssets.address,
                                title: "addNewAddress",
                                description: "easilyAddNewAddress",
                              ))
                          : CustomSizedBox(
                              height: 155,
                              width: context.screenWidth,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
                                child: Row(
                                  children: <Widget>[
                                        CustomInkWellContainer(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              googleMapRoute,
                                              arguments: {
                                                "defaultLatitude": HiveRepository.getLatitude,
                                                "defaultLongitude": HiveRepository.getLongitude,
                                                'showAddressForm': true
                                              },
                                            ).then((Object? value) {
                                              context.read<GetAddressCubit>().fetchAddress();
                                            });
                                          },
                                          child: CustomContainer(
                                            color: context.colorScheme.secondaryColor,
                                            borderRadius: UiUtils.borderRadiusOf10,
                                            child: Center(
                                              child: Icon(
                                                Icons.add,
                                                color: context.colorScheme.accentColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ] +
                                      List.generate(
                                        addressesState.addresses.length,
                                        (index) {
                                          late GetAddressModel addressData;
                                          if (getAddressState.data.isNotEmpty) {
                                            addressData = addressesState.addresses[index];
                                          }
                                          return AddressSelector(
                                            mobileNumber: '${addressData.mobile}',
                                            address: addressData.address.toString(),
                                            addressAreaAndCity:
                                                '${addressData.area} ,${addressData.cityName}',
                                            addressPincodeAndCountry:
                                                '${addressData.pincode} , ${addressData.country}',
                                            addressType: addressData.type.toString(),
                                            isAddressSelected: (selectedAddressIndex == null &&
                                                    addressesState.addresses[index].isDefault ==
                                                        '1') ||
                                                selectedAddressIndex == index,
                                            onTap: () {
                                              selectedAddressIndex = index;
                                              selectedAddress = addressesState.addresses[index];
                                              setState(() {});
                                            },
                                            onDeleteButtonSelected: () {
                                              UiUtils.showAnimatedDialog(
                                                  context: context,
                                                  child: DeleteAddressDialog(
                                                    onConfirmButtonPressed: () {
                                                      if (selectedAddress?.id == addressData.id) {
                                                        selectedAddress = null;
                                                        selectedAddressIndex = null;
                                                        setState(() {});
                                                      }
                                                      try {
                                                        context
                                                            .read<DeleteAddressCubit>()
                                                            .deleteAddress(
                                                                addressData.id as String);
                                                        Navigator.pop(context);
                                                      } catch (_) {}
                                                    },
                                                  ));
                                            },
                                            onEditButtonSelected: () {
                                              Navigator.pushNamed(
                                                context,
                                                googleMapRoute,
                                                arguments: {
                                                  "defaultLatitude": addressData.lattitude,
                                                  "defaultLongitude": addressData.longitude,
                                                  'details': addressData,
                                                  'showAddressForm': true
                                                },
                                              ).then((final Object? value) {
                                                if (value == true) {
                                                  context.read<GetAddressCubit>().fetchAddress();
                                                }
                                              });
                                            },
                                          );
                                        },
                                      ),
                                ),
                              ));
                    }

                    return const CustomSizedBox();
                  },
                );
              }
              if (getAddressState is GetAddressInProgress) {
                return CustomSizedBox(
                  height: 140,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: CustomShimmerLoadingContainer(
                          height: 140,
                          width: 24,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: CustomShimmerLoadingContainer(
                          height: 140,
                          width: 250,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: CustomShimmerLoadingContainer(
                          height: 140,
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const CustomSizedBox();
            },
          ),
        ),
      );

  Widget buildDateSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralCardContainer(
            onTap: () {
              setState(() {});
              UiUtils.removeFocus();
              UiUtils.showBottomSheet(
                enableDrag: true,
                context: context,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<ValidateCustomTimeCubit>(
                      create: (context) =>
                          ValidateCustomTimeCubit(cartRepository: CartRepository()),
                    ),
                    BlocProvider(
                      create: (final BuildContext context) => TimeSlotCubit(CartRepository()),
                    ),
                  ],
                  child: CalenderBottomSheet(
                    orderId: widget.orderID,
                    advanceBookingDays: widget.providerAdvanceBookingDays,
                    providerId: widget.providerId,
                    selectedDate: selectedDate == null ? null : DateTime.parse(selectedDate),
                    selectedTime: selectedTime,
                  ),
                ),
              ).then((final value) {
                if (value != null) {
                  if (value["isSaved"]) {
                    selectedDate = intl.DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse("${value['selectedDate']}"));
                    selectedTime = value["selectedTime"];
                    message = value["message"];
                    setState(() {});
                  }
                }
              });
            },
            imageName: AppAssets.icCalendar,
            title: selectedDate != null && selectedTime != null
                ? '${selectedDate.toString().formatDate()}, ${selectedTime.toString().formatTime()}'
                : "selectDate".translate(context: context),
            description: selectedDate != null && selectedTime != null
                ? message != null && message != ''
                    ? 'orderWillBeScheduledForTheMultipleDays'.translate(context: context)
                    : ""
                : "scheduleOnYourPreferDateAndTime",
            showEditIcon: selectedDate != null && selectedTime != null,
          ),
        ],
      );

  BoxDecoration selectedItemBorderStyle() => BoxDecoration(
        boxShadow: [BoxShadow(color: context.colorScheme.lightGreyColor, blurRadius: 3)],
        border: Border.all(color: context.colorScheme.blackColor),
        color: context.colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      );

  BoxDecoration normalBoxDecoration() => BoxDecoration(
        color: context.colorScheme.secondaryColor,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      );

  void placeOrder() {
    //
    context.read<PlaceOrderCubit>().placeOrder(
          status: "awaiting",
          orderId: widget.orderID ?? "",
          selectedAddressID: selectedAddress?.id,
          promoCodeId: appliedPromocode?.id ??'',
          paymentMethod: selectedPaymentMethod!,
          orderNote: _instructionController.text.trim().toString(),
          dateOfService: selectedDate!,
          startingTime: selectedTime!,
          isAtStoreOptionSelected: selectedDeliverableOption == "atStore" ? "1" : "0",
        );
  }

  Widget continueButtonContainer(final BuildContext context) =>
      BlocConsumer<PlaceOrderCubit, PlaceOrderState>(
        listener: (final BuildContext context, PlaceOrderState placeOrderState) {
          if (placeOrderState is PlaceOrderSuccess) {
            if (!placeOrderState.isError) {
              //
              placedOrderId = placeOrderState.orderId;
              //
              //we will get cart total amount form cart cubit
              //and promocode is applied then we will subtract that amount for online pay
              final double cartTotalAmount = double.parse(context
                      .read<CartCubit>()
                      .getCartTotalAmount(
                          isFrom: widget.isFrom,
                          isAtStoreBooked: selectedDeliverableOption == "atStore")) -
                  promoCodeDiscount;
              //
              if (selectedPaymentMethod == "cod") {
                _navigateToOrderConfirmation(isSuccess: true);
              } else {
                if (selectedPaymentMethod == 'stripe') {
                  //
                  openStripePaymentGateway(
                    orderAmount: cartTotalAmount,
                    placedOrderId: placeOrderState.orderId,
                  );
                  //
                } else if (selectedPaymentMethod == 'razorpay') {
                  //
                  openRazorPayGateway(
                    orderAmount: cartTotalAmount,
                    placedOrderId: placeOrderState.orderId,
                    razorpayOrderId: placeOrderState.razorpayOrderId,
                  );
                  //
                } else if (selectedPaymentMethod == 'paystack') {
                  //
                  _openWebviewPaymentGateway(webviewLink: placeOrderState.paystackLink);
                } else if (selectedPaymentMethod == 'flutterwave') {
                  //
                  _openWebviewPaymentGateway(webviewLink: placeOrderState.flutterwaveLink);
                } else if (selectedPaymentMethod == 'paypal') {
                  //
                  _openWebviewPaymentGateway(webviewLink: placeOrderState.paypalLink);
                } else {
                  UiUtils.showMessage(
                    context,
                    "onlinePaymentNotAvailableNow".translate(context: context),
                    MessageType.warning,
                  );
                }
              }
            } else {
              UiUtils.showMessage(
                  context, placeOrderState.message.translate(context: context), MessageType.error);
            }
          }
          if (placeOrderState is PlaceOrderFailure) {
            UiUtils.showMessage(context, placeOrderState.errorMessage.translate(context: context),
                MessageType.error);
          }
        },
        builder: (context, state) {
          Widget? child;
          if (state is PlaceOrderInProgress) {
            child = const Center(
              child: CustomCircularProgressIndicator(color: AppColors.whiteColors),
            );
          } else if (state is PlaceOrderFailure || state is PlaceOrderSuccess) {
            child = null;
          }
          return BlocConsumer<CheckProviderAvailabilityCubit, CheckProviderAvailabilityState>(
            listener:
                (final context, CheckProviderAvailabilityState checkProviderAvailabilityState) {
              if (checkProviderAvailabilityState is CheckProviderAvailabilityFetchSuccess) {
                if (checkProviderAvailabilityState.error) {
                  //
                  UiUtils.showMessage(
                    context,
                    'serviceNotAvailableAtSelectedAddress'.translate(context: context),
                    MessageType.warning,
                  );
                } else {
                  //
                  context.read<ValidateCustomTimeCubit>().validateCustomTime(
                      providerId: widget.providerId,
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      orderId: widget.orderID);
                }
              } else if (checkProviderAvailabilityState is CheckProviderAvailabilityFetchFailure) {
                UiUtils.showMessage(
                  context,
                  checkProviderAvailabilityState.errorMessage.translate(context: context),
                  MessageType.error,
                );
              }
            },
            builder:
                (final context, CheckProviderAvailabilityState checkProviderAvailabilityState) {
              if (checkProviderAvailabilityState is CheckProviderAvailabilityFetchInProgress) {
                child = const CustomCircularProgressIndicator(
                  color: AppColors.whiteColors,
                );
              } else if (checkProviderAvailabilityState is CheckProviderAvailabilityFetchFailure ||
                  checkProviderAvailabilityState is CheckProviderAvailabilityFetchSuccess) {
                child = null;
              }
              return BlocConsumer<ValidateCustomTimeCubit, ValidateCustomTimeState>(
                listener: (
                  final BuildContext context,
                  final ValidateCustomTimeState validateCustomTimeState,
                ) {
                  if (validateCustomTimeState is ValidateCustomTimeSuccess) {
                    if (!validateCustomTimeState.error) {
                      placeOrder();
                    } else {
                      UiUtils.showMessage(
                          context,
                          validateCustomTimeState.message.translate(context: context),
                          MessageType.error);
                    }
                  } else if (validateCustomTimeState is ValidateCustomTimeFailure) {
                    UiUtils.showMessage(
                      context,
                      validateCustomTimeState.errorMessage.translate(context: context),
                      MessageType.error,
                    );
                  }
                },
                builder: (
                  final BuildContext context,
                  final ValidateCustomTimeState validateCustomTimeState,
                ) {
                  if (validateCustomTimeState is ValidateCustomTimeInProgress) {
                    child = const CustomCircularProgressIndicator(color: AppColors.whiteColors);
                  } else if (validateCustomTimeState is ValidateCustomTimeFailure ||
                      validateCustomTimeState is ValidateCustomTimeSuccess) {
                    child = null;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: ValueListenableBuilder(
                      valueListenable: paymentButtonName,
                      builder: (context, value, _) {
                        return CustomRoundedButton(
                          onTap: () {
                            if (validateCustomTimeState is ValidateCustomTimeInProgress ||
                                checkProviderAvailabilityState
                                    is CheckProviderAvailabilityFetchInProgress) {
                              return;
                            }
                            //
                            if (selectedTime == null || selectedDate == null) {
                              UiUtils.showMessage(
                                context,
                                'pleaseSelectDateAndTime'.translate(context: context),
                                MessageType.warning,
                              );
                              return;
                            }
                            //
                            if (context
                                    .read<CartCubit>()
                                    .checkAtDoorstepProviderAvailable(isFrom: widget.isFrom) &&
                                selectedDeliverableOption == deliverableOptions[0]["title"]) {
                              if (selectedAddress == null) {
                                UiUtils.showMessage(
                                  context,
                                  'pleaseSelectAddress'.translate(context: context),
                                  MessageType.warning,
                                );
                              } else {
                                context
                                    .read<CheckProviderAvailabilityCubit>()
                                    .checkProviderAvailability(
                                      orderId: widget.orderID,
                                      isAuthTokenRequired: true,
                                      checkingAtCheckOut: '1',
                                      latitude: selectedAddress!.lattitude.toString(),
                                      longitude: selectedAddress!.longitude.toString(),
                                    );
                              }
                            } else {
                              placeOrder();
                            }
                          },
                          widthPercentage: 1,
                          backgroundColor: context.colorScheme.accentColor,
                          buttonTitle: selectedPaymentMethod == "cod"
                              ? 'bookService'.translate(context: context)
                              : paymentButtonName.value.translate(context: context),
                          showBorder: false,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      );

  Widget getTitle({required String title}) {
    return CustomText(
      title.translate(context: context),
      fontSize: 16,
      color: context.colorScheme.blackColor,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.colorScheme.primaryColor,
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: widget.companyName,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(bottom: UiUtils.bottomNavigationBarHeight + 20, top: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (context
                                .read<CartCubit>()
                                .checkAtStoreProviderAvailable(isFrom: widget.isFrom) &&
                            context
                                .read<CartCubit>()
                                .checkAtDoorstepProviderAvailable(isFrom: widget.isFrom)) ...[
                          getTitle(title: "chooseStoreOrDoorstepOption"),
                          verticalSpacing(),
                          getServiceDeliverableOptions(),
                          verticalSpacing(),
                        ],
                        getTitle(title: "scheduleDateAndTime"),
                        verticalSpacing(),
                        buildDateSelector(),
                      ],
                    ),
                  ),
                  if (selectedDeliverableOption == deliverableOptions[0]["title"] &&
                      context
                          .read<CartCubit>()
                          .checkAtDoorstepProviderAvailable(isFrom: widget.isFrom)) ...[
                    verticalSpacing(),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
                      child: getTitle(title: "serviceAddress"),
                    ),
                    verticalSpacing(),
                    buildAddressSelector(),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpacing(),
                        getTitle(title: "writeInstructionsForProvider"),
                        verticalSpacing(),
                        buildProviderInstructionField()
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getTitle(title: "saveExtra"),
                        verticalSpacing(),
                        GeneralCardContainer(
                          onTap: () {
                            if (widget.providerId == "0") {
                              UiUtils.showMessage(
                                context,
                                'somethingWentWrong'.translate(context: context),
                                MessageType.warning,
                              );
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              promocodeScreen,
                              arguments: {
                                "isFrom": widget.isFrom,
                                "providerID": widget.providerId,
                                "isAtStoreOptionSelected":
                                    selectedDeliverableOption == "atStore" ? "1" : "0"
                              },
                            ).then((final Object? value) {
                              if (value != null) {
                                final parameter = value as Map;
                                promoCodeDiscount = double.parse(parameter["discount"]);
                                appliedPromocode = parameter["appliedPromocode"];

                                setState(() {});
                              }
                            });
                          },
                          imageName: AppAssets.discount,
                          title: "applyCoupon",
                          description: appliedPromocode != null
                              ? "${appliedPromocode!.promoCode} ${"applied".translate(context: context)}"
                              : "applyCouponAndGetExtraDiscount".translate(context: context),
                          extraWidgetWithDescription: appliedPromocode != null
                              ? CustomInkWellContainer(
                                  onTap: () {
                                    promoCodeDiscount = 0.0;
                                    appliedPromocode = null;
                                    setState(() {});
                                  },
                                  child: CustomText(
                                    "remove",
                                    fontSize: 12,
                                    color: context.colorScheme.lightGreyColor,
                                    fontStyle: FontStyle.italic,
                                    showUnderline: true,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(),
                  if (context.read<CartCubit>().isPayLaterAllowed(isFrom: widget.isFrom) &&
                          context.read<CartCubit>().isOnlinePaymentAllowed(isFrom: widget.isFrom) ||
                      (context.read<CartCubit>().isOnlinePaymentAllowed(isFrom: widget.isFrom) &&
                          context
                              .read<SystemSettingCubit>()
                              .isMoreThanOnePaymentGatewayEnabled())) ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getTitle(title: "paymentOptions"),
                          verticalSpacing(),
                          ...[
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: enabledPaymentMethods.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> paymentMethod =
                                    enabledPaymentMethods[index];

                                return CustomRadioOptionsWidget(
                                  isFirst: index == 0,
                                  isLast: index == enabledPaymentMethods.length - 1,
                                  image: paymentMethod["image"]!,
                                  title: paymentMethod["title"]!,
                                  subTitle: (selectedDeliverableOption == "atStore"
                                      ? paymentMethod["optionDescription"]!
                                      : paymentMethod["description"]!),
                                  value: paymentMethod["paymentType"]!,
                                  groupValue: selectedPaymentMethod!,
                                  applyAccentColor: false,
                                  onChanged: (final Object? selectedValue) {
                                    selectedPaymentMethod = selectedValue.toString();
                                    if (selectedValue.toString() == "cod") {
                                      paymentButtonName.value = "bookService";
                                    } else {
                                      paymentButtonName.value = "makePayment";
                                    }
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    )
                  ],
                  verticalSpacing(),
                  BlocBuilder<CartCubit, CartState>(
                    builder: (final BuildContext context, final CartState state) {
                      if (state is CartFetchSuccess) {
                        if (state.cartData.cartDetails == null &&
                            state.reOrderCartData?.cartDetails == null) {
                          return const CustomSizedBox();
                        }
                        return CustomContainer(
                          color: context.colorScheme.secondaryColor,
                          borderRadius: UiUtils.borderRadiusOf10,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.isFrom == "cart"
                                    ? state.cartData.cartDetails?.length
                                    : state.reOrderCartData?.cartDetails?.length,
                                itemBuilder: (final context, index) {
                                  final cartDetails = widget.isFrom == "cart"
                                      ? state.cartData.cartDetails![index]
                                      : state.reOrderCartData?.cartDetails![index];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                                        child: ChargesTile(
                                          title1: ' ${cartDetails?.serviceDetails!.title}',
                                          title2:
                                              "${'qty'.translate(context: context)}:${cartDetails!.qty}",
                                          title3:
                                              (cartDetails.serviceDetails!.discountedPrice != '0'
                                                      ? cartDetails.serviceDetails!.priceWithTax
                                                          .toString()
                                                      : cartDetails.serviceDetails!.priceWithTax
                                                          .toString())
                                                  .priceFormat(),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const CustomDivider()
                                    ],
                                  );
                                },
                              ),
                              ChargesTile(
                                title1: 'subTotal'.translate(context: context),
                                title2: '',
                                title3: (widget.isFrom == "cart"
                                        ? state.cartData.subTotal ?? "0"
                                        : state.reOrderCartData?.subTotal ?? "0")
                                    .priceFormat(),
                                fontSize: 14,
                              ),
                              if (promoCodeDiscount != 0.0) ...[
                                const CustomSizedBox(
                                  height: 5,
                                ),
                                ChargesTile(
                                  title1: "couponDiscount".translate(context: context),
                                  title2: '',
                                  title3: '- ${promoCodeDiscount.toString().priceFormat()}',
                                  fontSize: 14,
                                ),
                              ],
                              const CustomSizedBox(
                                height: 5,
                              ),
                              if (widget.isFrom == "cart" &&
                                  state.cartData.visitingCharges != '0' &&
                                  state.cartData.visitingCharges != "" &&
                                  state.cartData.visitingCharges != 'null' &&
                                  selectedDeliverableOption != "atStore")
                                ChargesTile(
                                  title1: 'visitingCharge'.translate(context: context),
                                  title2: '',
                                  title3: '+ ${state.cartData.visitingCharges!.priceFormat()}',
                                  fontSize: 14,
                                ),
                              if (widget.isFrom == "reOrder" &&
                                  state.reOrderCartData?.visitingCharges != '0' &&
                                  state.reOrderCartData?.visitingCharges != "" &&
                                  state.reOrderCartData?.visitingCharges != 'null' &&
                                  selectedDeliverableOption != "atStore")
                                ChargesTile(
                                  title1: 'visitingCharge'.translate(context: context),
                                  title2: '',
                                  title3:
                                      '+ ${(state.reOrderCartData?.visitingCharges ?? "0").priceFormat()}',
                                  fontSize: 14,
                                ),
                              const CustomDivider(),
                              ChargesTile(
                                title1: 'totalAmount'.translate(context: context),
                                title2: '',
                                title3: (double.parse(widget.isFrom == "cart"
                                            ? state.cartData.overallAmount != "null"
                                                ? state.cartData.overallAmount ?? "0"
                                                : "0"
                                            : state.reOrderCartData?.overallAmount != "null"
                                                ? state.reOrderCartData?.overallAmount ?? "0"
                                                : '0') -
                                        promoCodeDiscount -
                                        (selectedDeliverableOption == "atStore"
                                            ? double.parse(widget.isFrom == "cart"
                                                ? state.cartData.visitingCharges ?? "0"
                                                : state.reOrderCartData?.visitingCharges ?? "0")
                                            : 0))
                                    .toStringAsFixed(2)
                                    .priceFormat(),
                                fontSize: 18,
                                isBoldText: true,
                              ),
                            ],
                          ),
                        );
                      }
                      return const CustomSizedBox();
                    },
                  ),
                ],
              ),
            ),
            BlocBuilder<DeleteAddressCubit, DeleteAddressState>(
              builder: (final BuildContext context, final DeleteAddressState state) {
                if (state is DeleteAddressInProgress) {
                  return CustomSizedBox(
                    width: context.screenWidth,
                    height: context.screenHeight,
                    child: const Center(child: CustomCircularProgressIndicator()),
                  );
                }
                return const CustomSizedBox();
              },
            ),
            Align(alignment: Alignment.bottomCenter, child: continueButtonContainer(context))
          ],
        ),
      ),
    );
  }

  void _openWebviewPaymentGateway({required String webviewLink}) {
    Navigator.pushNamed(
      context,
      webviewPaymentScreen,
      arguments: {'paymentURL': webviewLink},
    ).then((final Object? value) {
      final parameter = value as Map;
      if (parameter['paymentStatus'] == 'Completed') {
        //
        _navigateToOrderConfirmation(isSuccess: true);
        //
      } else if (parameter['paymentStatus'] == 'Failed') {
        _navigateToOrderConfirmation(isSuccess: false);
      }
    });
  }

  @override
  void dispose() {
    _instructionController.dispose();
    paymentButtonName.dispose();

    super.dispose();
  }
}
