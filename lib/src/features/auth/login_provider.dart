import 'dart:convert';
import 'dart:io';
import 'package:cash_pendency/src/helper/api.dart';
import 'package:cash_pendency/src/helper/hive_localstorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class LoginProvider extends ChangeNotifier {
  bool isLoading = false;

  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<String> Login(
    String deviceId,
    String deviceName,
    String deviceVersion,
  ) async {
    try {
      Map<String, String> body = {
        'username': emailController.text,
        'password': passwordController.text,
        'device_id': deviceId,
        'device_name': deviceName,
        'version': deviceVersion,
        'os': Platform.isAndroid ? 'android' : 'ios',
      };

      print('body : $body');

      var respone = await post(
        Uri.parse('$finalUrl/auth/login'),
        body: body,
        headers: {'Accept': 'application/json'},
      );

      var data = jsonDecode(respone.body.toString());

      print('data : $data');
      print('respone.statusCode : ${respone.statusCode}');

      if (respone.statusCode == 200) {
        Auth.email = emailController.text;
        Auth.accestoken = data['data']['token'];

        print('token : ${Auth.accestoken}');

        storeUserData(Auth.email!, '', Auth.accestoken!);

        return 'true';
      } else {
        if (respone.statusCode != 200) {
          return data['message'];
        }
        return 'false';
      }
    } catch (e) {
      print('Error: $e');
      return 'false';
    }
  }
}
