import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:krivisha_app/main.dart';
import 'package:krivisha_app/view/dashboard/homeScreen.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpOTPPage extends StatefulWidget {
  final String? mobileNumber;
  const SignUpOTPPage({
    Key? key,
    required this.mobileNumber,
  }) : super(key: key);
  @override
  _SignUpOTPPageState createState() => _SignUpOTPPageState();
}

class _SignUpOTPPageState extends State<SignUpOTPPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final TextEditingController _otpController = TextEditingController();
  String _mobileNumber = '';
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    _getPermissionStatuses();
    _fetchMobileNumber();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceId = prefs.getString('device_id') ?? '';
    });
  }

  Future<void> _fetchMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _mobileNumber = prefs.getString('mobileNumber') ?? '';
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('OTP field is empty'), backgroundColor: Colors.red),
      );
      return;
    }

    // Simulate successful OTP verification without API call
    String otp = _otpController.text;
    // Mock response data with explicit types
    Map<String, dynamic> responseData = {
      'status': true,
      'data': [
        {
          'emp_id': 'EMP123', // String
          'id': 'ID456', // String
          'first_name': 'John', // String
          'country_id': 'C001', // String
          'city_id': 'CT001', // String
          'state_id': 'ST001', // String
        }
      ],
      'message': 'Verification successful'
    };

    bool status = responseData['status'] == true ||
        responseData['status'].toString().toLowerCase() == 'true';

    if (status) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Explicitly cast or ensure string type
      String empId = responseData['data'][0]['emp_id'] as String;
      String id = responseData['data'][0]['id'] as String;
      String name = responseData['data'][0]['first_name'] as String;
      String countryId = responseData['data'][0]['country_id'] as String;
      String cityId = responseData['data'][0]['city_id'] as String;
      String stateId = responseData['data'][0]['state_id'] as String;

      await prefs.setString('emp_id', empId);
      await prefs.setString('id', id);
      await prefs.setString('first_name', name);
      await prefs.setString('country_id', countryId);
      await prefs.setString('city_id', cityId);
      await prefs.setString('state_id', stateId);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(responseData['message'] as String? ?? 'Verification failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceDetails = {};

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceDetails = {
        'device_id': androidInfo.id,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'display': androidInfo.display,
        'hardware': androidInfo.hardware,
        'host': androidInfo.host,
        'manufacturer': androidInfo.manufacturer,
        'model': androidInfo.model,
        'product': androidInfo.product,
        'supported_abis': androidInfo.supportedAbis,
        'tags': androidInfo.tags,
        'type': androidInfo.type,
        'is_physical_device': androidInfo.isPhysicalDevice,
        'android_version': {
          'base_os': androidInfo.version.baseOS,
          'codename': androidInfo.version.codename,
          'incremental': androidInfo.version.incremental,
          'preview_sdk': androidInfo.version.previewSdkInt,
          'release': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'security_patch': androidInfo.version.securityPatch,
        },
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceDetails = {
        'name': iosInfo.name,
        'system_name': iosInfo.systemName,
        'system_version': iosInfo.systemVersion,
        'model': iosInfo.model,
        'localized_model': iosInfo.localizedModel,
        'identifier_for_vendor': iosInfo.identifierForVendor,
        'is_physical_device': iosInfo.isPhysicalDevice,
        'utsname': {
          'sysname': iosInfo.utsname.sysname,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'version': iosInfo.utsname.version,
          'machine': iosInfo.utsname.machine,
        },
      };
    }
    return deviceDetails;
  }

  Future<void> sendDeviceDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? empId = prefs.getString('emp_id');
      String? id = prefs.getString('id');

      if (empId == null || id == null) {
        log('empId or id is missing in SharedPreferences');
        return;
      }

      Map<String, dynamic> fullDeviceDetails = await getDeviceDetails();
      Map<String, dynamic> minimalDeviceDetails = {
        "device_id": deviceId,
        "app_version": "0.0.4",
        "android":
            fullDeviceDetails["android_version"]?["release"] ?? "unknown",
      };

      List<Map<String, dynamic>> permissions = await _getPermissionStatuses();
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      Map<String, dynamic> requestBody = {
        "user_id": id,
        "login_date_time": formattedDate,
        "device_id": deviceId,
        "device_details": json.encode(minimalDeviceDetails),
        "permission_details": json.encode(permissions),
      };

      log("Request Body: $requestBody");

      final response = await http.post(
        Uri.parse("https://staginglink.org/twice/set_logged_in_user"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('User login details sent successfully : ${response.body}');
      } else {
        print('Failed to send user login details: ${response.body}');
      }
    } catch (e) {
      print('Error sending user login details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getPermissionStatuses() async {
    final permissionsToCheck = {
      "camera": Permission.camera,
      "notifications": Permission.notification,
    };

    List<Map<String, dynamic>> permissions = [];
    for (var entry in permissionsToCheck.entries) {
      final status = await entry.value.request();
      permissions.add({
        "permission": entry.key,
        "status": status.isGranted ? "granted" : "denied",
        "is_required": "Yes",
      });
    }
    return permissions;
  }

  Future<void> _setUserFcmToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');

    if (userId == null) {
      print('User ID is null');
      return;
    }

    final response = await http.post(
      Uri.parse('${MyApp.apiUrl}set_user_fcm_token_api'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'fcm_token': token,
        'device_id': deviceId,
      }),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: height * 0.28,
            left: width * 0.09,
            child: Container(
              width: width * 0.4,
              height: height * 0.04,
              color: Colors.transparent,
              child: Center(
                child: Text(
                  'Verify phone',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: width * 0.065,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF353B43),
                    height: 1.2,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.32,
            left: width * 0.11,
            child: Container(
              width: width * 0.7,
              color: Colors.transparent,
              child: Text(
                'Please enter the 6 digit security code we just sent you at 222-444-XXXX',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF353B43),
                  height: 1.2,
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.42,
            left: width * 0.135,
            child: Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: PinTheme(
                width: width * 0.1,
                height: width * 0.1,
                textStyle:
                    TextStyle(fontSize: width * 0.05, color: Colors.black),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Positioned(
            top: height * 0.52,
            left: width * 0.15,
            child: GestureDetector(
              onTap: _verifyOtp,
              child: Container(
                width: width * 0.67,
                height: height * 0.06,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFEC5012), Color(0xFFD72B23)],
                    stops: [0.0, 0.5661],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Center(
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 0.02,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.62,
            left: width * 0.36,
            child: Container(
              width: width * 0.29,
              height: height * 0.025,
              color: Colors.transparent,
              child: Center(
                child: Text(
                  'Resend in 40 Sec',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0056D0),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: height * 0.9,
            left: width * 0.23,
            child: Container(
              width: width * 0.5,
              height: height * 0.040,
              color: Colors.transparent,
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Didn’t receive the code? ',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF353B43),
                    ),
                    children: [
                      TextSpan(
                        text: 'Resend',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0056D0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
