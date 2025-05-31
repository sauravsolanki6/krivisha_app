import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:krivisha_app/utility/app_colors.dart';
import 'package:krivisha_app/view/create_order/create_order.dart';
import 'package:krivisha_app/view/notifiation.dart';
import 'package:krivisha_app/view/signUp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../controller/dashboard/dashboard_controller.dart';
import '../create_order/order_list.dart';
import '../maintainance/add_maintainance.dart';
import '../maintainance/maintainance_list.dart';
import '../tasks/add_task.dart';
import '../tasks/auto_task_list.dart';
import '../tasks/mannual_task_list.dart';
import '../transport/add_transport.dart';
import '../transport/own_vehicle.dart';
import '../transport/own_vehicle_list.dart';
import '../transport/transport_list.dart';
import '../printing/add_printing.dart';
import '../printing/printing_list.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final controller = Get.put(DashboardController());

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 220, // Reduced width to prevent overflow
      child: ListView(
        padding: EdgeInsets.only(top: 20),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'KRIVISHA',
                style: TextStyle(
                  fontSize: 20, // Smaller font
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Divider(color: AppColors.primary, thickness: 1.0),
          _buildOrdersItem(), // Re
          _buildSidebarItem(
            icon: CupertinoIcons.create,
            title: 'Add Task',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTask()),
                ),
          ),
          _buildSidebarItem(
            icon: CupertinoIcons.create,
            title: 'Web View',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => WebViewPage(
                          url:
                              'https://seekhelp.in/krivisha/production_form_list/139',
                        ),
                  ),
                ),
          ),
          _buildTaskListItem(),
          _buildOutwardTransportItem(),
          _buildPrintingItem(),
          _buildMaintenanceItem(),
          _buildSidebarItem(
            icon: CupertinoIcons.bell,
            title: 'Notifications',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                ),
          ),
          _buildSidebarItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _showLogoutConfirmationDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersItem() {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(CupertinoIcons.doc, color: AppColors.primary, size: 18),
      ),
      title: Text(
        'Orders',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.only(left: 40),
      iconColor: Colors.grey.shade500,
      children: [
        _buildSubItem(
          icon: CupertinoIcons.add_circled,
          title: 'Create Order',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateOrder()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.list_bullet,
          title: 'Order List',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateOrderList(),
                ), // Replace with your OrderList page
              ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.blue.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6), // Smaller padding
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 18,
                ), // Smaller icon
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // Smaller font
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18, // Smaller chevron
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskListItem() {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.doc_on_doc,
          color: AppColors.primary,
          size: 18,
        ),
      ),
      title: Text(
        'Task List',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.only(left: 40), // Reduced indent
      iconColor: Colors.grey.shade500,
      children: [
        _buildSubItem(
          icon: CupertinoIcons.doc_text,
          title: 'Manual Task',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManualTaskList()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.doc_text,
          title: 'Auto Task',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AutoTaskList()),
              ),
        ),
      ],
    );
  }

  Widget _buildOutwardTransportItem() {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.car_detailed,
          color: AppColors.primary,
          size: 18,
        ),
      ),
      title: Text(
        'Transport',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.only(left: 40),
      iconColor: Colors.grey.shade500,
      children: [
        _buildSubItem(
          icon: CupertinoIcons.add_circled,
          title: 'Add Transport',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransport()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.list_bullet,
          title: 'Transport List',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransportList()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.car,
          title: 'Own Vehicle',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OwnVehicle()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.list_bullet,
          title: 'Vehicle List',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OwnVehicleList()),
              ),
        ),
      ],
    );
  }

  Widget _buildPrintingItem() {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(CupertinoIcons.printer, color: AppColors.primary, size: 18),
      ),
      title: Text(
        'Printing',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.only(left: 40),
      iconColor: Colors.grey.shade500,
      children: [
        _buildSubItem(
          icon: CupertinoIcons.add_circled,
          title: 'Add Printing',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPrinting()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.list_bullet,
          title: 'Printing Report List',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrintingListPage()),
              ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem() {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(CupertinoIcons.wrench, color: AppColors.primary, size: 18),
      ),
      title: Text(
        'Maintenance',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(horizontal: 12),
      childrenPadding: EdgeInsets.only(left: 40),
      iconColor: Colors.grey.shade500,
      children: [
        _buildSubItem(
          icon: CupertinoIcons.add_circled,
          title: 'Add Maintenance',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMaintenancePage()),
              ),
        ),
        _buildSubItem(
          icon: CupertinoIcons.list_bullet,
          title: 'Maintenance List',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MaintenanceList()),
              ),
        ),
      ],
    );
  }

  Widget _buildSubItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13, // Smaller font for sub-items
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                "Are you sure you want to log out?",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.logout(); // Use the _logout function
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    print("WebView URL: ${widget.url}");
    // Set device orientation to landscape only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    // Restore default orientations when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Are you sure you want to go back?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Web View'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}


// class WebViewPage extends StatefulWidget {
//   final String url;

//   const WebViewPage({Key? key, required this.url}) : super(key: key);

//   @override
//   _WebViewPageState createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     print("WebView URL: ${widget.url}");
//     // Set the device orientation to landscape
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(widget.url));
//   }

//   @override
//   void dispose() {
//     // Restore default orientations when leaving the page
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     super.dispose();
//   }

//   Future<bool> _onWillPop() async {
//     bool shouldPop = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm'),
//         content: const Text('Are you sure you want to go back?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     return shouldPop;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Web View'),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () async {
//               bool shouldPop = await _onWillPop();
//               if (shouldPop) {
//                 Navigator.of(context).pop();
//               }
//             },
//           ),
//         ),
//         body: WebViewWidget(controller: _controller),
//       ),
//     );
//   }
// }