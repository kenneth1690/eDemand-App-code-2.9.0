// ignore_for_file: file_names, use_build_context_synchronously

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({final Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => const SplashScreen(),
      );
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
    Future.delayed(Duration.zero).then((final value) {
      context.read<CountryCodeCubit>().loadAllCountryCode(context);
      context.read<SystemSettingCubit>().getSystemSettings();
      context.read<UserDetailsCubit>().loadUserDetails();
      if (HiveRepository.getUserToken != "") {
        context.read<UserDetailsCubit>().getUserDetailsFromServer();
      }

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: AppColors.splashScreenGradientTopColor,
            systemNavigationBarColor: AppColors.splashScreenGradientBottomColor,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light),
      );
    });
  }

  Future<void> getLocationData() async {
    //if already we have lat-long of customer then no need to get it again
    if ((HiveRepository.getLongitude == null && HiveRepository.getLatitude == null) ||
        (HiveRepository.getLongitude == "0.0" && HiveRepository.getLatitude == "0.0")) {
      await LocationRepository.requestPermission();
    }
  }

  Future<void> _checkAuthentication({required final bool isNeedToShowAppUpdate}) async {
    await Future.delayed(const Duration(seconds: 3), () {
      final authStatus = context.read<AuthenticationCubit>().state;

      if (authStatus is AuthenticatedState) {
        Navigator.pushReplacementNamed(context, navigationRoute);
        //
        if (isNeedToShowAppUpdate) {
          //if need to show app update screen then
          // we will push update screen, with not now button option
          Navigator.pushNamed(context, appUpdateScreen, arguments: {"isForceUpdate": false});
        }
        return;
      }
      if (authStatus is UnAuthenticatedState) {
        //
        final isFirst = HiveRepository.isUserFirstTimeInApp;
        final isSkippedLoginBefore = HiveRepository.isUserSkippedTheLoginBefore;
        //
        if (isFirst) {
          HiveRepository.setUserFirstTimeInApp = false;

          Navigator.pushReplacementNamed(context, onBoardingRoute);
        } else if (isSkippedLoginBefore) {
          Navigator.pushReplacementNamed(context, navigationRoute);
        } else {
          Navigator.pushReplacementNamed(
            context,
            loginRoute,
            arguments: {"source": "splashScreen"},
          );
        }
        if (isNeedToShowAppUpdate) {
          //if need to show app update screen then
          // we will push update screen, with not now button option
          Navigator.pushNamed(context, appUpdateScreen, arguments: {"isForceUpdate": false});
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: BlocConsumer<SystemSettingCubit, SystemSettingState>(
          listener: (final BuildContext context, final SystemSettingState state) async {
            if (state is SystemSettingFetchSuccess) {
              final GeneralSettings generalSettings = state.systemSettingDetails.generalSettings!;

              UiUtils.maxCharactersInATextMessage =
                  generalSettings.maxCharactersInATextMessage.toString().toInt();
              UiUtils.maxFilesOrImagesInOneMessage =
                  generalSettings.maxFilesOrImagesInOneMessage.toString().toInt();
              UiUtils.maxFileSizeInMBCanBeSent =
                  generalSettings.maxFileSizeInMBCanBeSent.toString().toInt();
              //
              final AppSetting appSetting = state.systemSettingDetails.appSetting!;

              //
              UiUtils.systemCurrency = appSetting.currency; /*currencyData['currencySymbol'];*/
              UiUtils.systemCurrencyCountryCode =
                  appSetting.countryCurrencyCode; /*currencyData['currencyCountryCode'];*/
              UiUtils.decimalPointsForPrice = appSetting.decimalPoint;

              //
              final List<Future> futureAPIs = <Future>[
                context.read<HomeScreenCubit>().fetchHomeScreenData(),
                if (HiveRepository.getUserToken != "") ...[
                  context.read<CartCubit>().getCartDetails(isReorderCart: false),
                  context.read<BookmarkCubit>().fetchBookmark(type: 'list')
                ]
              ];
              Future.wait(futureAPIs);

              //

              //
              // if maintenance mode is enable then we will redirect maintenance mode screen
              if (appSetting.customerAppMaintenanceMode == '1') {
                await Navigator.pushReplacementNamed(
                  context,
                  maintenanceModeScreen,
                  arguments: appSetting.messageForCustomerApplication,
                );
                return;
              }

              // here we will check current version and updated version from panel
              // if application current version is less than updated version then
              // we will show app update screen

              final String? latestAndroidVersion = appSetting.customerCurrentVersionAndroidApp;
              final latestIOSVersion = appSetting.customerCurrentVersionIosApp;

              final packageInfo = await PackageInfo.fromPlatform();

              final currentApplicationVersion = packageInfo.version;

              final currentVersion = Version.parse(currentApplicationVersion);
              final latestVersionAndroid = Version.parse(
                  latestAndroidVersion == "" ? "1.0.0" : latestAndroidVersion ?? '1.0.0');
              final latestVersionIos =
                  Version.parse(latestIOSVersion == "" ? "1.0.0" : latestIOSVersion ?? "1.0.0");

              if ((Platform.isAndroid && latestVersionAndroid > currentVersion) ||
                  (Platform.isIOS && latestVersionIos > currentVersion)) {
                // If it is force update then we will show app update with only Update button
                if (appSetting.customerCompulsaryUpdateForceUpdate == '1') {
                  Navigator.pushReplacementNamed(
                    context,
                    appUpdateScreen,
                    arguments: {'isForceUpdate': true},
                  );
                  return;
                } else {
                  // If it is normal update then
                  // we will pass true here for isNeedToShowAppUpdate
                  _checkAuthentication(isNeedToShowAppUpdate: true);
                }
              } else {
                //if no update available then we will pass false here for isNeedToShowAppUpdate
                _checkAuthentication(isNeedToShowAppUpdate: false);
              }
            }
          },
          builder: (final BuildContext context, final SystemSettingState state) {
            if (state is SystemSettingFetchFailure) {
              return ErrorContainer(
                errorMessage: state.errorMessage.toString().translate(context: context),
                onTapRetry: () {
                  context.read<SystemSettingCubit>().getSystemSettings();
                },
              );
            }
            return Stack(
              children: [
                CustomContainer(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.splashScreenGradientTopColor,
                      AppColors.splashScreenGradientBottomColor,
                    ],
                    stops: [0, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  width: context.screenWidth,
                  height: context.screenHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: const Center(
                    child:
                        CustomSvgPicture(svgImage: AppAssets.splashLogo, height: 240, width: 220),
                  ),
                ),
                if (isDemoMode)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: CustomSvgPicture(
                          svgImage: AppAssets.splashScreenBottomLogo, width: 135, height: 25),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}
