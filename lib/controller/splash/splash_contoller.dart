import 'package:get/get.dart';
import 'package:krivisha_app/utility/app_routes.dart';

import '../../utility/app_utility.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await AppUtility.initialize();
    await Future.delayed(const Duration(seconds: 2));
    if (AppUtility.isLoggedIn) {
      Get.offNamed(AppRoutes.dashboard);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }
}