import 'package:e_demand/app/generalImports.dart';
import "package:flutter/material.dart";

Future<void> initApp() async {
  //

  //
  WidgetsFlutterBinding.ensureInitialized();

  //locked in portrait mode only
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  //

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  //
  //FirebaseMessaging.onBackgroundMessage(NotificationService.onBackgroundMessageHandler);
  try {
    await FirebaseMessaging.instance.getToken();
  } catch (_) {}

  await Hive.initFlutter();
  await HiveRepository.init();


  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:  [
          const Icon(
            Icons.error_outline_outlined,
            color: Colors.red,
            size: 100,
          ),
          CustomText( errorDetails.exception.toString(),
          ),
        ],
      ),
    );
  };

  HttpOverrides.global = MyHttpOverrides();


  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (final context) => CountryCodeCubit(),
        ),
        BlocProvider(
          create: (final context) => AuthenticationCubit(),
        ),
        BlocProvider(
          create: (final context) => SendVerificationCodeCubit(),
        ),
        BlocProvider(
          create: (final context) => VerifyOtpCubit(),
        ),
        BlocProvider(
          create: (final context) => CategoryCubit(CategoryRepository()),
        ),
        // BlocProvider(
        //   create: (context) => CountDownCubit(),
        // ),
        BlocProvider(create: (final context) => NotificationsCubit()),
        BlocProvider<AppThemeCubit>(create: (final _) => AppThemeCubit(SettingRepository())),
        BlocProvider(
          create: (final context) => ResendOtpCubit(),
        ),
        BlocProvider(
          create: (final BuildContext context) =>
              SystemSettingCubit(settingRepository: SettingRepository()),
        ),
        BlocProvider(
          create: (final context) => GeolocationCubit(),
        ),

        BlocProvider(
          create: (final context) => LanguageCubit(),
        ),
        BlocProvider<ChangeBookingStatusCubit>(
          create: (final BuildContext context) =>
              ChangeBookingStatusCubit(bookingRepository: BookingRepository()),
        ),
        BlocProvider<DownloadInvoiceCubit>(
          create: (final BuildContext context) => DownloadInvoiceCubit(BookingRepository()),
        ),
        BlocProvider(
          create: (final context) => UserDetailsCubit(),
        ),
        BlocProvider(
          create: (final context) => AddAddressCubit(),
        ),
        BlocProvider(
          create: (final context) => UpdateUserCubit(),
        ),
        BlocProvider(
          create: (final context) => DeleteAddressCubit(),
        ),
        BlocProvider(
          create: (final BuildContext context) => AddressesCubit(),
        ),
        BlocProvider(
          create: (final context) => GooglePlaceAutocompleteCubit(),
        ),
        BlocProvider(
          create: (final context) => SubCategoryAndProviderCubit(
            subCategoryRepository: SubCategoryRepository(),
            providerRepository: ProviderRepository(),
          ),
        ),
        BlocProvider(
          create: (final context) => ProviderCubit(ProviderRepository()),
        ),
        BlocProvider(
          create: (final context) => GetAddressCubit(),
        ),
        BlocProvider(
          create: (final BuildContext context) => ReviewCubit(ReviewRepository()),
        ),
        BlocProvider(
          create: (final context) => BookmarkCubit(BookmarkRepository()),
        ),
        BlocProvider(
          create: (final context) => HomeScreenCubit(HomeScreenRepository()),
        ),
        BlocProvider(
          create: (final context) => BookingCubit(BookingRepository()),
        ),
        BlocProvider(
          create: (final context) => CartCubit(CartRepository()),
        ),
        BlocProvider(
          create: (final context) =>
              CheckIsUserExistsCubit(authenticationRepository: AuthenticationRepository()),
        ),
        BlocProvider<GetPromocodeCubit>(
          create: (final context) => GetPromocodeCubit(cartRepository: CartRepository()),
        ), BlocProvider<GoogleLoginCubit>(
          create: (final context) => GoogleLoginCubit(),
        ),
        BlocProvider<AppleLoginCubit>(
          create: (final context) => AppleLoginCubit(),
        ),
        //chat
        BlocProvider<ChatUsersCubit>(
          create: (context) => ChatUsersCubit(ChatRepository()),
        ),

      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({final Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  //
  //
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((final value) {
      if (HiveRepository.isDarkThemeUsing) {
        context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
      } else {
        context.read<AppThemeCubit>().changeTheme(AppTheme.light);
      }
    });

    context.read<LanguageCubit>().loadCurrentLanguage();
  }

  @override
  Widget build(final BuildContext context) => Builder(
        builder: (final context) {
          final AppTheme currentTheme = context.watch<AppThemeCubit>().state.appTheme;
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (final BuildContext context, final LanguageState languageState) =>
                GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: MaterialApp(

                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: appLanguages
                    .map((final language) =>
                        UiUtils.getLocaleFromLanguageCode(language.languageCode),)
                    .toList(),
                theme: appThemeData[currentTheme],
                title: appName,
                locale: (languageState is LanguageLoader)
                    ? Locale(languageState.languageCode)
                    : const Locale(defaultLanguageCode),
                debugShowCheckedModeBanner: false,
                navigatorKey: UiUtils.rootNavigatorKey,

                onGenerateRoute: Routes.onGeneratedRoute,
                initialRoute: splashRoute,
                builder: (final context, final widget) =>
                    widget!,
              ),
            ),
          );
        },
      );
}

///To remove scroll-glow from the ListView/GridView etc..
class CustomScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
          final BuildContext context, final Widget child, final ScrollableDetails details,) =>
      child;
}

///To apply BouncingScrollPhysics() to every scrollable widget
class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(final BuildContext context) => const BouncingScrollPhysics();
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
