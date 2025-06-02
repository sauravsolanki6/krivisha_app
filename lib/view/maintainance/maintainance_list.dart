import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:krivisha_app/utility/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../controller/maintenance/maintenance_controller.dart';
import '../../core/urls.dart';

import '../../model/maintenance/maintenance_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import 'edit_maintainance.dart';
import 'maintenacnce_details_page.dart';

class MaintenanceList extends StatefulWidget {
  const MaintenanceList({super.key});

  @override
  _MaintenanceListState createState() => _MaintenanceListState();
}

class _MaintenanceListState extends State<MaintenanceList> {
  String _mwoCodeFilter = '';
  String _maintenanceRequiredFilter = '';
  String _fromDateFilter = '';
  String _toDateFilter = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Maintenance> _orders = [];
  int _offset = 0;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreData = true;

  // Map for action type display
  final Map<String, int> maintenanceTypeMap = {
    "Emergency": 1,
    "Online Breakdown": 2,
    "Preventive": 3,
    "Outside Work": 4,
    "General": 5,
  };

  // Map for maintenance required display and ID mapping
  final Map<String, String> maintenanceRequiredMap = {
    "Machine": "1",
    "Mould/Article": "2",
    "Printing Unit": "3",
    "Plant": "4",
    "Other": "5",
  };

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreData) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchMaintenanceList({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _offset = 0;
        _orders.clear();
        _hasMoreData = true;
        _isLoading = true;
      });
    }

    final requestBody = {
      'limit': _limit,
      'offset': _offset,
      'from_date': _fromDateFilter,
      'to_date': _toDateFilter,
      'mwo_code': _mwoCodeFilter,
      'maintain_action': _maintenanceRequiredFilter,
      'type_of_action': '',
      'sub_category': '',
      'search': '',
    };

    print('Request URL: ${Networkutility.getMaintainanceApi}');
    print('Request Headers: ${{'Content-Type': 'application/json'}}');
    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(Networkutility.getMaintainanceApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'true') {
          final List<dynamic> data = jsonResponse['data'];
          setState(() {
            _orders.addAll(
              data.map((item) => Maintenance.fromJson(item)).toList(),
            );
            _isLoading = false;
            _isLoadingMore = false;
            _hasMoreData = data.length == _limit;
          });
        } else {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _hasMoreData = false;
          });
          Utils.flushBarErrorMessage(
            jsonResponse['message'] ?? 'Failed to load data',
            context,
            status: "e",
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _hasMoreData = false;
        });
        Utils.flushBarErrorMessage(
          'Failed to load maintenance list',
          context,
          status: "e",
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      print('Exception: $e');
      Utils.flushBarErrorMessage('Error: $e', context, status: "e");
    }
  }

  Future<void> _fetchMoreData() async {
    setState(() {
      _isLoadingMore = true;
      _offset += _limit;
    });
    await _fetchMaintenanceList();
  }

  Future<void> _onRefresh() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MaintenanceList()),
    );
  }

  void _showFilterBottomSheet() {
    final TextEditingController mwocodeController = TextEditingController(
      text: _mwoCodeFilter,
    );
    String? selectedMaintenanceRequired = _maintenanceRequiredFilter.isNotEmpty
        ? maintenanceRequiredMap.entries
            .firstWhere(
              (entry) => entry.value == _maintenanceRequiredFilter,
              orElse: () => const MapEntry('', ''),
            )
            .key
        : null;
    final TextEditingController fromDateController = TextEditingController(
      text: _fromDateFilter,
    );
    final TextEditingController toDateController = TextEditingController(
      text: _toDateFilter,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> _selectDate(TextEditingController controller) async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setModalState(() {
                  controller.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: mwocodeController,
                      decoration: InputDecoration(
                        labelText: 'MWO Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Maintenance Required for',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      value: selectedMaintenanceRequired,
                      items: maintenanceRequiredMap.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedMaintenanceRequired = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'From Date (YYYY-MM-DD)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: () => _selectDate(fromDateController),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: toDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'To Date (YYYY-MM-DD)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                              ),
                            ),
                            onTap: () => _selectDate(toDateController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _mwoCodeFilter = '';
                                _maintenanceRequiredFilter = '';
                                _fromDateFilter = '';
                                _toDateFilter = '';
                                _offset = 0;
                                _orders.clear();
                                _hasMoreData = true;
                              });
                              _fetchMaintenanceList(isRefresh: true);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _mwoCodeFilter = mwocodeController.text;
                                _maintenanceRequiredFilter =
                                    selectedMaintenanceRequired != null
                                        ? maintenanceRequiredMap[
                                            selectedMaintenanceRequired]!
                                        : '';
                                _fromDateFilter = fromDateController.text;
                                _toDateFilter = toDateController.text;
                                _offset = 0;
                                _orders.clear();
                                _hasMoreData = true;
                              });
                              _fetchMaintenanceList(isRefresh: true);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1':
        return Colors.orange.shade300; // Inprocess
      case '2':
        return Colors.green; // Completed
      default:
        return Colors.grey.shade300;
    }
  }

  String _getActionTypeName(String typeOfAction) {
    return maintenanceTypeMap.entries
        .firstWhere(
          (entry) => entry.value.toString() == typeOfAction,
          orElse: () => const MapEntry('Unknown', 0),
        )
        .key;
  }

  String _formatDateToIndian(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date; // Return original date if parsing fails
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 16,
                              color: Colors.white,
                            ),
                            Container(
                              width: 80,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 50, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 12,
                              color: Colors.white,
                            ),
                            Container(
                              width: 80,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offNamed(AppRoutes.dashboard);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Maintenance List',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              Get.offNamed(AppRoutes.dashboard);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.blue,
          backgroundColor: Colors.white,
          child: _isLoading
              ? _buildShimmer()
              : _orders.isEmpty
                  ? const Center(child: Text('No maintenance records found'))
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _orders.length && _isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final order = _orders[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Get the MaintenanceController instance
                              final MaintenanceController
                                  maintenanceController =
                                  Get.put(MaintenanceController());

                              // Store the selected maintenance order in the controller
                              maintenanceController
                                  .setSelectedMaintenance(order);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MaintenanceDetailsPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        left: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'ID: ${order.id}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              'MWO Code: ${order.mwoCode}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Plant Name: ${order.plantName}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Employee Name: ${order.firstName}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Action Type: ${_getActionTypeName(order.typeOfAction)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Maintenance Type: ${order.maintenanceType}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Type Name: ${order.typeName}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Problems: ${order.problems}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Date: ${_formatDateToIndian(order.date)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Status: ${order.status == '1' ? 'Pending' : order.status == '2' ? 'Completed' : ''}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getStatusColor(
                                                  order.status,
                                                ),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  // Get the MaintenanceController instance
                                                  final MaintenanceController
                                                      maintenanceController =
                                                      Get.put(
                                                    MaintenanceController(),
                                                  );

                                                  // Store the selected maintenance order in the controller
                                                  maintenanceController
                                                      .setSelectedMaintenance(
                                                    order,
                                                  );

                                                  // Navigate to EditMaintainance using Navigator.pushReplacement
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditMaintainance(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }
}
