import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:krivisha_app/controller/tasks/add_task_controller.dart';
import 'package:krivisha_app/utility/app_routes.dart';
import 'package:krivisha_app/utility/app_utility.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final controller = Get.put(AddTaskController());
  final remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _partyName;
  late final List<String> _taskHeads;
  String? _taskHead;
  int? _taskHeadId;
  DateTime? _deadlineDate;
  TimeOfDay? _deadlineTime;
  String? _priority;
  String? _remark;
  String? _departmentName;
  String? _teamMemberName;
  String? formattedDate;
  String? formattedTime;
  String? _departmentID;
  String? _memberID;

  final Map<String, int> items = {
    'Enquiry': 1,
    'Cold Call': 2,
    'Office Requirement': 3,
    'Self Task': 4,
    'Complaint': 5,
  };

  String? selectedKey;
  String? _selectedTaskHead;
  int? _selectedTaskHeadId;
  final List<String> _parties = ['Rahul Sharma', 'Priya Patel', 'Amit Kumar'];
  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final Map<String, int> _priorityIds = {'High': 1, 'Medium': 2, 'Low': 3};
  int? _priorityId;
  final List<String> _departments = ['Sales', 'Support', 'Admin'];
  final Map<String, List<String>> _teamMembers = {
    'Sales': ['Vikram Singh', 'Anjali Gupta', 'Rohit Sharma'],
    'Support': ['Suresh Nair', 'Pooja Desai', 'Neha Kapoor'],
    'Admin': ['Arjun Patel', 'Kavita Joshi'],
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != _deadlineDate) {
      setState(() {
        _deadlineDate = picked;
        formattedDate = DateFormat('dd-MM-yyyy').format(_deadlineDate!);
        log(formattedDate!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _deadlineTime) {
      setState(() {
        _deadlineTime = picked;
        formattedTime =
            '${_deadlineTime!.hour.toString().padLeft(2, '0')}:${_deadlineTime!.minute.toString().padLeft(2, '0')}';
        log(formattedTime!);
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _formKey.currentState?.reset();
      selectedKey = null;
      _partyName = null;
      _deadlineDate = null;
      _deadlineTime = null;
      _priority = null;
      _priorityId = null;
      remarkController.clear();
      _departmentName = null;
      _teamMemberName = null;
      _departmentID = null;
      _memberID = null;
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void initState() {
    super.initState();
    _taskHeads = items.keys.toList(); // Initialize task heads
  }

  @override
  Widget build(BuildContext context) {
    print(AppUtility.empID);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.manualtaskList);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white),
            ),
            child: Text(
              'Task List',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.manualtaskList);
          //   },
          //   icon: Icon(Icons.list),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 16),
                // 1. Task Head Dropdown
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    fit: FlexFit.loose,
                  ),
                  items: items.keys.toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Task Head',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      selectedKey = value;
                      _taskHeadId = value != null ? items[value] : null;
                      if (_taskHeadId != null) {
                        print('Selected Task Head: $value, ID: $_taskHeadId');
                        if (_taskHeadId == 1) {
                          print('Enquiry selected (ID = 1)');
                        }
                      }
                    });
                  },
                  selectedItem: selectedKey,
                  validator:
                      (value) =>
                          value == null ? 'Please select a task head' : null,
                ),
                const SizedBox(height: 16),

                // 2. Party Name Dropdown
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      fit: FlexFit.loose,
                    ),
                    items: controller.getPartyNames(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Party Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _partyName = value;
                        if (value != null) {
                          String partyId = controller.getPartyIdByName(value);
                          print('Selected Party ID: $partyId');
                        }
                      });
                    },
                    selectedItem: _partyName,
                    validator:
                        (value) =>
                            value == null ? 'Please select a party name' : null,
                  );
                }),
                const SizedBox(height: 16),

                // 3. Deadline Date Selector
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Complete By Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text:
                            _deadlineDate != null
                                ? '${_deadlineDate!.day}/${_deadlineDate!.month}/${_deadlineDate!.year}'
                                : '',
                      ),
                      validator:
                          (value) =>
                              _deadlineDate == null
                                  ? 'Please select a date'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Deadline Time Selector
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Complete By Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      controller: TextEditingController(
                        text:
                            _deadlineTime != null
                                ? _deadlineTime!.format(context)
                                : '',
                      ),
                      validator:
                          (value) =>
                              _deadlineTime == null
                                  ? 'Please select a time'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Priority Radio Buttons
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children:
                            _priorities
                                .map(
                                  (priority) => Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        priority,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      value: priority,
                                      groupValue: _priority,
                                      onChanged: (value) {
                                        setState(() {
                                          _priority = value;
                                          _priorityId = _priorityIds[value];
                                          print(
                                            'Selected: $_priority ($_priorityId)',
                                          );
                                        });
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                          ),
                                      dense: true,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      if (_priority == null)
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 8.0),
                          child: Text(
                            'Please select a priority',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Remark/Comment Textbox (Optional, but adding min length if required)
                TextFormField(
                  controller: remarkController,
                  decoration: const InputDecoration(
                    labelText: 'Remark/Comment',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    _remark = value;
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 5) {
                      return 'Remark must be at least 5 characters long';
                    }
                    return null; // Optional field, so null if empty
                  },
                ),
                const SizedBox(height: 16),

                // 7. Department Dropdown
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      fit: FlexFit.loose,
                    ),
                    items: controller.getDepartmentNames(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Department Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _departmentName = value;
                        _teamMemberName = null;
                        _memberID = null;
                        if (value != null) {
                          _departmentID = controller.getDepartmentIdByName(
                            value,
                          );
                          print('Selected Department ID: $_departmentID');
                          controller.employees.clear();
                          controller.fetchEmployees(
                            context: context,
                            id: _departmentID,
                            reset: true,
                          );
                        }
                      });
                    },
                    selectedItem: _departmentName,
                    validator:
                        (value) =>
                            value == null ? 'Please select a department' : null,
                  );
                }),
                const SizedBox(height: 16),

                // 8. Team Member Dropdown
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      fit: FlexFit.loose,
                    ),
                    items: controller.getEmployeeNames(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Employee Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _teamMemberName = value;
                        if (value != null) {
                          _memberID = controller.getEmployeeIdByName(value);
                          print('Selected Employee ID: $_memberID');
                        }
                      });
                    },
                    selectedItem: _teamMemberName,
                    validator:
                        (value) =>
                            value == null ? 'Please select an employee' : null,
                  );
                }),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // All validations passed, proceed with submission
                      controller.AddTask(
                        context,
                        taskheadID:
                            selectedKey != null
                                ? items[selectedKey].toString()
                                : null,
                        partyID:
                            _partyName != null
                                ? controller.getPartyIdByName(_partyName!)
                                : null,
                        date: formattedDate,
                        time: formattedTime,
                        priorityID: _priorityId?.toString(),
                        remark: remarkController.text,
                        depID: _departmentID,
                        teamID: _memberID,
                      );
                    } else {
                      // Show error message to user
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
