import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BottomSheetLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const BottomSheetLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colorScheme.primaryColor,
      borderRadiusStyle: const BorderRadius.only(
          topRight: Radius.circular(UiUtils.borderRadiusOf20), topLeft: Radius.circular(UiUtils.borderRadiusOf20)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              width: context.screenWidth,
              padding: const EdgeInsets.all(15.0),
              color: context.colorScheme.secondaryColor,
              borderRadiusStyle: const BorderRadius.only(
                  topRight: Radius.circular(UiUtils.borderRadiusOf20),
                  topLeft: Radius.circular(UiUtils.borderRadiusOf20)),
              child: CustomText(
                title.translate(context: context),
                fontSize: 20.0,
                maxLines: 1,
                color: context.colorScheme.blackColor,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                textAlign: TextAlign.start,
              ),
            ),
            CustomContainer(
              padding: const EdgeInsets.only(top: 5),
              color: context.colorScheme.primaryColor,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
