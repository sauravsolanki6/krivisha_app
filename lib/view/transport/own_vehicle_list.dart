import 'dart:convert';
import 'dart:developer'; // For debug logs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:krivisha_app/model/order/get_all_orderlist_response.dart';
import 'package:krivisha_app/model/transport/own_vehicle_response.dart';
import 'package:krivisha_app/utility/utils.dart';
import 'package:krivisha_app/view/transport/edit_own_vehicle.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/autoTask_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';

class OwnVehicleList extends StatefulWidget {
  const OwnVehicleList({super.key});

  @override
  _OwnVehicleListState createState() => _OwnVehicleListState();
}

class _OwnVehicleListState extends State<OwnVehicleList> {
  bool _isSearching = false;
  String searchVal = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;
  String _statusFilter = '';
  String _challanNumberFilter = '';
  String _vehicleNameFilter = '';
  String _departmentNameFilter = '';
  String _fromDateFilter = '';
  String _toDateFilter = '';
  String _typeFilter = '';
  String _partyNameFilter = '';
  List<OwnVehicles> _orders = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchOwnvehicleList();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchVal = _searchController.text.trim();
      _orders.clear();
      _offset = 0;
      _hasMore = true;
    });
    fetchOwnvehicleList();
    log('Search query changed: $searchVal');
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      log('Triggering fetchOwnvehicleList for offset: $_offset');
      fetchOwnvehicleList();
    }
  }

  Future<void> fetchOwnvehicleList() async {
    if (_isLoadingMore || !_hasMore) {
      log('Fetch aborted: isLoadingMore: $_isLoadingMore, hasMore: $_hasMore');
      return;
    }

    try {
      setState(() {
        if (_offset == 0) {
          _isLoading = true;
        } else {
          _isLoadingMore = true;
        }
      });

      final jsonBody = {
        "limit": _limit,
        "offset": _offset,
        "from_date": _fromDateFilter,
        "to_date": _toDateFilter,
        "party_name": _partyNameFilter,
        "type_of_order": "",
        "ink_type": _typeFilter,
        "order_status": "",
        "search": "",
      };

      log('Fetching tasks with body: $jsonBody');

      // Updated to use get_all_order_list_api
      List<Object?>? response = await Networkcall().postMethod(
        Networkutility.getallOwnvehicleLIstApi, // API endpoint key
        Networkutility.getallOwnvehicleLIst, // API URL
        jsonEncode(jsonBody),
        context,
      );

      log('API Response (offset: $_offset): $response');

      if (response != null && response.isNotEmpty) {
        List<OwnvehicleListResponse> orderResponses =
            response.cast<OwnvehicleListResponse>();
        if (orderResponses[0].status == "true") {
          setState(() {
            if (orderResponses[0].data.isEmpty) {
              _hasMore = false;
              log('No more data: data is empty');
            } else {
              _orders.addAll(orderResponses[0].data);
              _offset += _limit;
              log(
                'Added ${orderResponses[0].data.length} tasks, new offset: $_offset',
              );
            }
          });
          if (_offset == 0) {
            Utils.flushBarErrorMessage(
              "Success: ${orderResponses[0].message}",
              context,
              status: "s",
            );
          }
        } else {
          setState(() {
            _hasMore = false;
            log('Error response: ${orderResponses[0].message}');
          });
          Utils.flushBarErrorMessage(
            "Error:  ${orderResponses[0].message}",
            context,
            status: "e",
          );
        }
      } else {
        Utils.flushBarErrorMessage(
          "Error:  No response from server. Please try again.",
          context,
          status: "e",
        );

        setState(() {
          _hasMore = false;
          log('No response from server');
        });
      }
    } catch (e) {
      Utils.flushBarErrorMessage(
        "Error:  Unexpected error: $e",
        context,
        status: "e",
      );

      setState(() {
        _hasMore = false;
        log('Exception: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      log(
        'Fetch completed: isLoading: $_isLoading, isLoadingMore: $_isLoadingMore',
      );
    }
  }

  // Get color based on purpose
  Color _getPurposeColor(String purpose) {
    // Example logic for purpose-based colors
    if (purpose.contains('1')) {
      return Colors.blue.shade300;
    } else if (purpose.contains('4')) {
      return Colors.green.shade300;
    } else if (purpose.contains('2')) {
      return Colors.orange.shade300;
    } else {
      return Colors.grey.shade300;
    }
  }

  String _getPurposeLabel(String taskHead) {
    switch (taskHead) {
      case '1':
        return 'Delivery';
      case '2':
        return 'Pickup';
      case '3':
        return 'Others';
      default:
        return "NA";
    }
  }

  String _getTaskHeadLabel(String taskHead) {
    switch (taskHead) {
      case '1':
        return 'Create Order';
      case '2':
        return 'Production Schedule';
      case '3':
        return 'Maintenance';
      default:
        return taskHead;
    }
  }

  String _getTaskStatusLabel(String status) {
    switch (status) {
      case '1':
        return 'Inprocess';
      case '2':
        return 'Pending';
      default:
        return 'Completed';
    }
  }

  String _getType(String status) {
    switch (status) {
      case '1':
        return 'Household';
      case '2':
        return 'Container';
      default:
        return 'Both';
    }
  }

  String _getContainerType(String status) {
    switch (status) {
      case '1':
        return 'Plain';
      case '2':
        return 'Printing';
      default:
        return 'N/A';
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _orders.clear();
      _offset = 0;
      _hasMore = true;
      searchVal = '';
      _searchController.clear();
      log('Refreshing: cleared tasks, reset offset, cleared search');
    });
    await fetchOwnvehicleList();
  }

  //   //filter sheet
  void _showFilterBottomSheet() {
    final TextEditingController challanNumberController = TextEditingController(
      text: _challanNumberFilter,
    );
    final TextEditingController vehicleController = TextEditingController(
      text: _vehicleNameFilter,
    );
    final TextEditingController fromDateController = TextEditingController(
      text: _fromDateFilter,
    );
    final TextEditingController toDateController = TextEditingController(
      text: _toDateFilter,
    );
    String? selectedStatus = _statusFilter.isNotEmpty ? _statusFilter : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to adjust height dynamically
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Function to show date picker
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
                        primary: AppColors.primary, // Header background color
                        onPrimary: Colors.white, // Header text color
                        onSurface: Colors.black87, // Body text color
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
                bottom: MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Adjust for keyboard
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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

                    // Party Name TextField
                    TextField(
                      controller: challanNumberController,
                      decoration: InputDecoration(
                        labelText: 'Challan Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Party Name TextField
                    TextField(
                      controller: vehicleController,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // From Date TextField with Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromDateController,
                            readOnly: true, // Prevent manual editing
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
                            readOnly: true, // Prevent manual editing
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

                    // To Date TextField with Date Picker
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _challanNumberFilter = '';
                                _vehicleNameFilter = '';
                                _fromDateFilter = '';
                                _toDateFilter = '';

                                // _tasks.clear();
                                // _offset = 0;
                                // _hasMore = true;
                              });
                              Navigator.pop(context);
                              fetchOwnvehicleList();
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
                                _challanNumberFilter =
                                    challanNumberController.text;
                                _vehicleNameFilter = vehicleController.text;
                                _fromDateFilter = fromDateController.text;
                                _toDateFilter = toDateController.text;

                                //  _tasks.clear();
                                // _offset = 0;
                                // _hasMore = true;
                              });
                              Navigator.pop(context);
                              fetchOwnvehicleList();
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

  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: _limit,
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
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 8,
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
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
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
            'Own Vehicle List',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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
                  ? const Center(
                      child: Text(
                        'No orders available',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _orders.length && _isLoadingMore) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final vehicle = _orders[index];
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
                              // Add navigation or action here
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: _getPurposeColor(vehicle.purpose),
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
                                              'SR No: ${vehicle.id}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              'Vehicle: ${vehicle.vehical}',
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
                                          'Challan DC No: ${vehicle.challanDcNo}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Invoice No: ${vehicle.invoiceNo}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Location: ${vehicle.city} (${vehicle.pincode})',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Purpose: ${_getPurposeLabel(vehicle.purpose)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Distance: ${vehicle.inKm} KM',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Freight: ${vehicle.marketFreight}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            Text(
                                              'Diesel: ${vehicle.dieselTopup}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Driver Exp: ${vehicle.driverExpense}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            Text(
                                              'Maintenance: ${vehicle.maintenance}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
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
                                                  // Add edit action here
                                                  Get.to(
                                                    EditOwnVehicle(
                                                      vehicle: vehicle,
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
