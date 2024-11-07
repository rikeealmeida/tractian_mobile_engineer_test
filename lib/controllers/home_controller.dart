import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/models/company_unity_model.dart';

import '../services/http.dart';

class HomeController extends ValueNotifier<List<CompanyUnityModel>> {
  HomeController() : super([]);

  bool isLoading = (false);
  bool isEmpty = (false);
  bool haveError = (false);
  String errorMsg = ('');

  void getData() async {
    isLoading = true;
    haveError = false;
    notifyListeners();
    try {
      var unties = await getCompanyUnities();
      if (unties.isEmpty) {
        isEmpty = true;
        notifyListeners();
        return;
      }
      value = await getCompanyUnities();
    } catch (e) {
      haveError = true;
      errorMsg = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
