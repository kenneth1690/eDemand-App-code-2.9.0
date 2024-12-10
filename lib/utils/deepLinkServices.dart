import 'package:app_links/app_links.dart';
import 'package:e_demand/app/generalImports.dart';

class AppLinksDeepLink {
  AppLinksDeepLink._privateConstructor();

  static final AppLinksDeepLink _instance = AppLinksDeepLink._privateConstructor();

  static AppLinksDeepLink get instance => _instance;

  AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void onInit() {
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uriValue) {
        if (uriValue.toString().startsWith(domainURL) ) {

          UiUtils.rootNavigatorKey.currentState?.pushNamed(providerRoute,
              arguments: {"providerId": uriValue.toString().split("/").last});
        }
      },
      onError: (err) {},
      onDone: () {
        _linkSubscription?.cancel();
      },
    );
  }
}
