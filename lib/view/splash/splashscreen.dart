import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:krivisha_app/utility/app_images.dart';
import 'package:krivisha_app/view/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../controller/splash/splash_contoller.dart';
import '../../utility/app_colors.dart';
import '../dashboard/homeScreen.dart';
import '../signUp.dart';
import '../onboardingScreen1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String mobileNumber = '';
  String isLoginFirst = '';
  String deviceId = '';
  String userId = '';

  // @override
  // void initState() {
  //   super.initState();
  //   getDeviceId();
  //   Future.delayed(Duration(seconds: 3), () {
  //       Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //     // getValuesFromSharedPref();
  //   });
  // }

  Future<void> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDeviceId = prefs.getString('device_id');
    if (storedDeviceId == null || storedDeviceId.isEmpty) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        storedDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        storedDeviceId = iosInfo.identifierForVendor ?? '';
      }
      await prefs.setString('device_id', storedDeviceId ?? '');
    }
    setState(() {
      deviceId = storedDeviceId ?? '';
    });
  }

  Future<void> checkLoginStatus(String userId) async {
    try {
      // movenext();
    } catch (e) {
      print('Error: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  // void getValuesFromSharedPref() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   mobileNumber = prefs.getString('mobileNumber') ?? '';
  //   isLoginFirst = prefs.getString('isloginfirst') ?? '';
  //   userId = prefs.getString('id') ?? '';

  //   setState(() {});

  //   if (userId.isNotEmpty && deviceId.isNotEmpty) {
  //     await checkLoginStatus(userId);
  //   } else {
  //     movenext();
  //   }
  // }

  // void movenext() {
  //   if (userId.isNotEmpty) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => MyDashboard()),
  //     );
  //   } else {
  //     if (isLoginFirst == "1") {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => SignUpPage()),
  //       );
  //     } else {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => Onboarding()),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset('images/splashScreen.png', fit: BoxFit.cover),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image(image: AssetImage(AppImages.splashlogo)),
                ),
                // Text(
                //   'KRIVISHA',
                //   style: TextStyle(
                //     color: AppColors.primary,
                //     fontSize: 48,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
