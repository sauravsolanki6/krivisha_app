import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:krivisha_app/utility/app_utility.dart';
import 'package:krivisha_app/utility/utils.dart';

import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';

import '../../response/get_all_departmet_response.dart';
import '../../response/get_all_party_response.dart';
import '../../response/get_employee_according_department.dart';
import '../../response/set_add_task_response.dart';
import '../../utility/app_colors.dart';
import '../../view/progressdialog.dart';

class AddTaskController extends GetxController {
  static AddTaskController get to => Get.find();
  var partys = <AllPartyData>[].obs;
  var departments = <AllDepartments>[].obs;
  var employees = <EmployeeAccordingDepartment>[].obs;
  RxString partyID = "".obs;
  RxString depID = "".obs;
  RxString emploID = "".obs;
  var isLoading = false.obs;
  var isLoadingd = false.obs;
  var isLoadinge = false.obs;
  var isLoadingt = false.obs;

  var errorMessage = ''.obs;
  Map<String, String> partyNameToId = {};
  Map<String, String> departmentNameToId = {};
  Map<String, String> empNameToId = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      doapicall(true, context: Get.context!);
      fetchParty(context: Get.context!, reset: true);
      fetchAllDepartment(context: Get.context!, reset: true);
      developer.log(
        'GlobalDepartmentController initialized',
        name: 'GlobalDepartmentController',
      );
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Get.context != null) {
    //     doapicall(true, context: Get.context!);
    //   } else {
    //     developer.log(
    //       'Context is null in onInit',
    //       name: 'GlobalDepartmentController',
    //     );
    //   }
    // });
  }

  doapicall(bool showprogress, {required BuildContext context}) async {
    if (showprogress) {
      ProgressDialog.showProgressDialog(context);
    }
    await Future.wait([
      fetchAllDepartment(context: context, reset: true),
      fetchParty(context: context, reset: true),

      //  Future.delayed(Duration(minutes: 1)),
    ]);
    if (showprogress) {
      Get.back();
    }
  }

  Future<void> fetchParty({
    required BuildContext context,
    bool reset = false,
    bool forceFetch = false,
  }) async {
    if (!forceFetch && isLoading.value) return;

    try {
      print('function is called');
      isLoading.value = true;
      errorMessage.value = '';
      if (reset) {
        partys.clear();
        partyNameToId.clear();
      }

      final jsonBody = {};

      developer.log(
        'Fetching Party with body: $jsonBody',
        name: 'GlobalDepartmentController',
      );

      List<GetAllPartyResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getAllPartyApi,
                Networkutility.getAllParty,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetAllPartyResponse>?;

      if (response != null && response.isNotEmpty) {
        developer.log(
          'Response received: ${response[0].toJson()}',
          name: 'GlobalPartyController',
        );
        if (response[0].status == "true") {
          partys.addAll(response[0].data);
          for (var party in response[0].data) {
            partyNameToId[party.partyName] = party.id;
          }
          developer.log(
            'Customers updated: ${partys.length}, nameToId: $partyNameToId',
            name: 'GlobalPartyController',
          );
        } else {
          errorMessage.value = response[0].message;
          developer.log(
            'Error in response: ${response[0].message}',
            name: 'GlobalPartyController',
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        developer.log('No response from server', name: 'GlobalPartyController');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'NoInternetException: ${e.message}',
        name: 'GlobalPartyController',
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'TimeoutException: ${e.message}',
        name: 'GlobalPartyController',
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      developer.log(
        'HttpException: ${e.message}',
        name: 'GlobalPartyController',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'ParseException: ${e.message}',
        name: 'GlobalPartyController',
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      developer.log('Unexpected error: $e', name: 'GlobalPartyController');
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getPartyNames() {
    final names = partys.map((party) => party.partyName).toList();
    developer.log(
      'Returning Party names: $names',
      name: 'GlobalPartyController',
    );
    return names;
  }

  String getPartyIdByName(String name) {
    final id = partyNameToId[name] ?? '';
    partyID.value = id;
    developer.log(
      'Getting ID for name $name: $id',
      name: 'GlobalPartyController',
    );

    return id;
  }

  Future<void> fetchAllDepartment({
    required BuildContext context,
    bool reset = false,
    bool forceFetch = false,
  }) async {
    if (!forceFetch && isLoading.value) return;

    try {
      isLoadingd.value = true;
      errorMessage.value = '';
      if (reset) {
        employees.clear();
        departmentNameToId.clear();
      }

      final jsonBody = {};

      developer.log(
        'Fetching Party with body: $jsonBody',
        name: 'GlobalDepartmentController',
      );

      List<GetAllDepartmentResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getAllDepartmentApi,
                Networkutility.getAllDepartment,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetAllDepartmentResponse>?;
      log("$response");
      if (response != null && response.isNotEmpty) {
        developer.log(
          'Response received: ${response[0].toJson()}',
          name: 'GlobalDepartmentController',
        );
        if (response[0].status == "true") {
          departments.addAll(response[0].data);
          for (var dp in response[0].data) {
            departmentNameToId[dp.department] = dp.id;
          }
          developer.log(
            'Customers updated: ${partys.length}, nameToId: $departmentNameToId',
            name: 'GlobalDepartmentController',
          );
        } else {
          errorMessage.value = response[0].message;
          developer.log(
            'Error in response: ${response[0].message}',
            name: 'GlobalDepartmentController',
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        developer.log(
          'No response from server',
          name: 'GlobalDepartmentController',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'NoInternetException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'TimeoutException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      developer.log(
        'HttpException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'ParseException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      developer.log('Unexpected error: $e', name: 'GlobalDepartmentController');
    } finally {
      isLoadingd.value = false;
    }
  }

  List<String> getDepartmentNames() {
    final names = departments.map((dp) => dp.department).toList();
    developer.log(
      'Returning department names: $names',
      name: 'GlobalDepartmentController',
    );
    return names;
  }

  String getDepartmentIdByName(String name) {
    final id = departmentNameToId[name] ?? '';
    depID.value = id;
    developer.log(
      'Getting ID for name $name: $id',
      name: 'GlobalDepartmentController',
    );
    update();
    return id;
  }

  Future<void> fetchEmployees({
    required BuildContext context,
    bool reset = false,
    bool forceFetch = false,
    required id,
  }) async {
    if (!forceFetch && isLoading.value) return;

    try {
      isLoadinge.value = true;
      errorMessage.value = '';
      if (reset) {
        employees.clear();
        empNameToId.clear();
      }

      final jsonBody = {"department_id": id};

      developer.log(
        'Fetching Party with body: $jsonBody',
        name: 'GlobalDepartmentController',
      );

      List<GetEmployeeAccordingDepartmentResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getEmployeeAccordingDepartmenttApi,
                Networkutility.getEmployeeAccordingDepartment,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetEmployeeAccordingDepartmentResponse>?;
      log("$response");
      if (response != null && response.isNotEmpty) {
        developer.log(
          'Response received: ${response[0].toJson()}',
          name: 'GlobalDepartmentController',
        );
        if (response[0].status == "true") {
          employees.addAll(response[0].data);
          for (var emp in response[0].data) {
            empNameToId[emp.firstName] = emp.id;
          }
          developer.log(
            'Customers updated: ${partys.length}, nameToId: $empNameToId',
            name: 'GlobalDepartmentController',
          );
        } else {
          errorMessage.value = response[0].message;
          developer.log(
            'Error in response: ${response[0].message}',
            name: 'GlobalEmployeeController',
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        developer.log(
          'No response from server',
          name: 'GlobalDepartmentController',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'NoInternetException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'TimeoutException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      developer.log(
        'HttpException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      developer.log(
        'ParseException: ${e.message}',
        name: 'GlobalDepartmentController',
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      developer.log('Unexpected error: $e', name: 'GlobalDepartmentController');
    } finally {
      isLoadinge.value = false;
    }
  }

  List<String> getEmployeeNames() {
    final names = employees.map((emp) => emp.firstName).toList();
    developer.log(
      'Returning department names: $names',
      name: 'GlobalDepartmentController',
    );
    return names;
  }

  String getEmployeeIdByName(String name) {
    final id = empNameToId[name] ?? '';
    emploID.value = id;
    developer.log(
      'Getting ID for name $name: $id',
      name: 'GlobalDepartmentController',
    );

    return id;
  }

  Future<void> AddTask(
    BuildContext context, {
    required taskheadID,
    required partyID,
    required date,
    required time,
    required priorityID,
    required remark,
    required depID,
    required teamID,
  }) async {
    try {
      log("called");
      isLoadingt.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      final jsonBody = {
        "task_head_id": "1",
        "employee_id": AppUtility.empID,
        "party_id": partyID,
        "date": date,
        "time": time,
        "priority": priorityID,
        "remark": remark,
        "department_id": depID,
        "team_member_id": teamID,
      };
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.setManualTaskApi,
        Networkutility.setManualTask,
        jsonEncode(jsonBody),
        context,
      );
      log("Url ${Networkutility.setManualTaskApi}");
      log("req Body $jsonBody");
      log("req Body $list");
      if (list != null && list.isNotEmpty) {
        List<SetAddTaskResponse> response = List.from(list);
        if (response[0].status == "true") {
          final msg = response[0].message;

          Utils.flushBarErrorMessage(
            "Added task successfully!",
            context,
            status: "s",
          );
          await Future.delayed(Duration(seconds: 3));
          Get.back();
        } else {
          Get.back();
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
      Utils.flushBarErrorMessage('Error: ${e.message}', context, status: "e");
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
      isLoadingt.value = false;
    }
  }
}
