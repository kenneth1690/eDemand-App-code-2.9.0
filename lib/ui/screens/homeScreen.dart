import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/marqeeWidget.dart';
import 'package:flutter/material.dart'; // ignore_for_file: use_build_context_synchronously

import '../widgets/sliderImageWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.scrollController, final Key? key}) : super(key: key);
  final ScrollController scrollController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  FocusNode searchBarFocusNode = FocusNode();

  //
  List<String> searchValues = [
    "searchProviders",
    "searchServices",
    "searchElectronics",
    "searchHairCutting",
    "searchFanRepair"
  ];

  //
  late ValueNotifier<int> currentSearchValueIndex = ValueNotifier(0);
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));

  late final Animation<double> _bottomToCenterTextAnimation = Tween<double>(begin: 1, end: 0)
      .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.25)));

  late final Animation<double> _centerToTopTextAnimation = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.75, 1.0)));

  late Timer? _timer;

  //
  //this is used to show shadow under searchbar while scrolling
  ValueNotifier<bool> showShadowBelowSearchBar = ValueNotifier(false);

  //
  @override
  void dispose() {
    showShadowBelowSearchBar.dispose();
    searchBarFocusNode.dispose();
    currentSearchValueIndex.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialiseAnimation();
    AppQuickActions.initAppQuickActions();
    AppQuickActions.createAppQuickActions();
    //
    checkLocationPermission();
    //

    LocalAwesomeNotification.init(context);

    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (widget.scrollController.position.pixels > 7 && !showShadowBelowSearchBar.value) {
      showShadowBelowSearchBar.value = true;
    } else if (widget.scrollController.position.pixels < 7 && showShadowBelowSearchBar.value) {
      showShadowBelowSearchBar.value = false;
    }
  }

  Future<void> fetchHomeScreenData() async {
    //
    final Map<String, dynamic> currencyData =
        context.read<SystemSettingCubit>().getSystemCurrencyDetails();

    UiUtils.systemCurrency = currencyData['currencySymbol'];
    UiUtils.systemCurrencyCountryCode = currencyData['currencyCountryCode'];
    UiUtils.decimalPointsForPrice = currencyData['decimalPoints'];
    //
    final List<Future> futureAPIs = <Future>[
      context.read<HomeScreenCubit>().fetchHomeScreenData(),
      if (HiveRepository.getUserToken != "") ...[
        context.read<CartCubit>().getCartDetails(isReorderCart: false),
        context.read<BookmarkCubit>().fetchBookmark(type: 'list')
      ]
    ];
    await Future.wait(futureAPIs);
  }

  Future<void> checkLocationPermission() async {
    //
    final LocationPermission permission = await Geolocator.checkPermission();
    //
    if ((permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) &&
        ((HiveRepository.getLatitude == "0.0" || HiveRepository.getLatitude == "") &&
            (HiveRepository.getLongitude == "0.0" || HiveRepository.getLongitude == ""))) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, allowLocationScreenRoute);
        /*Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const AllowLocationScreen()));*/
      });
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position;

      if (HiveRepository.getLatitude != null &&
          HiveRepository.getLongitude != null &&
          HiveRepository.getLatitude != "" &&
          HiveRepository.getLongitude != "") {
        final latitude = HiveRepository.getLatitude ?? "0.0";
        final longitude = HiveRepository.getLongitude ?? "0.0";

        await GeocodingPlatform.instance!.placemarkFromCoordinates(
          double.parse(latitude.toString()),
          double.parse(longitude.toString()),
        );
      } else {
        position = await Geolocator.getCurrentPosition();
        await GeocodingPlatform.instance!
            .placemarkFromCoordinates(position.latitude, position.longitude);
      }

      setState(() {});
    }
  }

  @override
  Widget build(final BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: SafeArea(
          top: false,
          child: Scaffold(
            appBar: _getAppBar(),
            body: Stack(
              children: [
                Column(
                  children: [
                    const CustomSizedBox(
                      height: 70,
                    ),
                    Expanded(
                      child: BlocBuilder<CartCubit, CartState>(
                        // we have added Cart cubit
                        // because we want to calculate bottom padding of scroll
                        //
                        builder: (final BuildContext context, final CartState state) =>
                            BlocBuilder<HomeScreenCubit, HomeScreenState>(
                          builder: (context, HomeScreenState homeScreenState) {
                            if (homeScreenState is HomeScreenDataFetchSuccess) {
                              /* If data available in cart then it will return providerId,
                            and if it's returning 0 means cart is empty
                            so we do not need to add extra bottom height for padding
                            */
                              final cartButtonHeight =
                                  context.read<CartCubit>().getProviderIDFromCartData() == '0'
                                      ? 0
                                      : UiUtils.bottomNavigationBarHeight + 10;
                              if (homeScreenState.homeScreenData.category!.isEmpty &&
                                  homeScreenState.homeScreenData.sections!.isEmpty &&
                                  homeScreenState.homeScreenData.sliders!.isEmpty) {
                                return Center(
                                  child: NoDataFoundWidget(
                                    titleKey: 'weAreNotAvailableHere'.translate(context: context),
                                  ),
                                );
                              }
                              return CustomRefreshIndicator(
                                onRefreshCallback: fetchHomeScreenData,
                                displacment: 12,
                                child: SingleChildScrollView(
                                  controller: widget.scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.only(
                                    bottom: UiUtils.getScrollViewBottomPadding(context) +
                                        cartButtonHeight,
                                  ),
                                  child: Column(
                                    children: [
                                      const CustomSizedBox(
                                        height: 25,
                                      ),
                                      if (homeScreenState.homeScreenData.sliders!.isNotEmpty) ...[
                                        SliderImageWidget(
                                          sliderImages: homeScreenState.homeScreenData.sliders!,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                      _getCategoryListContainer(
                                        categoryList: homeScreenState.homeScreenData.category!,
                                      ),
                                      _getSections(
                                        sectionsList: homeScreenState.homeScreenData.sections!,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (homeScreenState is HomeScreenDataFetchFailure) {
                              return ErrorContainer(
                                errorMessage:
                                    homeScreenState.errorMessage.translate(context: context),
                                onTapRetry: () {
                                  fetchHomeScreenData();
                                },
                              );
                            }
                            return _homeScreenShimmerLoading();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  builder: (final BuildContext context, final Object? value, final Widget? child) =>
                      CustomContainer(
                    color: context.colorScheme.primaryColor,
                    borderRadius: 12,
                    boxShadow: showShadowBelowSearchBar.value
                        ? [
                            BoxShadow(
                              offset: const Offset(0, 0.75),
                              spreadRadius: 1,
                              blurRadius: 5,
                              color: context.colorScheme.lightGreyColor.withAlpha(80),
                            )
                          ]
                        : [],
                    child: _getSearchBarContainer(),
                  ),
                  valueListenable: showShadowBelowSearchBar,
                ),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: UiUtils.bottomNavigationBarHeight, right: 5, left: 5),
                  child: const Align(
                      alignment: Alignment.bottomCenter, child: CartSubDetailsContainer()),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _getSearchBarContainer() {
    return CustomContainer(
      color: context.colorScheme.secondaryColor,
      borderRadiusStyle: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: CustomInkWellContainer(
        onTap: () async {
          await Navigator.pushNamed(context, searchScreen);
        },
        child: CustomContainer(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          color: context.colorScheme.primaryColor,
          borderRadius: UiUtils.borderRadiusOf10,
          child: Row(
            children: [
              CustomContainer(
                width: 30,
                height: 30,
                margin: const EdgeInsetsDirectional.only(end: 10),
                padding: const EdgeInsets.all(5),
                child: CustomSvgPicture(
                  svgImage: AppAssets.search,
                  color: context.colorScheme.accentColor,
                ),
              ),
              Expanded(
                flex: 8,
                child: ValueListenableBuilder(
                    valueListenable: currentSearchValueIndex,
                    builder: (context, int searchValueIndex, _) {
                      return AnimatedBuilder(
                          animation: _bottomToCenterTextAnimation,
                          builder: (context, child) {
                            final dy = _bottomToCenterTextAnimation.value -
                                _centerToTopTextAnimation.value;

                            final opacity = 1 -
                                _bottomToCenterTextAnimation.value -
                                _centerToTopTextAnimation.value;

                            return Container(
                              height: 50,
                              alignment: Alignment(-1, dy),
                              child: Opacity(
                                  opacity: opacity,
                                  child: CustomText(
                                    searchValues[searchValueIndex].translate(context: context),
                                    color: context.colorScheme.lightGreyColor,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    maxLines: 1,
                                  )),
                            );
                          });
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryTextContainer() => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              'category'.translate(context: context),
              color: context.colorScheme.blackColor,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 18,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      );

  Widget _getCategoryListContainer({required final List<CategoryModel> categoryList}) =>
      categoryList.isEmpty
          ? const CustomSizedBox()
          : CustomContainer(
              color: context.colorScheme.secondaryColor,
              margin: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  _getCategoryTextContainer(),
                  _getCategoryItemsContainer(categoryList),
                ],
              ),
            );

  Widget _getTitleShimmerEffect({
    required final double height,
    required final double width,
    required final double borderRadius,
  }) =>
      CustomShimmerLoadingContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );

  Widget _getCategoryShimmerEffect() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
            child: _getTitleShimmerEffect(
              width: context.screenWidth * (0.7),
              height: context.screenHeight * (0.02),
              borderRadius: UiUtils.borderRadiusOf10,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 15),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  UiUtils.numberOfShimmerContainer,
                  (final int index) => Column(
                    children: [
                      const CustomShimmerLoadingContainer(
                        width: 75,
                        height: 75,
                        borderRadius: UiUtils.borderRadiusOf10,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      const CustomSizedBox(
                        height: 5,
                      ),
                      _getTitleShimmerEffect(
                          width: 75, height: 10, borderRadius: UiUtils.borderRadiusOf10)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _getSingleSectionShimmerEffect() => Padding(
        padding: const EdgeInsetsDirectional.only(top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _getTitleShimmerEffect(
                width: context.screenWidth * (0.7),
                height: context.screenHeight * (0.02),
                borderRadius: UiUtils.borderRadiusOf10,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  4,
                  (final int index) => const Padding(
                    padding: EdgeInsetsDirectional.only(top: 10, end: 5, start: 5),
                    child: CustomShimmerLoadingContainer(
                      width: 120,
                      height: 140,
                      borderRadius: UiUtils.borderRadiusOf10,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  AppBar _getAppBar() => AppBar(
        elevation: 0.5,
        surfaceTintColor: context.colorScheme.secondaryColor,
        backgroundColor: context.colorScheme.secondaryColor,
        leadingWidth: 0,
        leading: const CustomSizedBox(),
        title: CustomInkWellContainer(
          onTap: () {
            UiUtils.showBottomSheet(
              enableDrag: true,
              isScrollControlled: true,
              useSafeArea: true,
              child: CustomContainer(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: const LocationBottomSheet(),
              ),
              context: context,
            ).then((final value) {
              if (value != null) {
                if (value['navigateToMap']) {
                  Navigator.pushNamed(
                    context,
                    googleMapRoute,
                    arguments: {
                      "defaultLatitude": value['latitude'].toString(),
                      "defaultLongitude": value['longitude'].toString(),
                      'showAddressForm': false
                    },
                  );
                }
              }
            });
          },
          child: Row(
            children: [
              CustomContainer(
                width: 44,
                height: 44,
                color: context.colorScheme.accentColor.withAlpha(15),
                borderRadius: UiUtils.borderRadiusOf10,
                padding: const EdgeInsets.all(10),
                child: CustomSvgPicture(
                  height: 24,
                  width: 24,
                  svgImage: AppAssets.currentLocation,
                  color: context.colorScheme.accentColor,
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
                      'your_location'.translate(context: context),
                      color: context.colorScheme.lightGreyColor,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Stack(
                      children: [
                        MarqueeWidget(
                          direction: Axis.horizontal,
                          child: ValueListenableBuilder(
                            valueListenable: Hive.box(HiveRepository.userDetailBoxKey).listenable(),
                            builder: (BuildContext context, Box box, _) => CustomText(
                              " ${HiveRepository.getLocationName ?? "selectYourLocation".translate(context: context)} ",
                              color: context.colorScheme.blackColor,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 0,
                          child: Container(
                            width: 5,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.secondaryColor,
                                  context.colorScheme.secondaryColor.withOpacity(0.0005),
                                ],
                                stops: const [0.1, 1],
                                begin: AlignmentDirectional.centerStart,
                                end: AlignmentDirectional.centerEnd,
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          end: 0,
                          child: Container(
                            width: 5,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colorScheme.secondaryColor.withOpacity(0.0005),
                                  context.colorScheme.secondaryColor,
                                ],
                                stops: const [0.1, 1],
                                end: AlignmentDirectional.centerEnd,
                                begin: AlignmentDirectional.centerStart,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomInkWellContainer(
            onTap: () {
              final authStatus = context.read<AuthenticationCubit>().state;
              if (authStatus is UnAuthenticatedState) {
                UiUtils.showAnimatedDialog(context: context, child: const LogInAccountDialog());

                return;
              }
              Navigator.pushNamed(context, notificationRoute);
            },
            child: CustomContainer(
              width: 44,
              height: 44,
              margin: const EdgeInsetsDirectional.only(end: 15, start: 12),
              color: context.colorScheme.accentColor.withAlpha(15),
              borderRadius: UiUtils.borderRadiusOf10,
              padding: const EdgeInsets.all(10),
              child: CustomSvgPicture(
                height: 24,
                width: 24,
                svgImage: AppAssets.notification,
                color: context.colorScheme.accentColor,
              ),
            ),
          ),
        ],
      );

  Widget _getSections({required final List<Sections> sectionsList}) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sectionsList.length,
        itemBuilder: (final BuildContext context, int index) {
          return sectionsList[index].partners.isEmpty &&
                  sectionsList[index].subCategories.isEmpty &&
                  sectionsList[index].onGoingBookings.isEmpty &&
                  sectionsList[index].previousBookings.isEmpty &&
                  sectionsList[index].sliderImage == null
              ? const CustomSizedBox()
              : _getSingleSectionContainer(sectionsList[index]);
        },
      );

  Widget _getSingleSectionContainer(final Sections sectionData) => SingleChildScrollView(
        child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
          builder: (context, state) {
            final token = HiveRepository.getUserToken;
            if ((sectionData.sectionType == "previous_order" && token == "") ||
                (sectionData.sectionType == "ongoing_order" && token == ""))
              return const CustomSizedBox();
            //
            if (sectionData.sectionType == "banner") {
              if (sectionData.sliderImage != null) {
                return CustomContainer(
                    margin: const EdgeInsets.only(top: 10),
                    height: 190,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SingleSliderImageWidget(sliderImage: sectionData.sliderImage!));
              }
              return const SizedBox.shrink();
            }

            return CustomContainer(
              margin: const EdgeInsets.only(top: 10),
              color: context.colorScheme.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getSingleSectionTitle(sectionData),
                  _getSingleSectionData(sectionData),
                ],
              ),
            );
          },
        ),
      );

  Widget _getSingleSectionTitle(final Sections sectionData) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 10),
        child: CustomText(
          sectionData.title!,
          color: context.colorScheme.blackColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          maxLines: 1,
          textAlign: TextAlign.left,
        ),
      );

  Widget _getSingleSectionData(final Sections sectionData) {
    return CustomSizedBox(
      width: context.screenWidth,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(end: 15, start: 5),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            sectionData.subCategories.isNotEmpty
                ? sectionData.subCategories.length
                : sectionData.partners.isNotEmpty
                    ? sectionData.partners.length
                    : sectionData.onGoingBookings.isNotEmpty
                        ? sectionData.onGoingBookings.length
                        : sectionData.previousBookings.isNotEmpty
                            ? sectionData.previousBookings.length
                            : 0,
            (index) {
              if (sectionData.subCategories.isNotEmpty) {
                return SectionCardForCategoryAndProviderContainer(
                  title: sectionData.subCategories[index].name!,
                  image: sectionData.subCategories[index].image!,
                  discount: "0",
                  cardHeight: 200,
                  imageHeight: 135,
                  imageWidth: 120,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      subCategoryRoute,
                      arguments: {
                        "categoryId": sectionData.subCategories[index].id,
                        "appBarTitle": sectionData.subCategories[index].name,
                        "type": CategoryType.category,
                      },
                    );
                  },
                );
              } else if (sectionData.partners.isNotEmpty) {
                return SectionCardForCategoryAndProviderContainer(
                  title: sectionData.partners[index].companyName!,
                  image: sectionData.partners[index].image!,
                  discount: sectionData.partners[index].discount!,
                  cardHeight: 200,
                  imageHeight: 135,
                  imageWidth: 120,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      providerRoute,
                      arguments: {"providerId": sectionData.partners[index].id},
                    ).then(
                      (final Object? value) {
                        //we are changing the route name
                        //to use CartSubDetailsContainer widget to navigate to provider details screen
                        Routes.previousRoute = Routes.currentRoute;
                        Routes.currentRoute = navigationRoute;
                      },
                    );
                  },
                );
              } else if (sectionData.onGoingBookings.isNotEmpty) {
                //
                final Booking bookingData = sectionData.onGoingBookings[index];
                //

                return _getBookingDetailsCard(bookingDetailsData: bookingData);
              } else if (sectionData.previousBookings.isNotEmpty) {
                //
                final Booking bookingData = sectionData.previousBookings[index];
                //
                return _getBookingDetailsCard(bookingDetailsData: bookingData);
              }
              return const CustomSizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _getBookingDetailsCard({required Booking bookingDetailsData}) {
    return CustomContainer(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: Border.all(color: context.colorScheme.lightGreyColor, width: 0.5),
      borderRadius: UiUtils.borderRadiusOf10,
      width: context.screenWidth * 0.85,
      child: CustomInkWellContainer(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        onTap: () {
          Navigator.pushNamed(
            context,
            bookingDetails,
            arguments: {"bookingDetails": bookingDetailsData},
          );
        },
        child: BookingCardContainer(
          bookingDetails: bookingDetailsData,
          bookingScreenName: "homeScreen",
        ),
      ),
    );
  }

  Widget _getCategoryItemsContainer(final List<CategoryModel> categoryList) => CustomSizedBox(
        height: 120,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => const CustomSizedBox(
            width: 10,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, final int index) {
            return CustomContainer(
              color: context.colorScheme.secondaryColor,
              borderRadius: UiUtils.borderRadiusOf10,
              // padding: const EdgeInsetsDirectional.all(5),
              margin: const EdgeInsets.only(top: 10),
              child: Center(
                child: ImageWithText(
                  imageURL: categoryList[index].categoryImage!,
                  title: categoryList[index].name!,
                  imageContainerHeight: 65,
                  imageContainerWidth: 65,
                  textContainerHeight: 35,
                  textContainerWidth: 65,
                  maxLines: 2,
                  imageRadius: UiUtils.borderRadiusOf10,
                  fontWeight: FontWeight.w500,
                  darkModeBackgroundColor: categoryList[index].backgroundDarkColor,
                  lightModeBackgroundColor: categoryList[index].backgroundLightColor,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      subCategoryRoute,
                      arguments: {
                        'categoryId': categoryList[index].id,
                        'appBarTitle': categoryList[index].name,
                        'type': CategoryType.category,
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

  Widget _homeScreenShimmerLoading() => SingleChildScrollView(
        padding: EdgeInsets.only(bottom: UiUtils.getScrollViewBottomPadding(context)),
        child: Column(
          children: [
            _getSliderImageShimmerEffect(),
            _getCategoryShimmerEffect(),
            Column(
              children: List.generate(
                UiUtils.numberOfShimmerContainer,
                (final int index) => _getSingleSectionShimmerEffect(),
              ),
            )
          ],
        ),
      );

  Widget _getSliderImageShimmerEffect() => Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
        child: CustomShimmerLoadingContainer(
          width: context.screenWidth,
          height: 170,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
      );

  void _initialiseAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (currentSearchValueIndex.value != searchValues.length - 1) {
        currentSearchValueIndex.value += 1;
      } else {
        currentSearchValueIndex.value = 0;
      }
      _animationController.forward(from: 0.0);
    });
    //
    _animationController.forward();
  }
}
