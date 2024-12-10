import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ServiceDetailsBottomSheet extends StatelessWidget {
  const ServiceDetailsBottomSheet({
    required this.serviceDetails,
    final Key? key,
  }) : super(key: key);
  final Services serviceDetails;

  Widget _buildCustomContainerWithTitleWidget({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return CustomContainer(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.blackColor,
          ),
          const CustomSizedBox(
            height: 10,
          ),
          child,
        ],
      ),
    );
  }

  //
  Widget _buildFileWidget({required BuildContext context}) {
    return _buildCustomContainerWithTitleWidget(
      context: context,
      title: "brochureOrFiles".translate(context: context),
      child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serviceDetails.filesOfTheService!.length,
          separatorBuilder: (final BuildContext context, final int index) => const CustomDivider(),
          itemBuilder: (final BuildContext context, final int index) {
            final fileName =
                serviceDetails.filesOfTheService![index].split("/").last; // get file name
            return CustomInkWellContainer(
              onTap: () {
                launchUrl(
                  Uri.parse(serviceDetails.filesOfTheService![index]),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: context.colorScheme.lightGreyColor,
                    size: 30,
                  ),
                  CustomText(
                    fileName.split(".").first,
                    color: context.colorScheme.blackColor,
                    maxLines: 1,
                  ) // remove file extension
                ],
              ),
            );
          }),
    );
  }

  Widget _buildFAQWidget({required BuildContext context}) {
    return _buildCustomContainerWithTitleWidget(
      context: context,
      title: "faqs".translate(context: context),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: List.generate(
              serviceDetails.faqsOfTheService!.length,
              (final int index) {
                // bool isExpanded = false;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      collapsedIconColor: context.colorScheme.blackColor,
                      expandedAlignment: Alignment.topLeft,
                      title: CustomText(
                        serviceDetails.faqsOfTheService![index].question ?? "",
                        color: context.colorScheme.blackColor,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        textAlign: TextAlign.left,
                      ),
                      children: <Widget>[
                        CustomText(
                          serviceDetails.faqsOfTheService![index].answer ?? "",
                          color: context.colorScheme.lightGreyColor,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 12,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceDescriptionWidget({required BuildContext context}) {
    return _buildCustomContainerWithTitleWidget(
      context: context,
      title: "serviceDescription".translate(context: context),
      child: HtmlWidget(serviceDetails.longDescription ?? ""),
    );
  }

  Widget _buildReviewWidget({required BuildContext context, required Services serviceDetails}) {
    return BlocBuilder<ServiceReviewCubit, ServiceReviewState>(
      builder: (context, state) {
        if (state is ServiceReviewFetchSuccess) {
          if (state.reviewList.isEmpty) {
            return const CustomSizedBox();
          }
          return CustomContainer(
            margin: const EdgeInsetsDirectional.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            color: context.colorScheme.secondaryColor,
            borderRadius: UiUtils.borderRadiusOf10,
            child: ReviewsContainer(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              averageRating: serviceDetails.rating ?? "0",
              totalNumberOfRatings: serviceDetails.numberOfRatings ?? "0",
              totalNumberOfFiveStarRating: serviceDetails.fiveStar ?? "0",
              totalNumberOfFourStarRating: serviceDetails.fourStar ?? "0",
              totalNumberOfThreeStarRating: serviceDetails.threeStar ?? "0",
              totalNumberOfTwoStarRating: serviceDetails.twoStar ?? "0",
              totalNumberOfOneStarRating: serviceDetails.oneStar ?? "0",
              listOfReviews: state.reviewList,
            ),
          );
        } else if (state is ServiceReviewFetchFailure) {
          return const CustomSizedBox();
        }
        return CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf10,
          height: 25,
          width: context.screenWidth,
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    return CustomContainer(
      constraints: BoxConstraints(
        minHeight: context.screenHeight * 0.3,
        maxHeight: context.screenHeight * 0.8,
      ),
      color: context.colorScheme.primaryColor,
      borderRadiusStyle: const BorderRadius.only(
        topLeft: Radius.circular(UiUtils.borderRadiusOf20),
        topRight: Radius.circular(UiUtils.borderRadiusOf20),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ServiceDetailsCard(
              services: serviceDetails,
              showAddButton: false,
              showDescription: false,
            ),
            _buildCustomContainerWithTitleWidget(
              context: context,
              title: 'aboutService'.translate(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomReadMoreTextContainer(
                    text: serviceDetails.description ?? "",
                    textStyle: TextStyle(
                      color: context.colorScheme.lightGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            if (serviceDetails.longDescription!.isNotEmpty) ...[
              _buildServiceDescriptionWidget(context: context)
            ],
            if (serviceDetails.otherImagesOfTheService!.isNotEmpty) ...[
              _buildCustomContainerWithTitleWidget(
                context: context,
                title: "photos".translate(context: context),
                child: GalleryImagesStyles(imagesList: serviceDetails.otherImagesOfTheService!),
              ),
            ],
            if (serviceDetails.filesOfTheService!.isNotEmpty) ...[
              _buildFileWidget(context: context),
            ],
            if (serviceDetails.faqsOfTheService!.isNotEmpty) ...[_buildFAQWidget(context: context)],
            _buildReviewWidget(context: context, serviceDetails: serviceDetails),
          ],
        ),
      ),
    );
  }
}
