import 'package:e_demand/app/generalImports.dart';

class SettingRepository {
  String getCurrentLanguageCode() => 'en';

  Future<void> setCurrentLanguageCode(final String value) async {}

  Future<void> setTheme(final String theme) async {
    //add in hive
  }

  //
  ///This method is used to fetch system settings
  Future<SystemSettingsModel> getSystemSetting() async {
    try {
      final  response =
          await Api.post(url: Api.getSystemSettings, parameter: {}, useAuthToken: false);

      return SystemSettingsModel.fromJson(Map.from(response['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
