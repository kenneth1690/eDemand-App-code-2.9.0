import 'package:e_demand/app/generalImports.dart';

const String appName = "Kimii Servicios";

// domainURL should look like:- https://your_domain.in
const String domainURL = "https://panel.kimiiservicios.com";

//Add your baseURL
const String baseUrl = "https://panel.kimiiservicios.com/api/v1/";

//place API key need for place searches
const String placeAPIKey = 'AIzaSyAL1ZrNCsfbRSxF51BW9xY-j6CuQGNHyU0';

const bool isDemoMode = false;

//*******Add Your Language code and name here */
//by default language of the app
const String defaultLanguageCode = "es";
const String defaultLanguageName = "Spanish";

//add your default country code here
///https://www.att.com/support_media/images/pdf/Country_Code_List.pdf
String defaultCountryCode = "CR";

//if you do not want user to select another country rather than default country,
//then make below variable true
bool allowOnlySingleCountry = false;

const int resendOTPCountDownTime = 30; //in seconds

//OTP hint CustomText
const String otpHintText = "123456"; /* MUST BE 6 CHARACTER REQUIRED */

Map<String, dynamic> dateAndTimeSetting = {"dateFormat": "dd/MM/yyyy", "use24HourFormat": false};

//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
const List<AppLanguage> appLanguages = [
  //Please add language code here and language name
  AppLanguage(languageCode: "es", languageName: "Spanish", imageURL: AppAssets.englishAu),
  AppLanguage(languageCode: "en", languageName: "English", imageURL: AppAssets.englishAu),
  AppLanguage(languageCode: "hi", languageName: "हिन्दी", imageURL: AppAssets.hindi),
  AppLanguage(languageCode: "ar", languageName: "عربى", imageURL: AppAssets.arabic),
];

//slider on home screen
const Map sliderAnimationDurationSettings = {
  "sliderAnimationDuration": 3000, // in milliseconds
  "changeSliderAnimationDuration": 300, //in milliseconds
};

/* INTRO SLIDER LIST*/
List<IntroScreen> introScreenList = [
  IntroScreen(
    introScreenTitle: "onboarding_heading_one",
    introScreenSubTitle: "onboarding_body_one",
    imagePath: AppAssets.introSliderImageFirst,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_two",
    introScreenSubTitle: "onboarding_body_two",
    imagePath: AppAssets.introSliderImageSecond,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_three",
    introScreenSubTitle: "onboarding_body_three",
    imagePath: AppAssets.introSliderImageThird,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_four",
    introScreenSubTitle: "onboarding_body_four",
    imagePath: AppAssets.introSliderImageFourth,
    animationDuration: 3, /* DURATION IS IN SECONDS*/
  ),
];

enum LogInType { google, apple, phone }
