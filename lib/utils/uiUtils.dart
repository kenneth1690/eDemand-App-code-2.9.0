// ignore_for_file: prefer_final_locals

import 'dart:ui';

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

enum MessageType { success, error, warning }

class UiUtils {
  static String? systemCurrency;
  static String? systemCurrencyCountryCode;
  static String? decimalPointsForPrice;

  //
  static const int minimumMobileNumberDigit = 6;
  static const int maximumMobileNumberDigit = 15;

  //constant variables
  static const String limitOfAPIData = "10";

  static const String animationPath = "assets/animation/";

//global key
  static GlobalKey<CustomNavigationBarState> bottomNavigationBarGlobalKey =
      GlobalKey<CustomNavigationBarState>();

//
  static GlobalKey<BookingsScreenState> bookingScreenGlobalKey = GlobalKey<BookingsScreenState>();

  //key for global navigation
  static GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  // to manage snackBar/toast/message

  static Map<MessageType, Color> messageColors = {
    MessageType.success: Colors.green,
    MessageType.error: Colors.red,
    MessageType.warning: Colors.orange
  };

  static Map<MessageType, IconData> messageIcon = {
    MessageType.success: Icons.done_rounded,
    MessageType.error: Icons.error_outline_rounded,
    MessageType.warning: Icons.warning_amber_rounded
  };

  //border radius
  static const double borderRadiusOf5 = 5;
  static const double borderRadiusOf10 = 10;
  static const double borderRadiusOf20 = 20;
  static const double borderRadiusOf50 = 50;

  static double bottomNavigationBarHeight = kBottomNavigationBarHeight;

//
// Toast message display duration
  static const int messageDisplayDuration = 3000;

//shimmerLoadingContainer value
  static int numberOfShimmerContainer = 7;

//to give bottom scroll padding in screen where
//bottom navigation bar is displayed
  static double getScrollViewBottomPadding(final BuildContext context) =>
      kBottomNavigationBarHeight + 5;

//chat message sending related controls

  static int? maxFilesOrImagesInOneMessage;
  static int? maxFileSizeInMBCanBeSent;
  static int? maxCharactersInATextMessage;

  static List<String> chatPredefineMessagesForProvider = [
    "chatPreDefineMessageForProvider1",
    "chatPreDefineMessageForProvider2",
    "chatPreDefineMessageForProvider3",
    "chatPreDefineMessageForProvider4",
    "chatPreDefineMessageForProvider5",
    "chatPreDefineMessageForProvider6",
  ];
  static List<String> chatPreBookingMessageForProvider = [
    "chatPreBookingMessageForProvider1",
    "chatPreBookingMessageForProvider2",
    "chatPreBookingMessageForProvider3",
    "chatPreBookingMessageForProvider4",
    "chatPreBookingMessageForProvider5",
  ];

  static List<String> chatPredefineMessagesForAdmin = [
    "chatPreDefineMessageForAdmin1",
    "chatPreDefineMessageForAdmin2",
    "chatPreDefineMessageForAdmin3",
    "chatPreDefineMessageForAdmin4",
    "chatPreDefineMessageForAdmin5",
    "chatPreDefineMessageForAdmin6",
  ];

  static Locale getLocaleFromLanguageCode(final String languageCode) {
    final result = languageCode.split("-");
    return result.length == 1 ? Locale(result.first) : Locale(result.first, result.last);
  }

