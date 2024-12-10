import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderConfirm extends StatefulWidget {
  const OrderConfirm({required this.isSuccess, required this.orderId, super.key});

  final bool isSuccess;
  final String orderId;

  static Route route(final RouteSettings routeSettings) {
    //
    final Map arguments = routeSettings.arguments as Map;
    //
    return CupertinoPageRoute(
      builder: (final _) => BlocProvider<AddTransactionCubit>(
        create: (final BuildContext context) =>
            AddTransactionCubit(bookingRepository: BookingRepository()),
        child: OrderConfirm(
          isSuccess: arguments["isSuccess"],
          orderId: arguments["orderId"],
        ),
      ),
    );
  }

  @override
  State<OrderConfirm> createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  @override
  void initState() {
    super.initState();
    callAPIs();
  }

  Future<void> callAPIs() async {
    Future.delayed(Duration.zero).then(
      (final value) async {
        //
        await context.read<AddTransactionCubit>().addTransaction(
            status: widget.isSuccess ? "success" : "cancelled", orderID: widget.orderId);

        //context.read<BookingCubit>().fetchBookingDetails(status: "");
        UiUtils.bookingScreenGlobalKey.currentState?.fetchBookingDetails();
        context.read<CartCubit>().getCartDetails(isReorderCart: false);
      },
    );
  }

  @override
  Widget build(final BuildContext context) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'confirmation'.translate(context: context),
            centerTitle: true,
            isLeadingIconEnable: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    widget.isSuccess
                        ? "assets/animation/success.json"
                        : "assets/animation/fail.json",
                    height: 150,
                    width: 150,
                  ),

                  const CustomSizedBox(
                    height: 25,
                  ),
                  CustomText(
                    widget.isSuccess
                        ? "bookingSuccessMessage".translate(context: context)
                        : "bookingFailureMessage".translate(context: context),
                    textAlign: TextAlign.center,
                    color: context.colorScheme.blackColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                  ),
                  const CustomSizedBox(
                    height: 25,
                  ),
                  if (!widget.isSuccess)
                    CustomRoundedButton(
                      widthPercentage: 0.9,
                      backgroundColor: context.colorScheme.accentColor,
                      buttonTitle: 'rePayment'.translate(context: context),
                      showBorder: false,
                      onTap: () {
                        //Navigator.popUntil(context, ModalRoute.withName(orderSummaryDetailsRoute));
                        Navigator.pop(context);
                      },
                    ),
                  const CustomSizedBox(
                    height: 25,
                  ),
                  CustomRoundedButton(
                    widthPercentage: 0.9,
                    backgroundColor: context.colorScheme.accentColor,
                    buttonTitle: 'goToHome'.translate(context: context),
                    showBorder: false,
                    onTap: () {
                      //Navigator.popUntil(context, ModalRoute.withName(orderSummaryDetailsRoute));
                      Navigator.of(context).popUntil(
                        (final Route route) => route.isFirst,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
