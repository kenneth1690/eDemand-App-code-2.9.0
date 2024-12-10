// ignore_for_file: non_constant_identifier_names

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

Widget MessageContainer({
  required final BuildContext context,
  required final String text,
  required final MessageType type,
}) => Material(
    child: ToastAnimation(
      delay: UiUtils.messageDisplayDuration,
      child: CustomContainer(
        constraints:  BoxConstraints(
            minHeight: 50,
            maxHeight: 60,
            maxWidth: context.screenWidth,
            minWidth: context.screenWidth,),
        clipBehavior: Clip.hardEdge,

//
// using gradient to apply one side dark color in container
            gradient: LinearGradient(stops: const [
              0.02,
              0.02
            ], colors: [
              UiUtils.messageColors[type]!,
              UiUtils.messageColors[type]!.withOpacity(0.1),
            ],),
            borderRadius: UiUtils.borderRadiusOf10,
            border: Border.all(
              color: UiUtils.messageColors[type]!.withOpacity(0.5),
            ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 10,
              child: CustomContainer(
                height: 25,
                width: 25,

                  shape: BoxShape.circle,
                  color: UiUtils.messageColors[type],

                child: Icon(
                  UiUtils.messageIcon[type],
                  color: context.colorScheme.secondaryColor,
                  size: 20,
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 40,
              child: CustomSizedBox(
                width: context.screenWidth - 90,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomText(text.translate(context: context),

                      maxLines: 5,

                          color: UiUtils.messageColors[type],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
