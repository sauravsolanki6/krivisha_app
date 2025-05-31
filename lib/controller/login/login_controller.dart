import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:krivisha_app/model/login/get_login_response.dart';
import 'package:krivisha_app/utility/app_routes.dart';
import 'package:krivisha_app/view/progressdialog.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';

import '../../core/urls.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';
import '../../utility/utils.dart';

class LoginController extends GetxController {
  RxString mobileNumber = ''.obs;
  RxString password = ''.obs;
  RxBool isLoading = false.obs;

  Future<void> login(BuildContext context) async {
    try {
      isLoading.value = true;
      ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      final jsonBody = {
        "mobile_number": mobileNumber.value,
        "password": password.value,
      };
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.loginApiUrl,
        jsonEncode(jsonBody),
        context,
      );

      if (list != null && list.isNotEmpty) {
        Get.back();
        List<LoginResponse> response = List.from(list);
        if (response[0].status == "true") {
          final user = response[0].data;
          await AppUtility.setUserInfo(
            user.firstName,
            user.empId,
            user.id,
            user.pushToken,
          );
          Utils.flushBarErrorMessage("Login Successful", context, status: "s");

          // redirect to dashboard
          Get.offNamed(AppRoutes.dashboard);
        } else {
          Utils.flushBarErrorMessage(
            'Error: ${response[0].message}',
            context,
            status: "e",
          );
        }
      } else {
        Get.back();
        Utils.flushBarErrorMessage(
          'Error: No response from server',
          context,
          status: "e",
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Utils.flushBarErrorMessage('Error: ${e.message}', context, status: "e");
    } on TimeoutException catch (e) {
      Get.back();
      Utils.flushBarErrorMessage('Error: ${e.message}', context, status: "e");
    } on HttpException catch (e) {
      Get.back();
      Utils.flushBarErrorMessage(
        'Error: ${e.message} (Code: ${e.statusCode})',
        context,
        status: "e",
      );
    } on ParseException catch (e) {
      Get.back();
      Utils.flushBarErrorMessage('Error: ${e.message}', context, status: "e");
    } catch (e) {
      Get.back();
      Utils.flushBarErrorMessage(
        'Error: Unexpected error: $e',
        context,
        status: "e",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
