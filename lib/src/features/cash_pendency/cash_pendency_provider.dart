import 'dart:convert';
import 'package:cash_pendency/src/features/modal/compnay_modal.dart';
import 'package:cash_pendency/src/features/modal/pendency_modal.dart';
import 'package:cash_pendency/src/features/modal/state_modal.dart';
import 'package:cash_pendency/src/helper/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CashPendencyProvider extends ChangeNotifier {
  bool isLaoding = false;

  setLoading(bool value) {
    isLaoding = value;
    notifyListeners();
  }

  List<CompanyModal> companyList = [];

  Future<void> getCompany() async {
    setLoading(true);
    try {
      var response = await post(
        Uri.parse('$finalUrl/dropdown/company'),
        headers: Auth.commonHeader,
      );
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        companyList = (data['data'] as List)
            .map((item) => CompanyModal.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error in getCompany: $e');
    }
    setLoading(false);
  }

  List<StateModal> stateList = [];

  Future<void> getState() async {
    setLoading(true);
    try {
      var response = await post(
        Uri.parse('$finalUrl/dropdown/state'),
        headers: Auth.commonHeader,
      );
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        stateList = (data['data']['items'] as List)
            .map((item) => StateModal.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error in getState: $e');
    }
    setLoading(false);
  }

  List<CashPendencyModal> cashPendencyList = [];

  Future<String> getCashPendencyGroupReport(
    String? pendencyDate,
    String? searchBy,
    String? companyId,
    List<String>? stateIds,
  ) async {
    setLoading(true);

    try {
      Map<String, dynamic> body = {
        'pendency_date': pendencyDate,
        'company_id': companyId,
        'srchby': searchBy,
      };

      if (stateIds != null && stateIds.isNotEmpty) {
        for (int i = 0; i < stateIds.length; i++) {
          body['state_id[$i]'] = stateIds[i];
        }
      }

      print('body : $body');

      var response = await post(
        Uri.parse('$finalUrl/report/cash-pendency-group-report'),
        headers: {
          'Authorization': 'Bearer ${Auth.accestoken}',
          'Accept': 'application/json',
        },
        body: body,
      );

      var data = jsonDecode(response.body);

      print('data : $data');
      print('response.statusCode : ${response.statusCode}');

      if (response.statusCode == 200) {
        cashPendencyList = (data['data'] as List)
            .map((item) => CashPendencyModal.fromJson(item))
            .toList();
        print('cashPendencyList : ${cashPendencyList.length}');
        setLoading(false);
        return 'true';
      } else {
        setLoading(false);
        return 'false';
      }
    } catch (e) {
      print('Error in getCashPendencyGroupReport: $e');
      setLoading(false);
      return 'false';
    }
  }
}
