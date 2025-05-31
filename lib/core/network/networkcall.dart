import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:krivisha_app/model/login/get_login_response.dart';
import '../../model/login/autoTask_response.dart';
import '../../model/login/task_response.dart';

import '../../model/order/get_all_orderlist_response.dart';
import '../../model/printing/get_printing_list_response.dart';
import '../../model/transport/own_vehicle_response.dart';
import '../../response/get_all_departmet_response.dart';
import '../../response/get_all_party_response.dart';
import '../../response/get_employee_according_department.dart';
import '../../response/set_add_task_response.dart';
import '../network/exceptions.dart';

class Networkcall {
  // final ConnectivityService _connectivityService =
  //     Get.find<ConnectivityService>();
  static GetSnackBar? _slowInternetSnackBar;
  static const int _minResponseTimeMs =
      3000; // Threshold for slow internet (3s)
  static bool _isNavigatingToNoInternet = false; // Prevent multiple navigations

  Future<List<Object?>?> postMethod(
    int requestCode,
    String url,
    String body,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      // final isConnected = await _connectivityService.checkConnectivity();
      // if (!isConnected) {
      //   // await _navigateToNoInternet();
      //   return null;
      // }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make POST request with timeout
      var response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body.isEmpty ? null : body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out. Please try again.');
            },
          );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;
      if (response.statusCode == 200) {
        log("url : $url \n Request body : $body \n Response : $data");

        // Wrap response in [] for consistency
        String str = "[${response.body}]";

        switch (requestCode) {
          case 1:
            final login = loginResponseFromJson(str);
            return login;
          case 2:
            final tasks = taskResponseFromJson(str);
            return tasks;
          case 3:
            final AutoTasks = autoTaskResponseFromJson(str);
            return AutoTasks;
          case 9:
            final allParty = getAllPartyResponseFromJson(str);
            return allParty;
          case 10:
            final allDepartment = getAllDepartmentResponseFromJson(str);
            return allDepartment;
          case 7:
            final employeeAccordingDepartment =
                getEmployeeAccordingDepartmentResponseFromJson(str);
            return employeeAccordingDepartment;
          case 8:
            final setAddTask = setAddTaskResponseFromJson(str);
            return setAddTask;
          case 11:
            final allorderlist = getAllOrderlistResponseFromJson(str);
            return allorderlist;
          case 12:
            final allownvehiclelist = ownvehicleListResponseFromJson(str);
            return allownvehiclelist;
          case 13:
            final allprintinglist = getAllPrintingListResponseFromJson(str);
            return allprintinglist;
          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Request body : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      // await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      Get.snackbar(
        'Request Timed Out',
        'The server took too long to respond. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      //await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    }
  }

  // Future<List<Object?>?> getMethod(
  //   int requestCode,
  //   String url,
  //   BuildContext context,
  // ) async {
  //   try {
  //     // Check connectivity with retries
  //     final isConnected = await _connectivityService.checkConnectivity();
  //     if (!isConnected) {
  //       // await _navigateToNoInternet();
  //       return null;
  //     }

  //     // Start measuring response time
  //     final stopwatch = Stopwatch()..start();

  //     // Make GET request with timeout
  //     var response = await http
  //         .get(Uri.parse(url))
  //         .timeout(
  //           const Duration(seconds: 30),
  //           onTimeout: () {
  //             throw TimeoutException('Request timed out. Please try again.');
  //           },
  //         );

  //     // Stop measuring response time
  //     stopwatch.stop();
  //     final responseTimeMs = stopwatch.elapsedMilliseconds;

  //     // Handle slow internet
  //     _handleSlowInternet(responseTimeMs);

  //     var data = response.body;
  //     log(url);
  //     if (response.statusCode == 200) {
  //       log("url : $url \n Response : $data");
  //       String str = "[${response.body}]";
  //       switch (requestCode) {
  //         case 22:
  //           final getCities = getMaharashtraCityResponseFromJson(str);
  //           return getCities;
  //         default:
  //           log("Invalid request code: $requestCode");
  //           throw ParseException('Unhandled request code: $requestCode');
  //       }
  //     } else {
  //       log("url : $url \n Response : $data");
  //       throw HttpException(
  //         'Server error: ${response.statusCode}',
  //         response.statusCode,
  //       );
  //     }
  //   } on NoInternetException catch (e) {
  //     log("url : $url \n Response : $e");
  //     // await _navigateToNoInternet();
  //     return null;
  //   } on TimeoutException catch (e) {
  //     log("url : $url \n Response : $e");
  //     Get.snackbar(
  //       'Request Timed Out',
  //       'The server took too long to respond. Please try again.',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 3),
  //     );
  //     return null;
  //   } on HttpException catch (e) {
  //     log("url : $url \n Response : $e");
  //     return null;
  //   } on SocketException catch (e) {
  //     log("url : $url \n Response : $e");
  //     // await _navigateToNoInternet();
  //     return null;
  //   } catch (e) {
  //     log("url : $url \n Response : $e");
  //     return null;
  //   }
  // }

  // Future<void> _navigateToNoInternet() async {
  //   if (!_isNavigatingToNoInternet &&
  //       Get.currentRoute != AppRoutes.noInternet) {
  //     _isNavigatingToNoInternet = true;
  //     // Double-check connectivity before navigating
  //     final isConnected = await _connectivityService.checkConnectivity();
  //     if (!isConnected) {
  //       await Get.offNamed(AppRoutes.noInternet);
  //     }
  //     // Reset flag after a delay
  //     await Future.delayed(const Duration(milliseconds: 500));
  //     _isNavigatingToNoInternet = false;
  //   }
  // }

  void _handleSlowInternet(int responseTimeMs) {
    if (responseTimeMs > _minResponseTimeMs) {
      // Show slow internet snackbar if not already shown
      if (_slowInternetSnackBar == null || !Get.isSnackbarOpen) {
        _slowInternetSnackBar = const GetSnackBar(
          message:
              'Slow internet connection detected. Please check your network.',
          duration: Duration(days: 1), // Persistent until closed
          backgroundColor: Colors.orange,
          snackPosition: SnackPosition.TOP,
          isDismissible: false,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
        );
        Get.showSnackbar(_slowInternetSnackBar!);
        
      }
    } else {
      // Close slow internet snackbar if connection improves
      if (_slowInternetSnackBar != null && Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        _slowInternetSnackBar = null;
      }
    }
  }
}
