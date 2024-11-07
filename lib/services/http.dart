import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tractian_mobile_engineer_test/models/company_unity_model.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';

const baseUrl = "https://fake-api.tractian.com";

Future<List<CompanyUnityModel>> getCompanyUnities() async {
  try {
    var response = await http
        .get(
          Uri.parse('$baseUrl/companies'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List;
      return data.map((d) => CompanyUnityModel.fromMap(d)).toList();
    } else {
      throw Exception('Failed to load the Company Unities');
    }
  } on SocketException {
    throw Exception('No Internet connection');
  } on TimeoutException {
    throw Exception('The connection has timed out');
  } catch (e) {
    throw Exception('An unknown error occurred: $e');
  }
}

Future<List<CompanyAssetModel>> getUnitLocations(String id) async {
  try {
    var response = await http
        .get(
          Uri.parse('$baseUrl/companies/$id/locations'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      var data = (jsonDecode(response.body) as List)
          .map((e) => CompanyAssetModel.fromMap(e))
          .toList();
      return data;
    } else {
      throw Exception('Failed to load the Locations');
    }
  } on SocketException {
    throw Exception('No Internet connection');
  } on TimeoutException {
    throw Exception('The connection has timed out');
  } catch (e) {
    throw Exception('An unknown error occurred: $e');
  }
}

Future<List<CompanyAssetModel>> getUnitAssets(String id) async {
  try {
    var response = await http
        .get(
          Uri.parse('$baseUrl/companies/$id/assets'),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      var data = (jsonDecode(response.body) as List)
          .map((e) => CompanyAssetModel.fromMap(e))
          .toList();
      return data;
    } else {
      throw Exception('Failed to load the Locations');
    }
  } on SocketException {
    throw Exception('No Internet connection');
  } on TimeoutException {
    throw Exception('The connection has timed out');
  } catch (e) {
    throw Exception('An unknown error occurred: $e');
  }
}
