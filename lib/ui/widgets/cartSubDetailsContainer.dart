import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/cart/removeCartCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shader_snap/flutter_shader_snap.dart';

class CartSubDetailsContainer extends StatefulWidget {
  const CartSubDetailsContainer({final Key? key, this.providerID})
      : super(key: key);
  final String? providerID;

  @override
  State<CartSubDetailsContainer> createState() =>
      _CartSubDetailsContainerState();
}

class _CartSubDetailsContainerState extends State<CartSubDetailsContainer>
    with TickerProviderStateMixin {
  //
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        context.read<CartCubit>().clearCartCubit();
        _controller.reset();
      }
    });

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    final curve =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animController);
    _animOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.25, 0))
        .animate(curve);
  }

  @override
  Widget build(final BuildContext context) => AnimationFromBottomSide(
        delay: 250,
        child: SnapShader(
          snapShaderType: SnapShaderType.smoke,
          controller: _controller,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (BuildContext context, final CartState state) {
              if (state is CartInitial) {
                return const CustomSizedBox();
              } else if (state is CartFetchSuccess) {
                if (state.cartData.cartDetails == null) {
                  return const CustomSizedBox();
                }

                return state.cartData.cartDetails!.isEmpty
                    ? const CustomSizedBox()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: BlocProvider(
                          create: (context) => RemoveCartCubit(),
                          child: Builder(builder: (context) {
                            return Stack(
                              children: [
                                CustomContainer(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                  color: AppColors.redColor,
                                  borderRadius: UiUtils.borderRadiusOf10,
                                  height: kBottomNavigationBarHeight,
                                  width: context.screenWidth * 0.95,
                                  child: CustomInkWellContainer(
                                    borderRadius: BorderRadius.circular(
                                        UiUtils.borderRadiusOf10),
                                    onTap: () {
                                      _animController.reverse();
                                      context
                                          .read<RemoveCartCubit>()
                                          .removeCart(
                                              providerId:
                                                  state.cartData.providerId ??
                                                      "0");
                                    },
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: CustomText(
                                          "remove".translate(context: context),
                                          color: AppColors.whiteColors,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SlideTransition(
                                  position: _animOffset,
                                  child: CustomContainer(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                    color: context.colorScheme.accentColor,
                                    borderRadius: UiUtils.borderRadiusOf10,
                                    height: kBottomNavigationBarHeight,
                                    width: context.screenWidth * 0.95,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  CustomText(
                                                    "${state.cartData.subTotal!.priceFormat()} | ${state.cartData.totalQuantity} ${(int.parse(state.cartData.totalQuantity ?? "0") > 1 ? "services" : "service").translate(context: context)} ",
                                                    color:
                                                        AppColors.whiteColors,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  if (state.cartData
                                                          .providerId !=
                                                      widget.providerID)
                                                    CustomInkWellContainer(
                                                      onTap: () {
                                                        if (state.cartData
                                                                .providerId !=
                                                            widget.providerID) {
                                                          Navigator.pushNamed(
                                                            context,
                                                            providerRoute,
                                                            arguments: {
                                                              "providerId": state
                                                                  .cartData
                                                                  .providerId
                                                            },
                                                          ).then(
                                                            (Object? value) {
                                                              //we are changing the route name
                                                              // to use CartSubDetailsContainer widget to navigate to provider details screen
                                                              Routes.previousRoute =
                                                                  Routes
                                                                      .currentRoute;
                                                              Routes.currentRoute =
                                                                  navigationRoute;
                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: CustomText(
                                                        "view".translate(
                                                            context: context),
                                                        color: AppColors
                                                            .whiteColors,
                                                        showUnderline: true,
                                                        underlineOrLineColor:
                                                            AppColors
                                                                .whiteColors,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              CustomText(
                                                "${"from".translate(context: context)} ${state.cartData.companyName}",
                                                fontSize: 12,
                                                color: AppColors.whiteColors,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () {
                                            context
                                                .read<GetPromocodeCubit>()
                                                .getPromocodes(
                                                    providerId: state.cartData
                                                            .providerId ??
                                                        "0");
                                            //

                                            Navigator.pushNamed(
                                              context,
                                              scheduleScreenRoute,
                                              arguments: {
                                                "isFrom": "cart",
                                                "providerName": state.cartData
                                                        .providerName ??
                                                    "",
                                                "providerId":
                                                    state.cartData.providerId ??
                                                        "0",
                                                "companyName": state
                                                        .cartData.companyName ??
                                                    "",
                                                "providerAdvanceBookingDays":
                                                    state.cartData
                                                        .advanceBookingDays,
                                              },
                                            );
                                          },
                                          height: double.maxFinite,
                                          child: CustomText(
                                            'continueText'
                                                .translate(context: context),
                                            color: AppColors.whiteColors,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        BlocConsumer<RemoveCartCubit,
                                            RemoveCartState>(
                                          listener: (context, removeCartState) {
                                            if (removeCartState
                                                is RemoveCartSuccess) {
                                              _controller.forward();
                                            }
                                          },
                                          builder: (context, removeCartState) {
                                            final bool isLoading = removeCartState
                                                is RemoveCartInProgress;

                                            return CustomInkWellContainer(
                                              onTap: () {
                                                if (_animController
                                                    .isCompleted) {
                                                  _animController.reverse();
                                                } else {
                                                  _animController.forward();
                                                }
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      UiUtils.borderRadiusOf50),
                                              child: CustomContainer(
                                                  margin: const EdgeInsetsDirectional
                                                      .only(end: 5),
                                                  height: 24,
                                                  width: 24,
                                                  borderRadius:
                                                      UiUtils.borderRadiusOf50,
                                                  color: AppColors.whiteColors,
                                                  child: isLoading
                                                      ? const Center(
                                                          child:
                                                              CustomCircularProgressIndicator(
                                                            widthAndHeight: 20,
                                                          ),
                                                        )
                                                      : CustomToolTip(
                                                          toolTipMessage:
                                                              "deleteCart",
                                                          child: Icon(
                                                            Icons.close,
                                                            color: context
                                                                .colorScheme
                                                                .accentColor,
                                                            size: 16,
                                                          ),
                                                        )),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      );
              }
              return const CustomSizedBox();
            },
          ),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
