import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utility/app_colors.dart';

class TransportList extends StatefulWidget {
  const TransportList({super.key});

  @override
  _TransportListState createState() => _TransportListState();
}

class _TransportListState extends State<TransportList> {
   bool _isSearching = false;
  String searchVal = '';
  final TextEditingController _searchController = TextEditingController();
  String _partyNameFilter = '';
  String _typeFilter = '';
  String _fromDateFilter = '';
  String _toDateFilter = '';
  String _statusFilter = '';
  // Updated data for orders
  final List<Map<String, dynamic>> _orders = const [
    {
      'srNo': 1,
      'orderId': 'ORD-043',
      'orderDate': '06-05-2025',
      'partyName': 'Krivisha Industries',
      'articleGroup': 'View',
      'status': 'In Process',
    },
    {
      'srNo': 2,
      'orderId': 'ORD-044',
      'orderDate': '07-05-2025',
      'partyName': 'Nexlify Solutions',
      'articleGroup': 'Components',
      'status': 'Pending',
    },
    {
      'srNo': 3,
      'orderId': 'ORD-045',
      'orderDate': '08-05-2025',
      'partyName': 'Starlight Enterprises',
      'articleGroup': 'Modules',
      'status': 'Completed',
    },
    {
      'srNo': 4,
      'orderId': 'ORD-046',
      'orderDate': '09-05-2025',
      'partyName': 'Bluewave Logistics',
      'articleGroup': 'Parts',
      'status': 'In Process',
    },
    {
      'srNo': 5,
      'orderId': 'ORD-047',
      'orderDate': '10-05-2025',
      'partyName': 'Techtrend Innovations',
      'articleGroup': 'Accessories',
      'status': 'Pending',
    },
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate initial loading
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Process':
        return Colors.blue.shade300;
      case 'Pending':
        return Colors.orange.shade300;
      case 'Completed':
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  // Handle refresh
  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate network fetch
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  //filter sheet
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
                    // Status Dropdown
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
                      items:
                          ['1', '2'].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                status == '1' ? 'Pending' : "Completed",
                                // status == '1'
                                //     ? 'Pending'
                                //     : status == '2'
                                //     ? 'Completed'
                                //     : "",
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedStatus = value;
                        });
                      },
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
                                _partyNameFilter = '';
                                _fromDateFilter = '';
                                _toDateFilter = '';
                                _statusFilter = '';
                                // _tasks.clear();
                                // _offset = 0;
                                // _hasMore = true;
                              });
                              Navigator.pop(context);
                              // fetchTasks();
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
                                _partyNameFilter = partyNameController.text;
                                _fromDateFilter = fromDateController.text;
                                _toDateFilter = toDateController.text;
                                _statusFilter = selectedStatus ?? '';
                                // _tasks.clear();
                                // _offset = 0;
                                // _hasMore = true;
                              });
                              Navigator.pop(context);
                              // fetchTasks();
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

  // Build shimmer skeleton
  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: 1, // Adjusted to match new data
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
                    height: 80, // Adjusted height for fewer fields
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transport List', // Corrected typo
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),

        centerTitle: true,
        actions: [
            // IconButton(
            //   icon: Icon(_isSearching ? Icons.close : Icons.search),
            //   onPressed: () {
            //     setState(() {
            //       _isSearching = !_isSearching;
            //       if (!_isSearching) {
            //         _searchController.clear();
            //         // _filteredItems = _items;
            //       }
            //     });
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
            ),
          ],
      ),
      body:Column(
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 15, left: 15),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {},
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
                      : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Card(
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
                                  // Could implement edit action here
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height:
                                            80, // Adjusted height for fewer fields
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order['status']),
                                          borderRadius: const BorderRadius.horizontal(
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
                                                  'SR No: ${order['srNo']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  'Order ID: ${order['orderId']}',
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
                                              'Party: ${order['partyName']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Article: ${order['articleGroup']}',
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
                                                  'Date: ${order['orderDate']}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                  ),
                                                ),
                                                Text(
                                                  'Status: ${order['status']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getStatusColor(
                                                      order['status'],
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
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
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                          color: Colors.blue,
                                                          size: 24,
                                                        ),
                                                        onPressed: () {
                                                          // Add edit action here
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
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
                                                        },
                                                      ),
                                                    ),
                                                  ],
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
                      ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
