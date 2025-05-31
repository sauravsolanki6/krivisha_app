import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:krivisha_app/core/urls.dart';
import 'package:krivisha_app/view/transport/own_vehicle_list.dart';
import 'dart:convert';

import '../../core/network/exceptions.dart';
import '../../model/transport/city_dropdown_model.dart';
import '../../model/transport/vehicle_dropdown_model.dart';
import '../../utility/app_routes.dart';
import '../../utility/utils.dart';
import '../../view/progressdialog.dart';

class VehicleController extends GetxController {
  // Reactive list of vehicles
  final RxList<Vehicle> vehicles = <Vehicle>[].obs;
  // Reactive selected vehicle
  Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);

  // Loading state
  RxBool isLoading = false.obs;
  RxBool isLoadingv = false.obs;
  RxBool isLoadingc = false.obs;
  RxBool isLoadingup = false.obs;
  // Error message
  final RxString errorMessagev = ''.obs;
  final RxString errorMessagec = ''.obs;
  final RxList<AllCity> cities = <AllCity>[].obs;
  // Reactive selected vehicle
  Rx<AllCity?> selectedCity = Rx<AllCity?>(null);

  @override
  void onInit() {
    super.onInit();

    fetchVehicles();
    fetchCities();
  }

  // Fetch vehicles from the API and map to List<Vehicle>
  Future<void> fetchVehicles() async {
    try {
      isLoadingv.value = true;
      errorMessagev.value = '';

      final response = await http.post(Uri.parse(Networkutility.getallVehicle));
      log("${response.body}");
      if (response.statusCode == 200) {
        // Parse JSON and map to List<Vehicle>
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<dynamic> data = jsonData['data'];
        if (jsonData['status'] == 'true') {
          vehicles.assignAll(
            data.map((json) => Vehicle.fromJson(json)).toList(),
          );
        }
        update();
      } else {
        errorMessagev.value = 'Failed to load vehicles: ${response.statusCode}';
      }
    } catch (e) {
      errorMessagev.value = 'Error fetching vehicles: $e';
    } finally {
      isLoadingv.value = false;
    }
  }

  // Update selected vehicle and navigate back after delay
  void setSelectedVehicle(Vehicle? value) {
    selectedVehicle.value = value;
    // if (value != null) {
    //   // Trigger delayed navigation
    //   navigateBackAfterDelay();
    // }
    update();
  }

  // Delayed navigation
  Future<void> navigateBackAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.back();
  }

  // Validator for the dropdown
  String? validateVehicle(Vehicle? value) {
    return value == null ? 'Please select a vehicle' : null;
  }

  Future<void> fetchCities() async {
    try {
      isLoadingc.value = true;
      errorMessagec.value = '';

      final response = await http.post(
        Uri.parse(Networkutility.getallLocations),
      );
      log("${response.body}");
      if (response.statusCode == 200) {
        // Parse JSON and map to List<Vehicle>
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<dynamic> data = jsonData['data'];
        if (jsonData['status'] == 'true') {
          cities.assignAll(data.map((json) => AllCity.fromJson(json)).toList());
        }
        update();
      } else {
        errorMessagec.value = 'Failed to load vehicles: ${response.statusCode}';
      }
    } catch (e) {
      errorMessagec.value = 'Error fetching vehicles: $e';
    } finally {
      isLoadingc.value = false;
    }
  }

  // Update selected vehicle and navigate back after delay
  void setSelectedCity(AllCity? value) {
    selectedCity.value = value;
    // if (value != null) {
    //   // Trigger delayed navigation
    //   navigateBackAfterDelay();
    // }
    update();
  }

  // Delayed navigation

  // Validator for the dropdown
  String? validateCity(AllCity? value) {
    return value == null ? 'Please select a vehicle' : null;
  }

  Future<void> addOwnvehicle(
    BuildContext context, {

    required vehicleID,
    required challan,
    required invNum,
    required locationID,
    required pincode,
    required List<String> purpose,
    required partyID,
    required km,
    required marketfreight,
    required diesel,
    required driverexp,
    required maintenance,
  }) async {
    try {
      log("called");
      isLoading.value = true;
      ProgressDialog.showProgressDialog(context);
      Get.back();
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      final jsonBody = {
        "vehical_id": vehicleID,
        "challan_dc_no": challan,
        "invoice_no": invNum,
        "location_id": locationID,
        "pincode": pincode,
        "purpose": purpose,
        "party_id": partyID,
        "in_km": km,
        "market_freight": marketfreight,
        "diesel_topup": diesel,
        "driver_expense": driverexp,
        "maintenance": maintenance,
      };
      final response = await http.post(
        Uri.parse(Networkutility.setOwnvehicle),
        body: jsonEncode(jsonBody),
      );
      log("Url ${Networkutility.setOwnvehicle}");
      log("req Body $jsonBody");
      log("response Body ${response.body}");
      if (response.statusCode == 200) {
        var decodeData = jsonDecode(response.body);
        Map<String, dynamic> res = decodeData;
        if (decodeData['status'] == "true") {
          Utils.flushBarErrorMessage("${res['message']}", context, status: "s");

          // await Future.delayed(Duration(seconds: 3));

          Get.to(OwnVehicleList());
          // Get.back();
        } else {
          Get.back();
          Utils.flushBarErrorMessage(
            'Error: ${decodeData['message']}',
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
      isLoading.value = false;
    }
  }

  Future<void> updateOwnvehicle(
    BuildContext context, {

    required updateID,
    required vehicleID,
    required challan,
    required invNum,
    required locationID,
    required pincode,
    required List<String> purpose,
    required partyID,
    required km,
    required marketfreight,
    required diesel,
    required driverexp,
    required maintenance,
  }) async {
    try {
      log("called");
      isLoadingup.value = true;
      // ProgressDialog.showProgressDialog(context);
      // Get.back();
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      final jsonBody = {
        "update_id": updateID,
        "vehical_id": vehicleID,
        "challan_dc_no": challan,
        "invoice_no": invNum,
        "location_id": locationID,
        "pincode": pincode,
        "purpose": purpose,
        "party_id": partyID,
        "in_km": km,
        "market_freight": marketfreight,
        "diesel_topup": diesel,
        "driver_expense": driverexp,
        "maintenance": maintenance,
      };
      final response = await http.post(
        Uri.parse(Networkutility.setOwnvehicle),
        body: jsonEncode(jsonBody),
      );
      log("Url ${Networkutility.setOwnvehicle}");
      log("req Body $jsonBody");
      log("response Body ${response.body}");
      if (response.statusCode == 200) {
        var decodeData = jsonDecode(response.body);
        Map<String, dynamic> res = decodeData;
        if (decodeData['status'] == "true") {
          Utils.flushBarErrorMessage("${res['message']}", context, status: "s");

          // await Future.delayed(Duration(seconds: 3));

        //Get.offNamed(AppRoutes.ownvehicleList);
          // Get.back();
        } else {
          Get.back();
          Utils.flushBarErrorMessage(
            'Error: ${decodeData['message']}',
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
      isLoadingup.value = false;
    }
  }
}
