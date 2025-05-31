import 'package:get/get.dart';

import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class DashboardController extends GetxController {
  void logout() {
    AppUtility.clearUserInfo().then((_) {
      Get.offAllNamed(AppRoutes.login); // Navigate to login screen after logout
    });
  }
}
