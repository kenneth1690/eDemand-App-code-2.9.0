import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddAddressContainer extends StatelessWidget {
  final Function()? onTap;

  const AddAddressContainer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: () {
        onTap?.call();
      },
      child: CustomContainer(

        padding: const EdgeInsets.all(10),
        height: 45,

          color: context.colorScheme.secondaryColor,
          borderRadius: UiUtils.borderRadiusOf10,

        child: Center(
          child: Row(
            children: [
              CustomSizedBox(
                width: 45,
                child: Icon(
                  Icons.add,
                  color: context.colorScheme.blackColor,
                ),
              ),
              CustomText(
                " ${"addNewAddress".translate(context: context)}",

                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,

                textAlign: TextAlign.left,
              )
            ],
          ),
        ),
      ),
    );
  }
}
