import 'dart:convert';
import 'dart:developer'; // For debug logs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:krivisha_app/model/order/get_all_orderlist_response.dart';
import 'package:krivisha_app/utility/utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import 'edit_order.dart';

class CreateOrderList extends StatefulWidget {
  const CreateOrderList({super.key});

  @override
  _CreateOrderListState createState() => _CreateOrderListState();
}

class _CreateOrderListState extends State<CreateOrderList> {
  bool _isSearching = false;
  String searchVal = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;
  String _statusFilter = '';
  String _typeFilter = '';
  String _partyNameFilter = '';
  String _fromDateFilter = '';
  String _toDateFilter = '';
  List<Order> _orders = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchOrderList();
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
    fetchOrderList();
    log('Search query changed: $searchVal');
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      log('Triggering fetchOrderList for offset: $_offset');
      fetchOrderList();
    }
  }

  Future<void> fetchOrderList() async {
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
        "search": searchVal,
        if (_statusFilter.isNotEmpty) "order_status": _statusFilter,
        if (_typeFilter.isNotEmpty) "type_of_order": _typeFilter,
        if (_partyNameFilter.isNotEmpty) "party_name": _partyNameFilter,
        if (_fromDateFilter.isNotEmpty) "from_date": _fromDateFilter,
        if (_toDateFilter.isNotEmpty) "to_date": _toDateFilter,
      };

      log('Fetching orders with body: $jsonBody');

      List<Object?>? response = await Networkcall().postMethod(
        Networkutility.getOrderListApi,
        Networkutility.getOrderList,
        jsonEncode(jsonBody),
        context,
      );

      log('API Response (offset: $_offset): $response');

      if (response != null && response.isNotEmpty) {
        List<GetAllOrderlistResponse> orderResponses =
            response.cast<GetAllOrderlistResponse>();
        if (orderResponses[0].status) {
          setState(() {
            if (orderResponses[0].data.isEmpty) {
              _hasMore = false;
              log('No more data: data is empty');
            } else {
              _orders.addAll(orderResponses[0].data);
              _offset += _limit;
              log('Added ${orderResponses[0].data.length} orders, new offset: $_offset');
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
            "Error: ${orderResponses[0].message}",
            context,
            status: "e",
          );
        }
      } else {
        setState(() {
          _hasMore = false;
          log('No response from server');
        });
        Utils.flushBarErrorMessage(
          "Error: No response from server. Please try again.",
          context,
          status: "e",
        );
      }
    } catch (e) {
      setState(() {
        _hasMore = false;
        log('Exception: $e');
      });
      Utils.flushBarErrorMessage(
        "Error: Unexpected error: $e",
        context,
        status: "e",
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      log('Fetch completed: isLoading: $_isLoading, isLoadingMore: $_isLoadingMore');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1':
        return Colors.red.shade300;
      case '2':
        return Colors.orange.shade300;
      case '3':
        return Colors.blue.shade300;
      case '4':
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  String _getTaskStatusLabel(String status) {
    switch (status) {
      case '1':
        return 'Pending';
      case '2':
        return 'Proceed to Account';
      case '3':
        return 'Proceed to Printing';
      case '4':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  String _getType(String type) {
    switch (type) {
      case '1':
        return 'Household';
      case '2':
        return 'Container';
      default:
        return 'Both';
    }
  }

  String _getInkType(dynamic inkType) {
    if (inkType == null) return 'N/A';
    switch (inkType.toString()) {
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
      _statusFilter = '';
      _typeFilter = '';
      _partyNameFilter = '';
      _fromDateFilter = '';
      _toDateFilter = '';
      log('Refreshing: cleared orders, reset offset, cleared search and filters');
    });
    await fetchOrderList();
  }

  void _showFilterBottomSheet() {
    String? selectedType = _typeFilter.isNotEmpty ? _typeFilter : null;
    String? selectedStatus = _statusFilter.isNotEmpty ? _statusFilter : null;
    final TextEditingController partyNameController =
        TextEditingController(text: _partyNameFilter);
    final TextEditingController fromDateController =
        TextEditingController(text: _fromDateFilter);
    final TextEditingController toDateController =
        TextEditingController(text: _toDateFilter);

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
                      controller: partyNameController,
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
                      items: ['1', '2', '3'].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(_getType(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      value: selectedStatus,
                      items: ['1', '2', '3', '4'].map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(_getTaskStatusLabel(status)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedStatus = value;
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
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
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
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
                                _partyNameFilter = '';
                                _fromDateFilter = '';
                                _toDateFilter = '';
                                _typeFilter = '';
                                _statusFilter = '';
                                _orders.clear();
                                _offset = 0;
                                _hasMore = true;
                              });
                              Navigator.pop(context);
                              fetchOrderList();
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
                                _statusFilter = selectedStatus ?? '';
                                _partyNameFilter = partyNameController.text;
                                _fromDateFilter = fromDateController.text;
                                _toDateFilter = toDateController.text;
                                _orders.clear();
                                _offset = 0;
                                _hasMore = true;
                              });
                              Navigator.pop(context);
                              fetchOrderList();
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
            'Order List',
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
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
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
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Search by order ID or party name...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                child: _isLoading
                    ? _buildShimmer()
                    : _orders.isEmpty
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
                                _orders.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _orders.length && _isLoadingMore) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final order = _orders[index];
                              final subDetailsSummary = order
                                      .subDetails.isNotEmpty
                                  ? order.subDetails
                                      .map((sub) =>
                                          "${sub.articleName} (${sub.orderQuantity})")
                                      .join(", ")
                                  : "No articles";

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
                                    log('Tapped order: ${order.orderId}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                order.orderStatus),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Order ID: ${order.orderId}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color:
                                                              AppColors.primary,
                                                          size: 20,
                                                        ),
                                                        onPressed: () {
                                                          Get.to(() =>
                                                              EditOrderPage(
                                                                order: order,
                                                              ));
                                                          log('Edit order: ${order.orderId}');
                                                        },
                                                      ),
                                                    ],
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
                                                'Type: ${_getType(order.typeOfOrder)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Ink Type: ${_getInkType(order.inkType)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Articles: $subDetailsSummary',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                                          order.orderStatus),
                                                      fontWeight:
                                                          FontWeight.w600,
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
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }
}
