import 'package:e_demand/app/generalImports.dart';

abstract class SystemSettingState {}

class SystemSettingFetchInitial extends SystemSettingState {}

class SystemSettingFetchInProgress extends SystemSettingState {}

class SystemSettingFetchSuccess extends SystemSettingState {
  SystemSettingFetchSuccess({required this.systemSettingDetails});

  final SystemSettingsModel systemSettingDetails;
}

class SystemSettingFetchFailure extends SystemSettingState {
  SystemSettingFetchFailure({required this.errorMessage});

  final dynamic errorMessage;
}

class SystemSettingCubit extends Cubit<SystemSettingState> {
  SystemSettingCubit({required this.settingRepository}) : super(SystemSettingFetchInitial());
  SettingRepository settingRepository = SettingRepository();

  void getSystemSettings() {
    emit(SystemSettingFetchInProgress());
    settingRepository.getSystemSetting().then((final SystemSettingsModel value) {
      emit(SystemSettingFetchSuccess(systemSettingDetails: value));
    }).catchError((final error) {
      emit(SystemSettingFetchFailure(errorMessage: error.toString()));
    });
  }

  Map<String, dynamic> getSystemCurrencyDetails() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting!;
      return {
        "currencySymbol": appSetting.currency,
        "currencyCountryCode": appSetting.countryCurrencyCode,
        "decimalPoints": appSetting.decimalPoint
      };
    }
    return {"currencySymbol": r"$", "currencyCountryCode": "usd", "decimalPoints": "0"};
  }

  Map<String, String> getApplicationVersionDetails() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting!;

      return {
        "androidVersion": appSetting.customerCurrentVersionAndroidApp.toString(),
        "iOSVersion": appSetting.customerCurrentVersionIosApp.toString(),
      };
    }
    return {
      "androidVersion": "1.0.0",
      "iOSVersion": "1.0.0",
    };
  }

  PaymentGatewaysSettings getPaymentMethodSettings() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess).systemSettingDetails.paymentGatewaysSettings!;
    }
    return PaymentGatewaysSettings();
  }

  String getPrivacyPolicy() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .customerPrivacyPolicy!
          .customerPrivacyPolicy!;
    }
    return "";
  }

  String getTermCondition() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
          .systemSettingDetails
          .customerTermsConditions!
          .customerTermsConditions!;
    }
    return "";
  }

  String getAboutUs() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess).systemSettingDetails.aboutUs!.aboutUs!;
    }
    return "";
  }

  String getContactUs() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess).systemSettingDetails.contactUs!.contactUS!;
    }
    return "";
  }

  bool isOTPSystemEnabled() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
              .systemSettingDetails
              .generalSettings
              ?.isOTPSystemEnable ==
          "1";
    }
    return false;
  }

  bool showProviderAddressDetails() {
    if (state is SystemSettingFetchSuccess) {
      return (state as SystemSettingFetchSuccess)
              .systemSettingDetails
              .generalSettings
              ?.showProviderAddress ==
          "1";
    }
    return false;
  }

  String getCustomerAppURL() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting? appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting;
      return Platform.isAndroid
          ? appSetting!.customerAppPlayStoreURL ?? ''
          : appSetting!.customerAppAppStoreURL ?? '';
    }
    return "";
  }

  String getProviderAppURL() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting? appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting;
      return Platform.isAndroid
          ? appSetting!.providerAppPlayStoreURL ?? ''
          : appSetting!.providerAppAppStoreURL ?? '';
    }
    return "";
  }

  Map<String, dynamic> getContactUsDetails() {
    if (state is SystemSettingFetchSuccess) {
      final GeneralSettings? generalSettings =
          (state as SystemSettingFetchSuccess).systemSettingDetails.generalSettings;

      return {
        "email": generalSettings?.supportEmail ?? "",
        "mobile": generalSettings?.phone ?? "",
        "address": generalSettings?.address ?? "",
        "supportHours": generalSettings?.supportHours ?? "",
      };
    }
    return {};
  }

  List<SocialMediaURL>? getSocialMediaLinks() {
    if (state is SystemSettingFetchSuccess) {
      final List<SocialMediaURL>? socialMedia =
          (state as SystemSettingFetchSuccess).systemSettingDetails.socialMediaURLs;

      return socialMedia;
    }
    return [];
  }

  bool isDemoModeEnabled() {
    if (state is SystemSettingFetchSuccess) {
      final GeneralSettings? appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.generalSettings;
      return appSetting?.isDemoModeEnabled ?? false;
    }
    return false;
  }

  bool isAdEnabled() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting? appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting;
      if (Platform.isAndroid) {
        return appSetting?.isAndroidAdEnabled == "1";
      } else if (Platform.isIOS) {
        return appSetting?.isIosAdEnabled == "1";
      }
      return false;
    }
    return false;
  }

//

  String getBannerAdId() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting? appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting;
      if (Platform.isAndroid) {
        return appSetting?.androidBannerId ?? "";
      } else if (Platform.isIOS) {
        return appSetting?.iosBannerId ?? "";
      }
    }
    return "";
  }

