// ignore_for_file: use_build_context_synchronously

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef PaymentGatewayDetails = ({String paymentType, String paymentImage});

// ignore: must_be_immutable
class BookingDetails extends StatelessWidget {
  //

  Booking bookingDetails;
  ValueNotifier<bool> isBillDetailsCollapsed = ValueNotifier(true);

  BookingDetails({final Key? key, required this.bookingDetails}) : super(key: key);

  static Route route(final RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => BookingDetails(
        bookingDetails: parameters["bookingDetails"],
      ),
    );
  }

  DateTime? selectedDate;
  dynamic selectedTime;
  String? message;

  //
  Widget _buildNotesWidget({
    required final BuildContext context,
    required final String notes,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildImageAndTitleWidget(context,
                imageName: AppAssets.icNotes, title: "notesLbl".translate(context: context)),
            const SizedBox(
              height: 10,
            ),
            CustomText(
              notes,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colorScheme.lightGreyColor,
            ),
          ],
        ),
      );

  Widget _buildProviderImageTitleAndChatOptionWidget({
    required final BuildContext context,
    required final String providerName,
    required final String providerImageUrl,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeadingWidget(context, title: "provider".translate(context: context)),
            const SizedBox(
              height: 10,
            ),
            CustomInkWellContainer(
              showRippleEffect: false,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  providerRoute,
                  arguments: {"providerId": bookingDetails.partnerId ?? "0"},
                );
              },
              child: Row(
                children: [
                  CustomContainer(
                    border: Border.all(color: context.colorScheme.lightGreyColor, width: 0.5),
                    borderRadius: UiUtils.borderRadiusOf5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                      child: CustomContainer(
                        height: 44,
                        width: 44,
                        borderRadius: UiUtils.borderRadiusOf5,
                        child: CustomCachedNetworkImage(
                            height: 44,
                            width: 44,
                            networkImageUrl: providerImageUrl,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const CustomSizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: CustomText(
                      providerName,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: context.colorScheme.blackColor,
                      maxLines: 2,
                    ),
                  ),
                  if (bookingDetails.isPostBookingChatAllowed == "1") ...[
                    CustomContainer(
                      height: 44,
                      padding: const EdgeInsetsDirectional.all(12),
                      color: bookingDetails.status == "completed" ||
                              bookingDetails.status == "cancelled"
                          ? context.colorScheme.lightGreyColor.withOpacity(0.1)
                          : context.colorScheme.accentColor.withOpacity(0.1),
                      borderRadius: UiUtils.borderRadiusOf10,
                      child: CustomToolTip(
                        toolTipMessage: "chat".translate(context: context),
                        child: CustomInkWellContainer(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.pushNamed(context, chatMessages, arguments: {
                              "chatUser": ChatUser(
                                id: bookingDetails.partnerId ?? "-",
                                bookingId: bookingDetails.id.toString(),
                                bookingStatus: bookingDetails.status.toString(),
                                name: bookingDetails.companyName.toString(),
                                receiverType: "1",
                                // 1 = provider
                                unReadChats: 0,
                                profile: bookingDetails.profileImage,
                                senderId:
                                    context.read<UserDetailsCubit>().getUserDetails().id ?? "0",
                              ),
                            });
                          },
                          child: CustomSvgPicture(
                            svgImage: AppAssets.drChat,
                            color: bookingDetails.status == "completed" ||
                                    bookingDetails.status == "cancelled"
                                ? context.colorScheme.lightGreyColor
                                : context.colorScheme.accentColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
          ],
        ),
      );

//
  Widget _buildServiceListContainer({
    required final String bookingStatus,
    required final List<BookedService> servicesList,
    required final BuildContext context,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeadingWidget(context, title: "services"),
            const SizedBox(
              height: 10,
            ),
            ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (final BuildContext context, final int index) => Column(
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        LinearDivider(),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                itemCount: servicesList.length,
                shrinkWrap: true,
                itemBuilder: (final BuildContext context, final int index) {
                  final BookedService service = servicesList[index];
                  //
                  bool collapsed = true;
                  return StatefulBuilder(builder: (context, innerSetState) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            CustomContainer(
                              borderRadius: UiUtils.borderRadiusOf5,
                              width: 62,
                              height: 68,
                              border:
                                  Border.all(color: context.colorScheme.lightGreyColor, width: 0.5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                                child: CustomCachedNetworkImage(
                                  networkImageUrl: service.image ?? '',
                                  height: 68,
                                  width: 62,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    '${service.serviceTitle} ',
                                    fontWeight: FontWeight.w500,
                                    color: context.colorScheme.blackColor,
                                    fontSize: 16,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            service.priceWithTax!.toString().priceFormat(),
                                            color: context.colorScheme.accentColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          CustomText(
                                            "x${service.quantity}".translate(context: context),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            color: context.colorScheme.blackColor,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      _buildRatingWidget(context, service: service, index: index,
                                          onTap: () {
                                        innerSetState(() {
                                          collapsed = !collapsed;
                                        });
                                      }, isCollapsed: collapsed),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (service.rating != "0") ...[
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: CustomContainer(
                              constraints: collapsed
                                  ? const BoxConstraints(maxHeight: 0.0)
                                  : const BoxConstraints(
                                      maxHeight: double.infinity,
                                      maxWidth: double.maxFinite,
                                    ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CustomText(
                                    service.comment ?? "",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: context.colorScheme.lightGreyColor,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (service.reviewImages?.isNotEmpty ?? false)
                                    SizedBox(
                                      height: 44,
                                      child: ListView.separated(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: service.reviewImages?.length ?? 0,
                                          separatorBuilder:
                                              (final BuildContext context, final int index) =>
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                          itemBuilder: (context, index) => CustomInkWellContainer(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    imagePreview,
                                                    arguments: {
                                                      "startFrom": index,
                                                      "isReviewType": true,
                                                      "dataURL": service.reviewImages,
                                                      "reviewDetails": Reviews(
                                                        id: service.id ?? "",
                                                        rating: service.rating ?? "",
                                                        profileImage: HiveRepository
                                                                .getUserProfilePictureURL ??
                                                            "",
                                                        userName: HiveRepository.getUsername ?? "",
                                                        serviceId: service.serviceId ?? "",
                                                        comment: service.comment ?? "",
                                                        images: service.reviewImages ?? [],
                                                        ratedOn: "",
                                                      ),
                                                    },
                                                  );
                                                },
                                                child: CustomContainer(
                                                    height: 44,
                                                    width: 44,
                                                    borderRadius: UiUtils.borderRadiusOf5,
                                                    border: Border.all(
                                                        color: context.colorScheme.lightGreyColor,
                                                        width: 0.5),
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(
                                                            UiUtils.borderRadiusOf5),
                                                        child: CustomCachedNetworkImage(
                                                          networkImageUrl:
                                                              service.reviewImages?[index] ?? "",
                                                          height: 44,
                                                          width: 44,
                                                          fit: BoxFit.fill,
                                                        ))),
                                              )),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    );
                  });
                }),
          ],
        ),
      );

  //
  Widget _getPriceSectionTile({
    required final BuildContext context,
    required final String heading,
    required final String subHeading,
    required final Color textColor,
    final Color? subHeadingTextColor,
    required final double fontSize,
    final FontWeight? fontWeight,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            CustomText(heading, color: textColor, fontWeight: fontWeight, fontSize: fontSize),
            const Spacer(),
            CustomText(subHeading,
                color: subHeadingTextColor ?? textColor,
                fontWeight: fontWeight,
                fontSize: fontSize),
          ],
        ),
      );

//
  Widget _buildPriceSectionWidget({
    required final BuildContext context,
    required final String subTotal,
    required final String taxAmount,
    required final String visitingCharge,
    required final String promoCodeAmount,
    required final String promoCodeName,
    required final String totalAmount,
    required final bool isAtStoreOptionSelected,
  }) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          CustomInkWellContainer(
            onTap: () {
              isBillDetailsCollapsed.value = !isBillDetailsCollapsed.value;
            },
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    "billDetails".translate(context: context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.lightGreyColor,
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: isBillDetailsCollapsed,
                    builder: (context, bool isCollapsed, _) {
                      return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isCollapsed
                              ? Icon(Icons.arrow_drop_down_sharp,
                                  color: context.colorScheme.accentColor, size: 24)
                              : Icon(Icons.arrow_drop_up_sharp,
                                  color: context.colorScheme.accentColor, size: 24));
                    })
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: isBillDetailsCollapsed,
              builder: (context, bool isCollapsed, _) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: CustomContainer(
                    constraints: isCollapsed
                        ? const BoxConstraints(maxHeight: 0.0)
                        : const BoxConstraints(
                            maxHeight: double.infinity,
                            maxWidth: double.maxFinite,
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _getPriceSectionTile(
                          context: context,
                          fontSize: 14,
                          heading: 'subTotal'.translate(context: context),
                          subHeading: subTotal.priceFormat(),
                          textColor: context.colorScheme.blackColor,
                        ),
                        if (promoCodeName != "" && promoCodeAmount != "")
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading: "${"promoCode".translate(context: context)} ($promoCodeName)",
                            subHeading: "- ${promoCodeAmount.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                        if (taxAmount != "" && taxAmount != "0" && taxAmount != "0.00")
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading: 'tax'.translate(context: context),
                            subHeading: "+ ${taxAmount.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                        if (visitingCharge != '0' &&
                            visitingCharge != "" &&
                            visitingCharge != 'null' &&
                            !isAtStoreOptionSelected)
                          _getPriceSectionTile(
                            context: context,
                            fontSize: 14,
                            heading: 'visitingCharge'.translate(context: context),
                            subHeading: "+ ${visitingCharge.priceFormat()}",
                            textColor: context.colorScheme.blackColor,
                          ),
                      ],
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: 10,
          ),
          Divider(
            color: context.colorScheme.lightGreyColor,
            thickness: 0.5,
            height: 0.5,
          ),
          const SizedBox(
            height: 10,
          ),
          _getPriceSectionTile(
            context: context,
            fontSize: 20,
            heading: (bookingDetails.paymentMethod == "cod" ? "totalAmount" : 'paidAmount')
                .translate(context: context),
            subHeading: totalAmount.priceFormat(),
            textColor: context.colorScheme.blackColor,
            fontWeight: FontWeight.w700,
            subHeadingTextColor: context.colorScheme.accentColor,
          ),
          const SizedBox(
            height: 12,
          ),
          _buildPaymentModeWidget(context),
        ],
      ),
    );
  }

  //
  Widget _buildUploadedProofWidget({
    required final BuildContext context,
    required final String title,
    required final List<dynamic> proofData,
  }) =>
      CustomContainer(
        color: context.colorScheme.secondaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: _buildSectionHeadingWidget(context, title: title),
            ),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: ListView.separated(
                  separatorBuilder: (final BuildContext context, final int index) => const SizedBox(
                        width: 12,
                      ),
                  itemCount: proofData.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (final BuildContext context, final int index) {
                    return CustomContainer(
                      height: 100,
                      width: 100,
                      borderRadius: UiUtils.borderRadiusOf10,
                      border: Border.all(color: context.colorScheme.lightGreyColor, width: 0.5),
                      child: CustomInkWellContainer(
                        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            imagePreview,
                            arguments: {
                              "startFrom": index,
                              "isReviewType": false,
                              "dataURL": proofData,
                            },
                          ).then((Object? value) {
                            //locked in portrait mode only
                            SystemChrome.setPreferredOrientations(
                              [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
                            );
                          });
                        },
                        child: UrlTypeHelper.getType(proofData[index]) == UrlType.image
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                                child: CustomCachedNetworkImage(
                                  networkImageUrl: proofData[index],
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: 100,
                                ),
                              )
                            : UrlTypeHelper.getType(proofData[index]) == UrlType.video
                                ? Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: context.colorScheme.accentColor,
                                    ),
                                  )
                                : const CustomSizedBox(),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      );

//
  Widget getBookingDetailsData({required final BuildContext context}) {
    String scheduledTime =
        "${bookingDetails.dateOfService!.formatDate()}, ${bookingDetails.startingTime!.formatTime()}-${bookingDetails.endingTime!.formatTime()}";
    if (bookingDetails.multipleDaysBooking!.isNotEmpty) {
      String currentDate = "";
      for (int i = 0; i < bookingDetails.multipleDaysBooking!.length; i++) {
        currentDate =
            "\n${bookingDetails.multipleDaysBooking![i].multipleDayDateOfService.toString().formatDate()},${bookingDetails.multipleDaysBooking![i].multipleDayStartingTime.toString().formatTime()}-${bookingDetails.multipleDaysBooking![i].multipleEndingTime.toString().formatTime()}";
      }
      scheduledTime = scheduledTime + currentDate;
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 10 +
                (bookingDetails.status == "completed"
                    ? 0
                    : UiUtils.getScrollViewBottomPadding(context)),
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProviderImageTitleAndChatOptionWidget(
                context: context,
                providerName: bookingDetails.companyName!,
                providerImageUrl: bookingDetails.profileImage!,
              ), //
              const SizedBox(
                height: 8,
              ),
              _buildStatusAndInvoiceWidget(context,
                  status: bookingDetails.status, invoiceNumber: bookingDetails.invoiceNo),
              const SizedBox(
                height: 8,
              ),
              _buildBookingAddressDateAndOTPWidget(context),
              const SizedBox(
                height: 8,
              ),
              if (bookingDetails.remarks != "") ...[
                _buildNotesWidget(
                  context: context,
                  notes: bookingDetails.remarks!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],

              if (bookingDetails.workStartedProof!.isNotEmpty) ...[
                _buildUploadedProofWidget(
                  context: context,
                  title: "workStartedProof",
                  proofData: bookingDetails.workStartedProof!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
              if (bookingDetails.workCompletedProof!.isNotEmpty) ...[
                _buildUploadedProofWidget(
                  context: context,
                  title: "workCompletedProof",
                  proofData: bookingDetails.workCompletedProof!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
              _buildServiceListContainer(
                bookingStatus: bookingDetails.status!,
                servicesList: bookingDetails.services!,
                context: context,
              ),
              const SizedBox(
                height: 8,
              ),
              _buildPriceSectionWidget(
                  context: context,
                  totalAmount: bookingDetails.finalTotal!,
                  promoCodeAmount: bookingDetails.promoDiscount!,
                  promoCodeName: bookingDetails.promoCode!,
                  subTotal: (double.parse(bookingDetails.total!.replaceAll(",", "")) -
                          double.parse(
                            bookingDetails.taxAmount!.replaceAll(",", ""),
                          ))
                      .toString(),
                  taxAmount: bookingDetails.taxAmount!,
                  visitingCharge: bookingDetails.visitingCharges!,
                  isAtStoreOptionSelected: bookingDetails.addressId == "0"),
              if (bookingDetails.status == "completed") ...[
                const SizedBox(
                  height: 26,
                ),
                _buildReorderAndGetInvoiceButton(context),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
          child: Row(
            children: [
              if (bookingDetails.isCancelable == "1" && bookingDetails.status != "cancelled") ...[
                Expanded(
                  child: CancelAndRescheduleButton(
                    bookingId: bookingDetails.id ?? "0",
                    buttonName: "cancelBooking",
                    onButtonTap: () {
                      context.read<ChangeBookingStatusCubit>().changeBookingStatus(
                            pressedButtonName: "cancelBooking",
                            bookingStatus: 'cancelled',
                            bookingId: bookingDetails.id!,
                          );
                    },
                  ),
                ),
                if (bookingDetails.status == "awaiting" || bookingDetails.status == "confirmed")
                  const CustomSizedBox(
                    width: 10,
                  )
              ],
              if (bookingDetails.status == "awaiting" || bookingDetails.status == "confirmed")
                Expanded(
                  child: CancelAndRescheduleButton(
                    bookingId: bookingDetails.id ?? "0",
                    buttonName: "reschedule",
                    onButtonTap: () {
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
                              create: (context) => TimeSlotCubit(CartRepository()),
                            )
                          ],
                          child: CalenderBottomSheet(
                            advanceBookingDays:
                                bookingDetails.providerAdvanceBookingDays.toString(),
                            providerId: bookingDetails.partnerId.toString(),
                            selectedDate: selectedDate,
                            selectedTime: selectedTime,
                            orderId: bookingDetails.id.toString(),
                          ),
                        ),
                      ).then(
                        (value) {
                          //
                          final bool isSaved = value['isSaved'];
                          selectedDate = DateTime.parse(DateFormat("yyyy-MM-dd")
                              .format(DateTime.parse("${value['selectedDate']}")));
                          //
                          selectedTime = value['selectedTime'];
                          //
                          message = value['message'];
                          //
                          if (selectedTime != null && selectedTime != null && isSaved) {
                            context.read<ChangeBookingStatusCubit>().changeBookingStatus(
                                pressedButtonName: "reschedule",
                                bookingStatus: 'rescheduled',
                                bookingId: bookingDetails.id!,
                                selectedTime: selectedTime.toString(),
                                selectedDate: selectedDate.toString());
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'bookingInformation'.translate(context: context),
            elevation: 0.5),
        body: BlocListener<ChangeBookingStatusCubit, ChangeBookingStatusState>(
          listener: (context, state) {
            if (state is ChangeBookingStatusFailure) {
              UiUtils.showMessage(context,
                  state.errorMessage.toString().translate(context: context), MessageType.error);
            } else if (state is ChangeBookingStatusSuccess) {
              UiUtils.showMessage(context, state.message, MessageType.success);
              //
              context
                  .read<BookingCubit>()
                  .updateBookingDataLocally(latestBookingData: state.bookingData);

              bookingDetails = state.bookingData;
            }
          },
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (final BuildContext context, final BookingState state) {
              if (state is BookingFetchSuccess) {
                return getBookingDetailsData(
                  context: context,
                );
              }
              return ErrorContainer(errorMessage: 'somethingWentWrong'.translate(context: context));
            },
          ),
        ),
      );

  Widget _buildStatusAndInvoiceWidget(BuildContext context,
      {String? status, String? invoiceNumber}) {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      border: Border.symmetric(
        horizontal: BorderSide(
          color: UiUtils.getBookingStatusColor(statusVal: status!),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomText(
                  "${"status".translate(context: context)}: ",
                  maxLines: 1,
                  color: context.colorScheme.blackColor,
                  textAlign: TextAlign.start,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                CustomText(
                  status.capitalize(),
                  color: UiUtils.getBookingStatusColor(statusVal: status),
                  maxLines: 1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomText(
                  "${"invoiceNumber".translate(context: context)}: ",
                  maxLines: 1,
                  color: context.colorScheme.blackColor,
                  textAlign: TextAlign.start,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                CustomText(
                  invoiceNumber ?? "0",
                  color: context.colorScheme.accentColor,
                  maxLines: 1,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingAddressDateAndOTPWidget(
    BuildContext context,
  ) {
    String scheduledTime =
        "${bookingDetails.dateOfService!.formatDate()}, ${bookingDetails.startingTime!.formatTime()}-${bookingDetails.endingTime!.formatTime()}";
    if (bookingDetails.multipleDaysBooking!.isNotEmpty) {
      String currentDate = "";
      for (int i = 0; i < bookingDetails.multipleDaysBooking!.length; i++) {
        currentDate =
            "\n${bookingDetails.multipleDaysBooking![i].multipleDayDateOfService.toString().formatDate()},${bookingDetails.multipleDaysBooking![i].multipleDayStartingTime.toString().formatTime()}-${bookingDetails.multipleDaysBooking![i].multipleEndingTime.toString().formatTime()}";
      }
      scheduledTime = scheduledTime + currentDate;
    }
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeadingWidget(context,
                    title: "bookedAt".translate(context: context)),
              ),
              CustomInkWellContainer(
                showRippleEffect: false,
                onTap: () => _handleAddressTap(context),
                child: CustomText(
                  (bookingDetails.addressId == "0" ? "storeAddress" : "yourAddress")
                      .translate(context: context),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: context.colorScheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomInkWellContainer(
            showRippleEffect: false,
            onTap: () => _handleAddressTap(context),
            child: _buildImageAndTitleWidget(context,
                imageName: AppAssets.icLocation,
                title: bookingDetails.addressId != "0"
                    ? filterAddressString(bookingDetails.address ?? "")
                    : "${bookingDetails.providerAddress}\n${bookingDetails.providerNumber}"),
          ),
          const SizedBox(
            height: 10,
          ),
          if (bookingDetails.multipleDaysBooking!.isEmpty) ...[
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildImageAndTitleWidget(context,
                      imageName: AppAssets.icCalendar,
                      title: bookingDetails.dateOfService.toString().formatDate()),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: _buildImageAndTitleWidget(context,
                      imageName: AppAssets.icClock,
                      title: bookingDetails.startingTime.toString().formatTime()),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 3,
                  child: _buildImageAndTitleWidget(context,
                      imageName: AppAssets.icClock,
                      title: bookingDetails.endingTime.toString().formatTime()),
                ),
              ],
            ),
          ] else ...[
            ...List.generate(bookingDetails.multipleDaysBooking!.length, (final int index) {
              final String scheduleDate = bookingDetails
                  .multipleDaysBooking![index].multipleDayDateOfService
                  .toString()
                  .formatDate();
              final String scheduleStartTime = bookingDetails
                  .multipleDaysBooking![index].multipleDayStartingTime
                  .toString()
                  .formatTime();
              final String scheduleEndTime = bookingDetails.multipleDaysBooking![index].multipleEndingTime
                  .toString()
                  .formatTime();
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildImageAndTitleWidget(context,
                        imageName: AppAssets.icCalendar, title: scheduleDate),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildImageAndTitleWidget(context,
                        imageName: AppAssets.icClock, title: scheduleStartTime),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildImageAndTitleWidget(context,
                        imageName: AppAssets.icClock, title: scheduleEndTime),
                  ),
                ],
              );
            }),
          ],
          if (context.read<SystemSettingCubit>().isOTPSystemEnabled() &&
              bookingDetails.status?.toLowerCase() != "cancelled" &&
              bookingDetails.status?.toLowerCase() != "completed") ...[
            const SizedBox(
              height: 10,
            ),
            _buildOTPWidget(context, otp: bookingDetails.otp!),
          ]
        ],
      ),
    );
  }

  Widget _buildImageAndTitleWidget(BuildContext context,
      {required String imageName, required String title}) {
    return Row(
      children: [
        CustomSvgPicture(
          svgImage: imageName,
          height: 20,
          width: 20,
          color: context.colorScheme.accentColor,
        ),
        const CustomSizedBox(
          width: 10,
        ),
        Expanded(
          child: CustomText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colorScheme.blackColor,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildOTPWidget(BuildContext context, {required String otp}) {
    return Row(
      children: [
        CustomSvgPicture(
          svgImage: AppAssets.icOtp,
          height: 20,
          width: 20,
          color: context.colorScheme.accentColor,
        ),
        const CustomSizedBox(
          width: 10,
        ),
        CustomText(
          "otp".translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.colorScheme.blackColor,
          maxLines: 1,
        ),
        const CustomSizedBox(
          width: 10,
        ),
        CustomInkWellContainer(
          onTap: () async {
            await Clipboard.setData(const ClipboardData(text: "your text"));
          },
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
          child: CustomContainer(
            height: 30,
            width: 110,
            color: context.colorScheme.accentColor.withAlpha(15),
            borderRadius: UiUtils.borderRadiusOf5,
            child: Stack(children: [
              CustomSizedBox(
                height: 30,
                width: 110,
                child: DashedRect(
                  color: context.colorScheme.accentColor,
                  strokeWidth: 1,
                  gap: 5,
                ),
              ),
              Center(
                child: CustomText(
                  otp,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.accentColor,
                  maxLines: 1,
                  letterSpacing: 5,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeadingWidget(BuildContext context, {required String title}) {
    return CustomText(
      title.translate(context: context),
      maxLines: 1,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: context.colorScheme.lightGreyColor,
    );
  }

  Widget _buildRatingWidget(BuildContext context,
      {required BookedService service,
      required int index,
      required VoidCallback onTap,
      required bool isCollapsed}) {
    final int serviceRating = int.parse(
      (service.rating ?? 0).toString().isEmpty ? '0' : service.rating ?? '0',
    );
    return (bookingDetails.status == "completed" && serviceRating == 0)
        ? _buildRatingButtonWidget(context,
            service: service, index: index, title: "rate", serviceRating: serviceRating)
        : (bookingDetails.status == "completed" && serviceRating != 0)
            ? CustomInkWellContainer(
                showRippleEffect: false,
                onTap: onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgPicture(
                      svgImage: AppAssets.icStar,
                      height: 16,
                      width: 16,
                      color: context.colorScheme.accentColor,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    CustomText(
                      serviceRating.toString(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.accentColor,
                    ),
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isCollapsed
                            ? Icon(Icons.arrow_drop_down_sharp,
                                color: context.colorScheme.accentColor, size: 12)
                            : Icon(Icons.arrow_drop_up_sharp,
                                color: context.colorScheme.accentColor, size: 12)),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 12,
                      child: VerticalDivider(
                        color: context.colorScheme.lightGreyColor,
                        thickness: 0.5,
                        width: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildRatingButtonWidget(context,
                        service: service,
                        index: index,
                        title: "edit",
                        serviceRating: serviceRating),
                  ],
                ),
              )
            : const SizedBox.shrink();
  }

  Widget _buildRatingButtonWidget(BuildContext context,
      {required BookedService service,
      required int index,
      required String title,
      required int serviceRating}) {
    return CustomInkWellContainer(
      onTap: () {
        UiUtils.showBottomSheet(
          enableDrag: true,
          context: context,
          child: BlocProvider<SubmitReviewCubit>(
            create: (final BuildContext context) =>
                SubmitReviewCubit(bookingRepository: BookingRepository()),
            child: RatingBottomSheet(
              reviewComment: service.comment!,
              ratingStar: serviceRating,
              serviceID: service.serviceId!,
              serviceName: service.serviceTitle ?? "",
            ),
          ),
        ).then(
          (value) {
            if (value != null) {
              bookingDetails.services?[index] = service.copyWith(
                comment: value["comment"],
                rating: value["rating"],
                reviewImages: (value["images"]?.isNotEmpty ?? false)
                    ? (value["images"] as List).cast<String>()
                    : [],
              );
              context
                  .read<BookingCubit>()
                  .updateBookingDataLocally(latestBookingData: bookingDetails);
            }
          },
        );
      },
      child: CustomText(
        title.translate(context: context),
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: context.colorScheme.accentColor,
      ),
    );
  }

  Widget _buildReorderAndGetInvoiceButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          if (bookingDetails.isReorderAllowed == "1") ...[
            Expanded(
              child: ReOrderButton(
                bookingDetails: bookingDetails,
                isReorderFrom: "bookingDetails",
                bookingId: bookingDetails.id ?? "0",
              ),
            ),
            const CustomSizedBox(
              width: 10,
            )
          ],
          Expanded(
            child: DownloadInvoiceButton(
              bookingId: bookingDetails.id ?? "0",
              buttonScreenName: "bookingDetails",
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddressTap(BuildContext context) async {
    //bookingDetails.addressId =="0" means booking booked as At store option
    if (bookingDetails.addressId == "0") {
      try {
        await launchUrl(
          Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${bookingDetails.providerLatitude},${bookingDetails.providerLongitude}',
          ),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        UiUtils.showMessage(
          context,
          'somethingWentWrong'.translate(context: context),
          MessageType.error,
        );
      }
    }
  }

  Widget _buildPaymentModeWidget(BuildContext context) {
    return Row(
      children: [
        CustomContainer(
          height: 44,
          width: 44,
          borderRadius: UiUtils.borderRadiusOf5,
          child: CustomSvgPicture(
            svgImage: _getPaymentGatewayDetails().paymentImage,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                "paymentMode".translate(context: context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colorScheme.blackColor,
              ),
              const CustomSizedBox(
                height: 4,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomText(
                      _getPaymentGatewayDetails().paymentType.translate(context: context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.accentColor,
                    ),
                  ),
                  CustomText(
                    (bookingDetails.paymentStatus!.toLowerCase().isEmpty
                                ? "pending"
                                : bookingDetails.paymentStatus?.toLowerCase())
                            ?.translate(context: context) ??
                        "",
                    color: UiUtils.getPaymentStatusColor(
                        paymentStatus: bookingDetails.paymentStatus ?? ""),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  PaymentGatewayDetails _getPaymentGatewayDetails() {
    switch (bookingDetails.paymentMethod) {
      case "cod":
        return (paymentType: "cod", paymentImage: AppAssets.cod);
      case "stripe":
        return (paymentType: "stripe", paymentImage: AppAssets.stripe);
      case "razorpay":
        return (paymentType: "razorpay", paymentImage: AppAssets.razorpay);
      case "paystack":
        return (paymentType: "paystack", paymentImage: AppAssets.paystack);
      case "paypal":
        return (paymentType: "paypal", paymentImage: AppAssets.paypal);
      case "flutterwave":
        return (paymentType: "flutterwave", paymentImage: AppAssets.flutterwave);
      default:
        return (paymentType: "cod", paymentImage: AppAssets.cod);
    }
  }
}
