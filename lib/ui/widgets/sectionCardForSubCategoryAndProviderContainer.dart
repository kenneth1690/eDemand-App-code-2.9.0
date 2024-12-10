import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class SectionCardForCategoryAndProviderContainer extends StatelessWidget {
  const SectionCardForCategoryAndProviderContainer({
    required this.discount,
    required this.onTap,
    required this.imageHeight,
    required this.imageWidth,
    required this.cardHeight,
    required this.title,
    required this.image,
    final Key? key,
  }) : super(key: key);
  final String title, image, discount;
  final double imageHeight, imageWidth, cardHeight;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
        onTap: onTap,
        child: CustomContainer(
          padding: const EdgeInsetsDirectional.only(top: 10, start: 10),
          height: cardHeight,
          width: imageWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainer(
                height: imageHeight,
                width: imageWidth,
                color: context.colorScheme.secondaryColor,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 5),
                    blurRadius: 6,
                  )
                ],
                borderRadius: UiUtils.borderRadiusOf10,
                child: Stack(
                  children: [
                    CustomSizedBox(
                      height: imageHeight,
                      width: imageWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                        child: CustomCachedNetworkImage(
                          height: 100,
                          width: 100,
                          networkImageUrl: image,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: CustomContainer(
                        width: imageWidth,
                        height: imageHeight * 0.5,
                        borderRadiusStyle: const BorderRadius.only(
                          bottomLeft: Radius.circular(UiUtils.borderRadiusOf10),
                          bottomRight: Radius.circular(UiUtils.borderRadiusOf10),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffFFFFFF).withOpacity(0),
                            const Color(0xff000000).withOpacity(0.2),
                            const Color(0xff000000).withOpacity(0.7),

                          ],
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                        ),
                      ),
                    ),
                    if (discount != "0")
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: CustomText(
                            "$discount${'percentageOff'.translate(context: context)}",
                            color: AppColors.whiteColors,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: CustomText(
                  title,
                  maxLines: 2,
                  color: context.colorScheme.blackColor,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  textAlign: TextAlign.left,
                  fontWeight: FontWeight.w500,

                ),
              ),
            ],
          ),
        ),
      );
}