//
  String getInterstitialAdId() {
    if (state is SystemSettingFetchSuccess) {
      final AppSetting? appSetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.appSetting;
      if (Platform.isAndroid) {
        return appSetting?.androidInterstitialId ?? "";
      } else if (Platform.isIOS) {
        return appSetting?.iosInterstitialId ?? "";
      }
    }
    return "";
  }

//

  bool isMoreThanOnePaymentGatewayEnabled() {
    int paymentGatewayCount = 0;
    if (state is SystemSettingFetchSuccess) {
      final PaymentGatewaysSettings? paymentGatewaySetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.paymentGatewaysSettings;
      if (paymentGatewaySetting?.paystackStatus == "enable") {
        paymentGatewayCount++;
      }
      if (paymentGatewaySetting?.razorpayApiStatus == "enable") {
        paymentGatewayCount++;
      }
      if (paymentGatewaySetting?.paypalStatus == "enable") {
        paymentGatewayCount++;
      }
      if (paymentGatewaySetting?.stripeStatus == "enable") {
        paymentGatewayCount++;
      }
      if (paymentGatewaySetting?.isFlutterwaveEnable == "enable") {
        paymentGatewayCount++;
      }
      return paymentGatewayCount > 1;
    }
    return false;
  }

  List<Map<String, dynamic>> getEnabledPaymentMethods({required bool isPayLaterAllowed}) {
    if (state is SystemSettingFetchSuccess) {
      final PaymentGatewaysSettings? paymentGatewaySetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.paymentGatewaysSettings;

      ///title will be shown in radio button
      ///description will be shown in radio button under title (conditional based on deliverable option)
      ///optionDescription will be shown in radio button under title (conditional based on deliverable option)
      ///image will be shown in radio button (icon)
      ///isEnabled will be shown in radio button (if enabled then only give option to select)
      ///paymentType will be used to identify the payment method (this type will be used in placeOrder)
      final List<Map<String, dynamic>> paymentMethods = [
        {
          "title": 'payNow',
          "description": 'payOnlineNow',
          "optionDescription": "payOnlineNow",
          "image": AppAssets.card,
          "isEnabled": !isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": getSingleEnabledPaymentMethod(),
        },
        {
          "title": 'paypal',
          "description": 'payOnlineNowUsingPaypal',
          "optionDescription": "payOnlineNowUsingPaypal",
          "image": AppAssets.paypal,
          "isEnabled": paymentGatewaySetting?.paypalStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "paypal"
        },
        {
          "title": 'razorpay',
          "description": 'payOnlineNowUsingRazorpay',
          "optionDescription": "payOnlineNowUsingRazorpay",
          "image": AppAssets.razorpay,
          "isEnabled": paymentGatewaySetting?.razorpayApiStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "razorpay"
        },
        {
          "title": 'paystack',
          "description": 'payOnlineNowUsingPaystack',
          "optionDescription": "payOnlineNowUsingPaystack",
          "image": AppAssets.paystack,
          "isEnabled": paymentGatewaySetting?.paystackStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "paystack"
        },
        {
          "title": 'stripe',
          "description": 'payOnlineNowUsingStripe',
          "optionDescription": "payOnlineNowUsingStripe",
          "image": AppAssets.stripe,
          "isEnabled": paymentGatewaySetting?.stripeStatus == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "stripe"
        },
        {
          "title": 'flutterwave',
          "description": 'payOnlineNowUsingFlutterwave',
          "optionDescription": "payOnlineNowUsingFlutterwave",
          "image": AppAssets.flutterwave,
          "isEnabled": paymentGatewaySetting?.isFlutterwaveEnable == "enable" &&
              isMoreThanOnePaymentGatewayEnabled(),
          "paymentType": "flutterwave"
        },
        {
          "title": 'payOnService',
          "description": 'payWithServiceAtYourHome',
          "optionDescription": "payWithServiceAtStore",
          "image": AppAssets.cod,
          'isEnabled': isPayLaterAllowed,
          "paymentType": "cod",
        },
      ];

      paymentMethods.removeWhere((element) => !element["isEnabled"]);
      return paymentMethods;
    }
    return [];
  }

  String getSingleEnabledPaymentMethod() {
    String selectedPaymentMethod = "";
    if (state is SystemSettingFetchSuccess) {
      final PaymentGatewaysSettings? paymentGatewaySetting =
          (state as SystemSettingFetchSuccess).systemSettingDetails.paymentGatewaysSettings;
      if (paymentGatewaySetting?.stripeStatus == "enable") {
        selectedPaymentMethod = "stripe";
      } else if (paymentGatewaySetting?.razorpayApiStatus == "enable") {
        selectedPaymentMethod = "razorpay";
      } else if (paymentGatewaySetting?.paystackStatus == "enable") {
        selectedPaymentMethod = "paystack";
      } else if (paymentGatewaySetting?.paypalStatus == "enable") {
        selectedPaymentMethod = "paypal";
      } else if (paymentGatewaySetting?.isFlutterwaveEnable == "enable") {
        selectedPaymentMethod = "flutterwave";
      }
    }
    return selectedPaymentMethod;
  }
}

enum TypesOfAppURLs {
  customerAppPlaystoreURL,
  customerAppAppstoreURL,
  providerAppPlaystoreURL,
  providerAppAppstoreURL,
}