  static Future<void> showMessage(
      final BuildContext context, final String text, final MessageType type) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (final context) => Positioned(
        left: 5,
        right: 5,
        bottom: 15,
        child: MessageContainer(
          context: context,
          text: text,
          type: type,
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(const Duration(milliseconds: messageDisplayDuration));

    overlayEntry.remove();
  }

// Only numbers can be entered
  static List<TextInputFormatter> allowOnlyDigits() =>
      <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

  //
  static Future<dynamic> showBottomSheet({
    required final BuildContext context,
    required final Widget child,
    final Color? backgroundColor,
    final bool? enableDrag,
    final bool? isScrollControlled,
    final bool? useSafeArea,
  }) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      isScrollControlled: isScrollControlled ?? true,
      useSafeArea: useSafeArea ?? false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusOf20),
          topRight: Radius.circular(borderRadiusOf20),
        ),
      ),
      context: context,
      builder: (final _) {
        //using backdropFilter to blur the background screen
        //while bottomSheet is open
        return BackdropFilter(filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), child: child);
      },
    );

    return result;
  }

  static Widget getBackArrow(BuildContext context, {VoidCallback? onTap}) {
    return CustomInkWellContainer(
      onTap: () {
        if (onTap != null) {
          onTap.call();
        } else {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: CustomSvgPicture(
            svgImage: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
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
          ),
        ),
      ),
    );
  }

  static AppBar getSimpleAppBar({
    required final BuildContext context,
    required final String title,
    final Color? backgroundColor,
    final bool? centerTitle,
    final bool? isLeadingIconEnable,
    final double? elevation,
    final List<Widget>? actions,
    final FontWeight? fontWeight,
    final double? fontSize,
  }) =>
      AppBar(
        surfaceTintColor: context.colorScheme.secondaryColor,
        systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
        leading: isLeadingIconEnable ?? true ? getBackArrow(context) : const CustomSizedBox(),
        title: CustomText(
          title,
          color: context.colorScheme.blackColor,
          fontWeight: fontWeight,
          fontSize: fontSize,
        ),
        centerTitle: centerTitle ?? false,
        elevation: elevation ?? 0.0,
        backgroundColor: backgroundColor ?? context.colorScheme.secondaryColor,
        actions: actions ?? [],
      );

  static SystemUiOverlayStyle getSystemUiOverlayStyle({required final BuildContext context}) =>
      SystemUiOverlayStyle(
        statusBarColor: context.colorScheme.secondaryColor,
        systemNavigationBarColor: context.colorScheme.secondaryColor,
        systemNavigationBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
            ? Brightness.light
            : Brightness.dark,
      );

  static void removeFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<bool> clearUserData() async {
    try {
      final String? latitude = HiveRepository.getLatitude;
      final String? longitude = HiveRepository.getLongitude;
      final String? currentLocationName = HiveRepository.getLocationName;

      //
      await FirebaseAuth.instance.signOut();

      HiveRepository.setUserLoggedIn = false;

      await HiveRepository.clearBoxValues(boxName: HiveRepository.userDetailBoxKey);

      //we will store latitude,longitude and location name to fetch data based on latitude and longitude

      HiveRepository.setLongitude = longitude;
      HiveRepository.setLatitude = latitude;
      HiveRepository.setLocationName = currentLocationName;

      NotificationService.disposeListeners();
      //
      return true;
    } catch (e) {
      return false;
    }
  }

  static Color getBookingStatusColor({required final String statusVal}) {
    switch (statusVal) {
      case "awaiting":
        return AppColors.awaitingOrderColor;

      case "confirmed":
        return AppColors.confirmedOrderColor;

      case "started":
        return AppColors.startedOrderColor;

      case "rescheduled": //Rescheduled
        return AppColors.rescheduledOrderColor;

      case "cancelled" || "cancel": //Cancelled
        return AppColors.cancelledOrderColor;

      case "completed":
        return AppColors.completedOrderColor;

      default:
        return AppColors.redColor;
    }
  }

  static Color getPaymentStatusColor({required String paymentStatus}) {
    switch (paymentStatus) {
      case "pending":
        return AppColors.pendingPaymentStatusColor;
      case "failed":
        return AppColors.failedPaymentStatusColor;
      case "success":
        return AppColors.successPaymentStatusColor;
      default:
        return AppColors.pendingPaymentStatusColor;
    }
  }

  static Future<void> getVibrationEffect() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 100);
    }
  }

  static Future<void> showAnimatedDialog(
      {required BuildContext context, required Widget child}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (final context, final animation, final secondaryAnimation) =>
          const CustomSizedBox(),
      transitionBuilder: (final context, final animation, final secondaryAnimation, Widget _) =>
          Transform.scale(
        scale: Curves.easeInOut.transform(animation.value),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusOf10)),
            child: child,
          ),
        ),
      ),
    );
  }

  static String formatTimeWithDateTime(
    DateTime dateTime,
  ) {
    if (dateAndTimeSetting["use24HourFormat"]) {
      return DateFormat("kk:mm").format(dateTime);
    } else {
      return DateFormat("hh:mm a").format(dateTime);
    }
  }

  static Future<void> downloadOrShareFile({
    required String url,
    String? customFileName,
    required bool isDownload,
  }) async {
    try {
      String downloadFilePath = isDownload
          ? (await getApplicationDocumentsDirectory()).path
          : (await getTemporaryDirectory()).path;

      downloadFilePath =
          "$downloadFilePath/${customFileName != null ? customFileName : DateTime.now().toIso8601String()}";

      if (await File(downloadFilePath).exists()) {
        if (isDownload) {
          OpenFilex.open(downloadFilePath);
        } else {
          Share.shareXFiles([XFile(downloadFilePath)]);
        }
        return;
      }

      var httpClient = HttpClient();
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);

      await File(downloadFilePath).writeAsBytes(
        bytes,
        flush: !isDownload,
      );
      if (isDownload) {
        OpenFilex.open(downloadFilePath);
      } else {
        Share.shareXFiles([XFile(downloadFilePath)]);
      }
    } catch (_) {}
  }
}
