import 'package:get/get.dart';
import 'package:krivisha_app/view/login/login_page.dart';
import 'package:krivisha_app/view/printing/printing_list.dart';
import 'package:krivisha_app/view/transport/own_vehicle_list.dart';
import 'package:krivisha_app/view/transport/transport_list.dart';

import '../view/create_order/order_list.dart';
import '../view/dashboard/homeScreen.dart';
import '../view/maintainance/maintainance_list.dart';
import '../view/splash/splashscreen.dart';
import '../view/tasks/mannual_task_list.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String maintainanceList = '/maintainanceList';
  static const String manualtaskList = '/manualtaskList';
  static const String createorderList = '/createorderList';
  static const String ownvehicleList = '/ownvehicleList';
  static const String transportList = '/transportList';
  static const String printingReportList = '/printing_reportlist';
  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      //  binding: GlobalBindings(), // Apply global bindings here
    ),
    GetPage(
      name: login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
      // binding: GlobalBindings(), // Apply global bindings here
    ),
    GetPage(
      name: dashboard,
      page: () => MyDashboard(),
      transition: Transition.fadeIn,
      // binding: GlobalBindings(), // Apply global bindings here
    ),
    GetPage(
      name: maintainanceList,
      page: () => MaintenanceList(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: manualtaskList,
      page: () => ManualTaskList(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: createorderList,
      page: () => CreateOrderList(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: ownvehicleList,
      page: () => OwnVehicleList(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: transportList,
      page: () => TransportList(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: printingReportList,
      page: () => PrintingListPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
