import 'dart:convert';
import 'dart:developer'; // For debug logs
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/autoTask_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/utils.dart';
import 'task_edit_form.dart';

class AutoTaskList extends StatefulWidget {
  const AutoTaskList({super.key});

  @override
  _AutoTaskListState createState() => _AutoTaskListState();
}

class _AutoTaskListState extends State<AutoTaskList> {
  bool _isSearching = false;
  String searchVal = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 10;

  String _departmentNameFilter = '';

  String _fromDateFilter = '';
  String _toDateFilter = '';
  String _statusFilter = '';
  String _taskActonFilter = '';
  List<Autotask> _tasks = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    log(
      'Scroll position: ${_scrollController.position.pixels}, Max: ${_scrollController.position.maxScrollExtent}',
    );
    log(
      'Conditions: isLoading: $_isLoading, isLoadingMore: $_isLoadingMore, hasMore: $_hasMore',
    );

    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      log('Triggering fetchTasks for offset: $_offset');
      fetchTasks();
    }
  }

  Future<void> fetchTasks() async {
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
        "task_action": _taskActonFilter,
        "task_status": _statusFilter,
        "order_department": _departmentNameFilter,
        "search": searchVal,
      };

      log('Fetching tasks with body: $jsonBody');

      List<Object?>? response = await Networkcall().postMethod(
        Networkutility.autoTaskListApi,
        Networkutility.autoTaskListApiUrl,
        jsonEncode(jsonBody),
        context,
      );

      log('API Response (offset: $_offset): $response');

      if (response != null &&
          response.isNotEmpty &&
          response[0] is AutoTaskResponse) {
        List<AutoTaskResponse> taskResponses =
            response.cast<AutoTaskResponse>();
        if (taskResponses[0].status == "true") {
          setState(() {
            if (taskResponses[0].data.isEmpty) {
              _hasMore = false;
              log('No more data: data is empty');
            } else {
              _tasks.addAll(taskResponses[0].data);
              _offset += _limit;
              log(
                'Added ${taskResponses[0].data.length} tasks, new offset: $_offset',
              );
            }
          });
          if (_offset == 0) {
            Utils.flushBarErrorMessage("Success: ${taskResponses[0].message}", context, status: "s");
            
          }
        } else {
          setState(() {
            _hasMore = false;
            log('Error response: ${taskResponses[0].message}');
          });
          Utils.flushBarErrorMessage(
            "Error:  ${taskResponses[0].message}",
            context,
            status: "e"
          );
        }
      } else {
        Utils.flushBarErrorMessage(
          "Error:  No response from server. Please try again.",
          context,
          status: "e"
        );

        setState(() {
          _hasMore = false;
          log('No response from server');
        });
      }
    } catch (e) {
      Utils.flushBarErrorMessage("Error:  Unexpected error: $e", context,status: "e");
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

  // Get color based on task status
  Color _getStatusColor(String status) {
    switch (status) {
      case '1': // Pending
        return Colors.orange.shade300;
      case '2': // Completed
        return Colors.green;
      default:
        return Colors.grey.shade300;
    }
  }

  // Map task head to readable label (assuming orderDepartment represents task type)
  String _getTaskHeadLabel(String taskHead) {
    switch (taskHead) {
      case '1':
        return 'Create Order';
      case '2':
        return 'Production Schedule';
      case '3':
        return 'Maintenance';
      default:
        return taskHead; // Return original value if not mapped
    }
  }

  // Map task status to readable label
  String _getTaskStatusLabel(String status) {
    switch (status) {
      case '1':
        return 'Pending';
      case '2':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  // Map task action to readable label
  String _getTaskActionLabel(String? action) {
    switch (action) {
      case '1':
        return 'Forward to other Department/Person';
      case '2':
        return 'Mark as Closed';
      default:
        return 'Unknown';
    }
  }

  // Handle refresh
  Future<void> _onRefresh() async {
    setState(() {
      _tasks.clear();
      _offset = 0;
      _hasMore = true;
      log('Refreshing: cleared tasks, reset offset');
    });
    await fetchTasks();
  }

  //filter sheet
  void _showFilterBottomSheet() {
    String? selectedtaskDepartment =
        _departmentNameFilter.isNotEmpty ? _statusFilter : null;
    final TextEditingController fromDateController = TextEditingController(
      text: _fromDateFilter,
    );
    final TextEditingController toDateController = TextEditingController(
      text: _toDateFilter,
    );
    String? selectedAction =
        _taskActonFilter.isNotEmpty ? _taskActonFilter : null;
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
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Task Action',
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
                                status == '1'
                                    ? 'Forword to other Department/Person'
                                    : "Mark as Closed",
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
                          selectedAction = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Task Status',
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
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Task Department',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      value: selectedtaskDepartment,
                      items:
                          ['1', '2', '3'].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                status == '1'
                                    ? 'Create Order'
                                    : status == '2'
                                    ? 'Prodction Schedule'
                                    : 'Maintenance',
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
                          selectedtaskDepartment = value;
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
                                _departmentNameFilter = '';
                                _taskActonFilter = '';

                                _fromDateFilter = '';
                                _toDateFilter = '';
                                _statusFilter = '';
                                _tasks.clear();
                                _offset = 0;
                                _hasMore = true;
                              });
                              Navigator.pop(context);
                              fetchTasks();
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
                                _departmentNameFilter =
                                    selectedtaskDepartment ?? '';
                                _taskActonFilter = selectedAction ?? '';
                                _fromDateFilter = fromDateController.text;
                                _toDateFilter = toDateController.text;
                                _statusFilter = selectedStatus ?? '';
                                _tasks.clear();
                                _offset = 0;
                                _hasMore = true;
                              });
                              Navigator.pop(context);
                              fetchTasks();
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
      itemCount: _limit, // Match shimmer count to limit
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
        return false; // Return false if dialog is dismissed
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Auto Task List',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
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

        body: Column(
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
                        : _tasks.isEmpty
                        ? const Center(
                          child: Text(
                            'No tasks available',
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
                          itemCount: _tasks.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _tasks.length && _isLoadingMore) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final task = _tasks[index];
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
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          width: 8,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                              task.taskStatus,
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
                                                    'SR No: ${index + 1}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Task ID: ${task.taskId}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'ID: ${task.id}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Employee Name: ${task.employeeName}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Department: ${_getTaskHeadLabel(task.orderDepartment)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                  backgroundColor:
                                                      Colors.grey.shade100,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Date: ${task.date}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Action: ${_getTaskActionLabel(task.taskAction)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Task Status: ${_getTaskStatusLabel(task.taskStatus)}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: _getStatusColor(
                                                        task.taskStatus,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: IconButton(
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Colors.blue,
                                                            size: 24,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => TaskEditForm(
                                                                      taskId:
                                                                          task.id,
                                                                      page: '0',
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        width:
                                                            80, // Increased width for text visibility
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            // Add log action here
                                                          },
                                                          child: const Text(
                                                            'Log',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
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
      ),
    );
  }
}
