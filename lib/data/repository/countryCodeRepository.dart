import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/model/countryCodeModel.dart';
import 'package:flutter/material.dart';

class CountryCodeRepository {


   Future<List<CountryCodeModel>> getCountries(BuildContext context) async {
    final String rawData = await rootBundle.loadString(
        'assets/countryCodes/countryCodes.json');
    final parsed = json.decode(rawData.toString()).cast<Map<String, dynamic>>();
    return parsed.map<CountryCodeModel>((json) =>  CountryCodeModel.fromJson(json)).toList();
  }


   Future<CountryCodeModel> getCountryByCountryCode(
      BuildContext context, String countryCode) async {
    final list = await getCountries(context);
    return list.firstWhere((element) => element.countryCode == countryCode);
  }


}
