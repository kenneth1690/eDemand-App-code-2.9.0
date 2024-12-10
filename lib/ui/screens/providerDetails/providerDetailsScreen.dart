import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({required this.providerID, final Key? key}) : super(key: key);
  final String providerID;

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => BlocProvider(
        create: (context) =>
            ProviderDetailsAndServiceCubit(ServiceRepository(), ProviderRepository()),
        child: ProviderDetailsScreen(
          providerID: arguments["providerId"],
        ),
      ),
    );
  }
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  //
  late TabController _tabController = TabController(length: 4, vsync: this);

  List<String> tabLabels = ['services', 'reviews', 'promocodes', 'about'];

  //
  ScrollController _serviceListScrollController = ScrollController();

  //
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((final value) {
      fetchProviderDetailsAndServices();
      context.read<GetPromocodeCubit>().getPromocodes(providerId: widget.providerID);
    });

    _tabController.addListener(tabBarListener);

    //_serviceListScrollController.addListener(serviceListScrollController);
  }

  void serviceListScrollController() {
    if (mounted && !context.read<ProviderDetailsAndServiceCubit>().hasMoreServices()) {
      return;
    }
// nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger = 0.7 * _serviceListScrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_serviceListScrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context
            .read<ProviderDetailsAndServiceCubit>()
            .fetchMoreServices(providerId: widget.providerID);
      }
    }
  }

  void tabBarListener() {
    Future.delayed(Duration.zero).then((value) {
      if (_tabController.index == 2) {
        if (context.read<GetPromocodeCubit>().state is FetchPromocodeFailure &&
            context.read<AuthenticationCubit>().state is! UnAuthenticatedState) {
          context.read<GetPromocodeCubit>().getPromocodes(providerId: widget.providerID);
        }
      }
    });
  }

  void fetchProviderDetailsAndServices() {
    context
        .read<ProviderDetailsAndServiceCubit>()
        .fetchProviderDetailsAndServices(providerId: widget.providerID);
    context.read<ReviewCubit>().fetchReview(providerId: widget.providerID);
  }

  Widget providerDetailsScreenShimmerLoading() => SingleChildScrollView(
        child: Column(
          children: [
            CustomShimmerLoadingContainer(
              height: context.screenHeight * 0.4,
              width: context.screenWidth,
            ),
            const CustomShimmerLoadingContainer(
              borderRadius: 0,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              height: 50,
            ),
            Column(
              children: List.generate(
                UiUtils.numberOfShimmerContainer,
                (final int index) => const CustomShimmerLoadingContainer(
                  height: 150,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                ),
              ),
            )
          ],
        ),
      );

  @override
  void dispose() {
    _serviceListScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (final BuildContext context, final CartState state) =>
            BlocBuilder<ProviderDetailsAndServiceCubit, ProviderDetailsAndServiceState>(
          builder: (final context, final state) {
            if (state is ProviderDetailsAndServiceFetchFailure) {
              return Center(
                child: ErrorContainer(
                  onTapRetry: () {
                    fetchProviderDetailsAndServices();
                  },
                  errorMessage: state.errorMessage.translate(context: context),
                ),
              );
            } else if (state is ProviderDetailsAndServiceFetchSuccess) {
              return Stack(
                children: [
                  NestedScrollView(
                    controller: _serviceListScrollController,
                    headerSliverBuilder:
                        (final BuildContext context, final bool innerBoxIsScrolled) => <Widget>[
                      SliverAppBar(
                        leading: CustomContainer(
                          margin: const EdgeInsetsDirectional.only(
                            end: 10,
                            top: 10,
                            bottom: 10,
                            start: 10,
                          ),
                          color: context.colorScheme.accentColor.withOpacity(0.3),
                          borderRadius: UiUtils.borderRadiusOf5,
                          child: CustomInkWellContainer(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
                              child: CustomSvgPicture(
                                svgImage:
                                    context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                                        ? Directionality.of(context)
                                                .toString()
                                                .contains(TextDirection.RTL.value.toLowerCase())
                                            ? AppAssets.backArrowDarkLtr
                                            : AppAssets.backArrowDark
                                        : Directionality.of(context)
                                                .toString()
                                                .contains(TextDirection.RTL.value.toLowerCase())
                                            ? AppAssets.backArrowLightLtr
                                            : AppAssets.backArrowLight,
                                color: context.colorScheme.accentColor,
                              ),
                            ),
                          ),
                        ),
                        systemOverlayStyle:
                            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                        pinned: true,
                        elevation: 0,
                        surfaceTintColor: context.colorScheme.secondaryColor,
                        expandedHeight: context.screenHeight * 0.37,
                        backgroundColor: context.colorScheme.secondaryColor,
                        actions: [
                          CustomToolTip(
                            toolTipMessage: "share".translate(context: context),
                            child: CustomContainer(
                              height: 40,
                              width: 40,
                              margin: const EdgeInsetsDirectional.only(
                                top: 10,
                                bottom: 10,
                              ),
                              color: context.colorScheme.accentColor.withOpacity(0.3),
                              borderRadius: UiUtils.borderRadiusOf5,
                              child: CustomInkWellContainer(
                                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                                onTap: () => _handleShareButtonClick(
                                  providerDetails: state.providerDetails,
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.all(10),
                                  child: CustomSvgPicture(
                                    svgImage: AppAssets.shareSp,
                                    color: context.colorScheme.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const CustomSizedBox(
                            width: 10,
                          ),
                          BlocBuilder<UserDetailsCubit, UserDetailsState>(
                              builder: (context, userDetails) {
                            final token = HiveRepository.getUserToken;

                            return Row(
                              children: [
                                CustomContainer(
                                  height: 40,
                                  width: 40,
                                  margin: const EdgeInsetsDirectional.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  padding: const EdgeInsetsDirectional.symmetric(
                                      horizontal: 10, vertical: 10),
                                  color: context.colorScheme.accentColor.withOpacity(0.3),
                                  borderRadius: UiUtils.borderRadiusOf5,
                                  child: BookMarkIcon(
                                    providerData: state.providerDetails,
                                  ),
                                ),
                                const CustomSizedBox(
                                  width: 10,
                                ),
                                if (state.providerDetails.isPreBookingChatAllowed == "1" &&
                                    token != "") ...[
                                  CustomInkWellContainer(
                                    borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
                                    onTap: () {
                                      Navigator.pushNamed(context, chatMessages, arguments: {
                                        "chatUser": ChatUser(
                                          id: state.providerDetails.providerId ?? "-",
                                          name: state.providerDetails.companyName.toString(),
                                          receiverType: "1",
                                          bookingId: "0",
                                          providerId: state.providerDetails.providerId,
                                          // 1 = provider
                                          unReadChats: 0,
                                          profile: state.providerDetails.image,
                                          senderId: context
                                                  .read<UserDetailsCubit>()
                                                  .getUserDetails()
                                                  .id ??
                                              "0",
                                        ),
                                      });
                                    },
                                    child: CustomContainer(
                                      height: 40,
                                      width: 40,
                                      margin: const EdgeInsetsDirectional.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 10, vertical: 10),
                                      color: context.colorScheme.accentColor.withOpacity(0.3),
                                      borderRadius: UiUtils.borderRadiusOf5,
                                      child: CustomSvgPicture(
                                        svgImage: AppAssets.drChat,
                                        color: context.colorScheme.accentColor,
                                      ),
                                    ),
                                  ),
                                  const CustomSizedBox(
                                    width: 10,
                                  ),
                                ],
                              ],
                            );
                          }),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          stretchModes: const [StretchMode.zoomBackground],
                          background: Stack(
                            children: [
                              CustomSizedBox(
                                width: context.screenWidth,
                                height: context.screenHeight * 0.27,
                                child: CustomCachedNetworkImage(
                                  height: 100,
                                  width: 100,
                                  networkImageUrl: state.providerDetails.bannerImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              PositionedDirectional(
                                top: context.screenHeight * 0.27 - 7,
                                child: CustomContainer(
                                  height: 10,
                                  width: context.screenWidth,
                                  color: context.colorScheme.secondaryColor,
                                  borderRadiusStyle: const BorderRadius.only(
                                    topRight: Radius.circular(UiUtils.borderRadiusOf10),
                                    topLeft: Radius.circular(UiUtils.borderRadiusOf10),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                top: context.screenHeight * 0.27 - 45,
                                start: (context.screenWidth * 0.5) - 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
                                  child: CustomContainer(
                                    width: 80,
                                    height: 80,
                                    color: context.colorScheme.secondaryColor,
                                    borderRadius: UiUtils.borderRadiusOf20,
                                    child: CustomCachedNetworkImage(
                                      height: 80,
                                      width: 80,
                                      networkImageUrl: state.providerDetails.image!,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                top: context.screenHeight * 0.27 + 50,
                                child: CustomSizedBox(
                                  width: context.screenWidth,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CustomInkWellContainer(
                                        showRippleEffect: false,
                                        onTap: () {
                                          _tabController.animateTo(3);
                                        },
                                        child: CustomText(
                                          state.providerDetails.companyName ?? "",
                                          maxLines: 1,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.colorScheme.blackColor,
                                        ),
                                      ),
                                      const CustomSizedBox(
                                        height: 5,
                                      ),
                                      CustomInkWellContainer(
                                        showRippleEffect: false,
                                        onTap: () => _tabController.animateTo(1),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(5, (final int index) {
                                                final double starRating =
                                                    double.parse(state.providerDetails.ratings!);
                                                if (index < starRating) {
                                                  return const Icon(
                                                    Icons.star,
                                                    color: AppColors.ratingStarColor,
                                                  );
                                                }
                                                return Icon(
                                                  Icons.star,
                                                  color: context.colorScheme.lightGreyColor,
                                                );
                                              }),
                                            ),
                                            const CustomSizedBox(
                                              width: 10,
                                            ),
                                            CustomText(
                                              state.providerDetails.numberOfRatings!,
                                              color: context.colorScheme.blackColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                            const CustomSizedBox(
                                              width: 5,
                                            ),
                                            CustomText(
                                              " ${"reviewers".translate(context: context)}",
                                              fontSize: 14,
                                              color: context.colorScheme.lightGreyColor,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverAppBarDelegate(
                          maxHeight: 50,
                          minHeight: 50,
                          child: CustomContainer(
                            color: context.colorScheme.secondaryColor,
                            child: TabBar(
                              controller: _tabController,
                              indicatorColor: context.colorScheme.accentColor,
                              unselectedLabelColor: context.colorScheme.lightGreyColor,
                              labelColor: context.colorScheme.accentColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              indicatorPadding: const EdgeInsets.only(bottom: 5),
                              dividerColor: Colors.transparent,
                              tabs: tabLabels
                                  .map(
                                    (e) => Tab(
                                      text: e.translate(context: context),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      )
                    ],
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        ProviderServicesContainer(
                          isProviderAvailableAtLocation:
                              state.providerDetails.isAvailableAtLocation!,
                          servicesList: state.serviceList,
                          providerID: state.providerDetails.providerId ?? "0",
                          isLoadingMoreData: state.isLoadingMoreServices,
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.only(
                            bottom: context.read<CartCubit>().getProviderIDFromCartData() == '0'
                                ? 0
                                : UiUtils.bottomNavigationBarHeight + 10,
                          ),
                          child: BlocBuilder<ReviewCubit, ReviewState>(
                            builder: (context, reviewState) {
                              if (reviewState is ReviewFetchFailure) {
                                return ErrorContainer(
                                  errorMessage:
                                      reviewState.errorMessage.translate(context: context),
                                  onTapRetry: () {
                                    context.read<ReviewCubit>().fetchReview(
                                          providerId: state.providerDetails.providerId ?? "0",
                                        );
                                  },
                                );
                              } else if (reviewState is ReviewFetchSuccess) {
                                //

                                if (reviewState.reviewList.isEmpty) {
                                  return Center(
                                    child: NoDataFoundWidget(
                                      titleKey: "noReviewsFound".translate(context: context),
                                    ),
                                  );
                                }
                                return CustomContainer(
                                  margin: const EdgeInsets.all(10),
                                  color: context.colorScheme.secondaryColor,
                                  borderRadius: UiUtils.borderRadiusOf10,
                                  child: ReviewsContainer(
                                    listOfReviews: reviewState.reviewList,
                                    totalNumberOfRatings:
                                        state.providerDetails.numberOfRatings ?? "0",
                                    averageRating: state.providerDetails.ratings ?? "0",
                                    totalNumberOfFiveStarRating:
                                        state.providerDetails.fiveStar ?? "0",
                                    totalNumberOfFourStarRating:
                                        state.providerDetails.fourStar ?? "0",
                                    totalNumberOfThreeStarRating:
                                        state.providerDetails.threeStar ?? "0",
                                    totalNumberOfTwoStarRating:
                                        state.providerDetails.twoStar ?? "0",
                                    totalNumberOfOneStarRating:
                                        state.providerDetails.oneStar ?? "0",
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  ),
                                );
                              }
                              return CustomShimmerLoadingContainer(
                                width: context.screenWidth * 0.9,
                                height: 25,
                                borderRadius: UiUtils.borderRadiusOf10,
                              );
                            },
                          ),
                        ),
                        if (context.read<AuthenticationCubit>().state is UnAuthenticatedState) ...[
                          Center(
                            child: NoDataFoundWidget(
                              titleKey: 'noPromoCodeAvailable'.translate(context: context),
                            ),
                          )
                        ] else ...[
                          PromocodeContainer(providerId: state.providerDetails.providerId ?? "0"),
                        ],
                        AboutProviderContainer(providerDetails: state.providerDetails)
                      ],
                    ),
                  ),
                  if (context.watch<CartCubit>().state is CartFetchSuccess &&
                      ((context.watch<CartCubit>().state as CartFetchSuccess)
                                  .cartData
                                  .cartDetails ??
                              [])
                          .isNotEmpty) ...[
                    PositionedDirectional(
                      start: context.screenWidth * 0.01,
                      end: context.screenWidth * 0.01,
                      bottom: 0,
                      child: CartSubDetailsContainer(
                        providerID: state.providerDetails.providerId,
                      ),
                    ),
                  ],
                ],
              );
            }
            return providerDetailsScreenShimmerLoading();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _handleShareButtonClick({required Providers providerDetails}) async {
    final box = context.findRenderObject() as RenderBox?;

    final sharePositionOrigin = box!.localToGlobal(Offset.zero) & box.size;
    //
    final String shareURL =
        "${providerDetails.companyName}\n\n$domainURL/provider/${providerDetails.providerId}";

    await Share.share(
      shareURL,
      subject: "Share Provider",
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
