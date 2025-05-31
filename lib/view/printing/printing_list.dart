import 'dart:convert';
import 'dart:developer'; // For debug logs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:krivisha_app/model/order/get_all_orderlist_response.dart';
import 'package:krivisha_app/model/printing/get_printing_list_response.dart';
import 'package:krivisha_app/utility/utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/autoTask_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';

class PrintingListPage extends StatefulWidget {
  const PrintingListPage({super.key});

  @override
  _PrintingListPageState createState() => _PrintingListPageState();
}

class _PrintingListPageState extends State<PrintingListPage> {
  bool _isSearching = false;
  String searchVal = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;
  String _statusFilter = '';
  String _departmentNameFilter = '';
  String _fromDateFilter = '';
  String _toDateFilter = '';
  String _typeFilter = '';
  String _partyNameFilter = '';
  List<Printing> printings = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fecthPrintingList();
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
      printings.clear();
      _offset = 0;
      _hasMore = true;
    });
    fecthPrintingList();
    log('Search query changed: $searchVal');
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      log('Triggering fecthPrintingList for offset: $_offset');
      fecthPrintingList();
    }
  }

  Future<void> fecthPrintingList() async {
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
        // "from_date": _fromDateFilter,
        // "to_date": _toDateFilter,
        // "party_name": _partyNameFilter,
        // "type_of_order": "",
        // "ink_type": _typeFilter,
        // "order_status": "",
        "search": searchVal,
      };

      log('Fetching tasks with body: $jsonBody');

      // Updated to use get_all_order_list_api
      List<Object?>? response = await Networkcall().postMethod(
        Networkutility.getallPrintingReportlistApi, // API endpoint key
        Networkutility.getallPrintingReportlist, // API URL
        jsonEncode(jsonBody),
        context,
      );

      log('API Response (offset: $_offset): $response');

      if (response != null && response.isNotEmpty) {
        List<GetAllPrintingListResponse> orderResponses =
            response.cast<GetAllPrintingListResponse>();
        if (orderResponses[0].status == "true") {
          setState(() {
            if (orderResponses[0].data.isEmpty) {
              _hasMore = false;
              log('No more data: data is empty');
            } else {
              printings.addAll(orderResponses[0].data);
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

  Color _getStatusColor(String status) {
    switch (status) {
      //  Colors.blue.shade300
      case '1':
        return Colors.red.shade300;
      case '2':
        return Colors.orange.shade300;
      case '3':
        return Colors.orange.shade300;
      case '4':
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
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
        return 'Pending';
      case '2':
        return 'Proceed to Accounting';
      case '3':
        return 'Proceed to Printing';
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

  String _getInkType(String status) {
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
      printings.clear();
      _offset = 0;
      _hasMore = true;
      searchVal = '';
      _searchController.clear();
      log('Refreshing: cleared tasks, reset offset, cleared search');
    });
    await fecthPrintingList();
  }

  void _showFilterBottomSheet() {
    String? selectedType = _typeFilter.isNotEmpty ? _typeFilter : null;
    final TextEditingController partyNameController = TextEditingController(
      text: _partyNameFilter,
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
                bottom:
                    MediaQuery.of(
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
                      controller: partyNameController,
                      inputFormatters: [
                        // FilteringTextInputFormatter.deny(RegExp(r'\s'))
                      ],
                      decoration: InputDecoration(
                        labelText: 'Party Name',
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
                        labelText: 'Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      value: selectedType,
                      items:
                          ['1', '2', '3'].map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type == '1'
                                    ? 'Household'
                                    : type == '2'
                                    ? 'Container'
                                    : "Both",
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    // const SizedBox(height: 16),
                    // // Status Dropdown
                    // DropdownButtonFormField<String>(
                    //   decoration: InputDecoration(
                    //     labelText: 'Status',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //       borderSide: BorderSide(color: Colors.grey.shade300),
                    //     ),
                    //     filled: true,
                    //     fillColor: Colors.grey.shade50,
                    //   ),
                    //   value: selectedStatus,
                    //   items:
                    //       ['1', '2'].map((status) {
                    //         return DropdownMenuItem<String>(
                    //           value: status,
                    //           child: Text(
                    //             status == '1' ? 'Pending' : "Completed",
                    //             // status == '1'
                    //             //     ? 'Pending'
                    //             //     : status == '2'
                    //             //     ? 'Completed'
                    //             //     : "",
                    //           ),
                    //         );
                    //       }).toList(),
                    //   onChanged: (value) {
                    //     setModalState(() {
                    //       selectedStatus = value;
                    //     });
                    //   },
                    // ),
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
                                _partyNameFilter = '';
                                _fromDateFilter = '';
                                _toDateFilter = '';
                                _typeFilter = '';
                                printings.clear();
                                _offset = 0;
                                _hasMore = true;
                              });
                              Navigator.pop(context);
                              fecthPrintingList();
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
                                _typeFilter = selectedType ?? '';
                                _partyNameFilter = partyNameController.text;
                                _fromDateFilter = fromDateController.text;
                                _toDateFilter = toDateController.text;
                                _statusFilter = selectedStatus ?? '';
                                printings.clear();
                                _offset = 0;
                                _hasMore = true;
                              });
                              Navigator.pop(context);
                              fecthPrintingList();
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
            'Printing Report List',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    // _filteredItems = _items;
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 15, left: 15),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      searchVal = value;
                      fecthPrintingList();
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Search here...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,

                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.blue,
                backgroundColor: Colors.white,
                child:
                    _isLoading
                        ? _buildShimmer()
                        : printings.isEmpty
                        ? const Center(
                          child: Text(
                            'No orders available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          itemCount:
                              printings.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == printings.length && _isLoadingMore) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final order = printings[index];
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
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            order.orderStatus,
                                          ),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'SR No: ${order.id}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  'Order ID: ${order.orderId}',
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
                                              'Party: ${order.partyName}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Type: ${_getType(order.typeOfOrder ?? "")}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            // const SizedBox(height: 4),
                                            // Text(
                                            //   'Article: ${order.inkType}',
                                            //   style: const TextStyle(
                                            //     fontSize: 12,
                                            //     color: Colors.black45,
                                            //   ),
                                            // ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ink Type: ${_getInkType(order.inkType)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Date: ${DateFormat('dd-MM-yyyy').format(order.orderDate)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                  ),
                                                ),
                                                Text(
                                                  'Status: ${_getTaskStatusLabel(order.orderStatus)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getStatusColor(
                                                      order.orderStatus,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _showSubDetailsDialog(
                                                  order.subDetails,
                                                );
                                              },
                                              icon: Icon(Icons.remove_red_eye),
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
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }

  void _showSubDetailsDialog(List<SubDetail> subDetails) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Printing Sub-Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Group of Article')),
                  DataColumn(label: Text('Article Name')),
                  DataColumn(label: Text('Order Quantity')),
                  DataColumn(label: Text('Remark')),
                ],
                rows:
                    subDetails
                        .map(
                          (data) => DataRow(
                            cells: [
                              DataCell(Text(data.groupOfArticle ?? '-')),
                              DataCell(Text(data.articleName ?? '-')),
                              DataCell(Text(data.orderQuantity ?? '-')),
                              DataCell(Text(data.remark ?? '-')),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class PrintingListPage extends StatefulWidget {
//   const PrintingListPage({super.key});

//   @override
//   _PrintingListPageState createState() => _PrintingListPageState();
// }

// class _PrintingListPageState extends State<PrintingListPage> {
//   // Dummy data for orders
//   final List<Map<String, dynamic>> printings = const [
//     {
//       'srNo': 1,
//       'reporting_data': 'Job',
//       'ink_consumed1': 'red',
//       'ink_consumed2': 'green',
//       'ink_consumed3': 'white',
//       'ink_consumed4': 'red',
//       'ink_consumed5': 'Glossy',
//       'other_material1': 'Machine',
//       'other_material2': 'Machine',
//       'status': 'Pending',
//     },
//     {
//       'srNo': 2,
//       'reporting_data': 'Job',
//       'ink_consumed1': 'red',
//       'ink_consumed2': 'green',
//       'ink_consumed3': 'white',
//       'ink_consumed4': 'red',
//       'ink_consumed5': 'Glossy',
//       'other_material1': 'Machine',
//       'other_material2': 'Machine',
//       'status': 'Completed',
//     },
//     {
//       'srNo': 3,
//       'reporting_data': 'Job',
//       'ink_consumed1': 'red',
//       'ink_consumed2': 'green',
//       'ink_consumed3': 'white',
//       'ink_consumed4': 'red',
//       'ink_consumed5': 'Glossy',
//       'other_material1': 'Machine',
//       'other_material2': 'Machine',
//       'status': 'Inprocess',
//     },
//   ];

//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // Simulate initial loading
//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         _isLoading = false;
//       });
//     });
//   }

//   // Get color based on status
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Inprocess':
//         return Colors.blue.shade300;
//       case 'Pending':
//         return Colors.orange.shade300;
//       case 'Completed':
//         return Colors.green.shade300;
//       default:
//         return Colors.grey.shade300;
//     }
//   }

//   // Handle refresh
//   Future<void> _onRefresh() async {
//     setState(() {
//       _isLoading = true;
//     });
//     // Simulate network fetch
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   // Build shimmer skeleton
//   Widget _buildShimmer() {
//     return ListView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(16.0),
//       itemCount: 3, // Number of skeleton items
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Card(
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: BorderSide(color: Colors.grey.shade300, width: 1.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 8,
//                     height: 100,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.horizontal(
//                         left: Radius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               width: 80,
//                               height: 16,
//                               color: Colors.white,
//                             ),
//                             Container(
//                               width: 80,
//                               height: 16,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           width: double.infinity,
//                           height: 14,
//                           color: Colors.white,
//                         ),
//                         const SizedBox(height: 4),
//                         Container(width: 100, height: 12, color: Colors.white),
//                         const SizedBox(height: 4),
//                         Container(width: 100, height: 12, color: Colors.white),
//                         const SizedBox(height: 4),
//                         Container(width: 100, height: 12, color: Colors.white),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               width: 80,
//                               height: 12,
//                               color: Colors.white,
//                             ),
//                             Container(
//                               width: 80,
//                               height: 12,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         title: const Text(
//           'Orders',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
//         ),

//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         color: Colors.blue,
//         backgroundColor: Colors.white,
//         child:
//             _isLoading
//                 ? _buildShimmer()
//                 : ListView.builder(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: printings.length,
//                   itemBuilder: (context, index) {
//                     final order = printings[index];
//                     return TweenAnimationBuilder(
//                       tween: Tween<double>(begin: 0, end: 1),
//                       duration: Duration(milliseconds: 300 + (index * 100)),
//                       builder: (context, double value, child) {
//                         return Opacity(
//                           opacity: value,
//                           child: Transform.translate(
//                             offset: Offset(0, 20 * (1 - value)),
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: Card(
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: BorderSide(
//                             color: Colors.grey.shade300,
//                             width: 1.0,
//                           ),
//                         ),
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(12),
//                           onTap: () {
//                             // Add navigation or action here
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 8,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     color: _getStatusColor(order['status']),
//                                     borderRadius: const BorderRadius.horizontal(
//                                       left: Radius.circular(12),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             'SR No: ${order['srNo']}',
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                           Text(
//                                             'Reporting: ${order['reporting_data']}',
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.black54,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Ink Consumed 1: ${order['ink_consumed1']}',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.black54,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Ink Consumed 2: ${order['ink_consumed2']}',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.black45,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Ink Consumed 3: ${order['ink_consumed3']}',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.black45,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Ink Consumed 4: ${order['ink_consumed4']}',
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.black45,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             'Ink Consumed 5: ${order['ink_consumed5']}',
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.black45,
//                                             ),
//                                           ),
//                                           Text(
//                                             'Status: ${order['status']}',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: _getStatusColor(
//                                                 order['status'],
//                                               ),
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//       ),
//       backgroundColor: Colors.grey.shade100,
//     );
//   }
// }
