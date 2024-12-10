import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class RatingBottomSheet extends StatefulWidget {
  final String serviceID;
  final String serviceName;
  final int? ratingStar;
  final String reviewComment;

  const RatingBottomSheet({
    Key? key,
    required this.serviceID,
    required this.serviceName,
    this.ratingStar,
    required this.reviewComment,
  }) : super(key: key);

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  // comment controller
  final TextEditingController reviewController = TextEditingController();

  int? selectedRating;

//image picker for review images
  final ImagePicker imagePicker = ImagePicker();
  ValueNotifier<List<XFile?>> reviewImages = ValueNotifier([]);

  Future<void> selectReviewImage() async {
    final List<XFile> listOfSelectedImage = await imagePicker.pickMultiImage();
    if (listOfSelectedImage.isNotEmpty) {
      reviewImages.value = listOfSelectedImage;
    }
  }

  @override
  void dispose() {
    reviewImages.dispose();
    reviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.reviewComment != "") {
      reviewController.text = widget.reviewComment;
    }
    if (widget.ratingStar != null) {
      selectedRating = widget.ratingStar! - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BottomSheetLayout(
        title: "reviewAndRating",
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainer(
                margin: const EdgeInsetsDirectional.only(bottom: 10, start: 5, top: 5),
                child: CustomText(
                  widget.serviceName,
                  color: context.colorScheme.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  children: List.generate(5, (index) {
                    return CustomInkWellContainer(
                      onTap: () {
                        selectedRating = index;
                        setState(() {});
                      },
                      child: CustomContainer(
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        width: 40,
                        height: 25,
                        color: selectedRating == index
                            ? context.colorScheme.accentColor
                            : null,
                        borderRadius: UiUtils.borderRadiusOf5,
                        border: Border.all(color: context.colorScheme.accentColor),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                '${index + 1}',
                                color: selectedRating == index
                                    ? AppColors.whiteColors
                                    : context.colorScheme.lightGreyColor,
                                fontSize: 12,
                              ),
                              Icon(
                                Icons.star_outlined,
                                size: 15,
                                color: selectedRating == index
                                    ? AppColors.whiteColors
                                    : context.colorScheme.lightGreyColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              CustomContainer(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                height: 100,
                child: TextField(
                  style: TextStyle(fontSize: 12, color: context.colorScheme.blackColor),
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  controller: reviewController,
                  cursorColor: context.colorScheme.blackColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15),
                    filled: false,
                    fillColor: context.colorScheme.secondaryColor,
                    hintText:
                        "${"writeReview".translate(context: context)} for ${widget.serviceName}",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.lightGreyColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colorScheme.accentColor),
                      borderRadius: const BorderRadius.all(Radius.circular(UiUtils.borderRadiusOf5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colorScheme.accentColor),
                      borderRadius: const BorderRadius.all(Radius.circular(UiUtils.borderRadiusOf5)),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colorScheme.accentColor),
                      borderRadius: const BorderRadius.all(Radius.circular(UiUtils.borderRadiusOf5)),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: reviewImages,
                builder: (context, List<XFile?> value, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    //if images is there then we will enable scroll
                    physics: value.isEmpty
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        CustomInkWellContainer(
                          onTap: selectReviewImage,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 15),
                            child: DottedBorderWithHint(
                              width: value.isEmpty ? context.screenWidth - 40 : 100,
                              height: 100,
                              radius: 5,
                              borderColor: context.colorScheme.accentColor,
                              hint: "chooseImage".translate(context: context),
                              svgImage: AppAssets.imageIcon,
                              needToShowHintText: value.isEmpty,
                            ),
                          ),
                        ),
                        if (value.isNotEmpty)
                          Row(
                            children: List.generate(
                              value.length,
                              (index) => CustomContainer(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                height: 100,
                                width: 100,
                                border: Border.all(
                                  color: context.colorScheme.blackColor.withOpacity(0.5),
                                ),
                                child: Stack(
                                  children: [
                                    Center(child: Image.file(File(value[index]!.path))),
                                    Align(
                                      alignment: AlignmentDirectional.topEnd,
                                      child: CustomInkWellContainer(
                                        onTap: () async {
                                          /*  reviewImages.value.removeAt(index);

                                          reviewImages.notifyListeners();*/

                                          //assigning new list, because listener will not notify if we remove the values only to the list
                                          reviewImages.value = List.from(reviewImages.value)
                                            ..removeAt(index);
                                        },
                                        child: CustomContainer(
                                          height: 20,
                                          width: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .blackColor
                                              .withOpacity(0.4),
                                          child: const Center(
                                            child: Icon(
                                              Icons.clear_rounded,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
              BlocConsumer<SubmitReviewCubit, SubmitReviewState>(
                listener: (context, state) async {
                  if (state is SubmitReviewSuccess) {
                    UiUtils.showMessage(
                      context,
                      "reviewSubmittedSuccessfully".translate(context: context),
                      MessageType.success,
                    );
                    Navigator.pop(context,{
                      "comment" : state.data["comment"],
                      "rating" : state.data["rating"],
                      "images" : state.data["images"]
                    });
                  } else if (state is SubmitReviewFailure) {
                    UiUtils.showMessage(
                      context,
                      state.errorMessage.translate(context: context),
                      MessageType.error,
                    );
                  }
                },
                builder: (context, state) {
                  Widget? child;
                  if (state is SubmitReviewInProgress) {
                    child = const CustomCircularProgressIndicator(color: AppColors.whiteColors);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CustomRoundedButton(
                      onTap: () {
                        if (selectedRating == null) {
                          UiUtils.showMessage(
                            context,
                            "pleaseGiveRating".translate(context: context),
                            MessageType.warning,
                          );
                          return;
                        }

                        context.read<SubmitReviewCubit>().submitReview(
                              serviceId: widget.serviceID,
                              ratingStar: (selectedRating! + 1).toString(),
                              reviewComment: reviewController.text.trim().toString(),
                              reviewImages: reviewImages.value,
                            );
                      },
                      widthPercentage: 1,
                      backgroundColor: context.colorScheme.accentColor,
                      buttonTitle: "submitReview".translate(context: context),
                      showBorder: false,
                      child: child,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
