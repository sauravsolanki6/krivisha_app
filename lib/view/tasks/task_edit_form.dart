import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/urls.dart';
import 'auto_task_list.dart';
import 'mannual_task_list.dart';

class TaskEditForm extends StatefulWidget {
  final String taskId;
  final String page;

  const TaskEditForm({super.key, required this.taskId, required this.page});
  @override
  TaskEditFormState createState() => TaskEditFormState();
}

class TaskEditFormState extends State<TaskEditForm> {
  final _formKey = GlobalKey<FormState>();
  String? _status = 'Pending'; // Default to Pending
  String? _taskAction;
  String? _department;
  String? _assignTo;
  String? _departmentId;
  String? _employeeId;
  final TextEditingController _remarksController = TextEditingController();

  final List<String> statusOptions = ['Pending', 'Complete'];
  final List<String> taskActionOptions = [
    'Forward to Other Department',
    'Mark as Closed'
  ];
  List<String> departmentOptions = [];
  List<String> assignToOptions = [];
  List<Map<String, dynamic>> departmentData = [];
  List<Map<String, dynamic>> employeeData = [];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    try {
      final response = await http.get(
        Uri.parse(Networkutility.departmentApiUrl),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'true') {
          setState(() {
            departmentData = List<Map<String, dynamic>>.from(data['data']);
            departmentOptions = departmentData
                .map((dept) => dept['department'] as String)
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching departments: $e');
    }
  }

  Future<void> _fetchEmployees(String departmentId) async {
    try {
      final response = await http.post(
        Uri.parse(Networkutility.employeeApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'department_id': departmentId}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'true') {
          setState(() {
            employeeData = List<Map<String, dynamic>>.from(data['data']);
            assignToOptions =
                employeeData.map((emp) => emp['first_name'] as String).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_status == 'Pending' && _taskAction == 'Mark as Closed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot mark as complete when status is Pending'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Map status and task action to numeric values
      final statusMap = {'Pending': '1', 'Complete': '2'};
      final taskActionMap = {
        'Forward to Other Department': '1',
        'Mark as Closed': '2'
      };

      // Create JSON output
      final jsonOutput = {
        'id': widget.taskId,
        'auto_or_manual': widget.page,
        'task_status': statusMap[_status],
        'task_action': taskActionMap[_taskAction],
        'department_id': _departmentId ?? '',
        'team_member_id': _employeeId ?? '',
        'remark': _remarksController.text,
      };

      // Print request body
      print('Request Body: ${json.encode(jsonOutput)}');

      try {
        // Make API call to submit form
        final response = await http.post(
          Uri.parse(Networkutility.updateTaskApiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(jsonOutput),
        );

        // Parse and handle response
        final responseData = json.decode(response.body);
        print('Response Body: ${json.encode(responseData)}');

        if (response.statusCode == 200) {
          // Navigate based on auto_or_manual value
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  widget.page == '1' ? ManualTaskList() : AutoTaskList(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  responseData['message'] ?? 'Form submitted successfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to submit form'),
            ),
          );
        }
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting form')),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _status = 'Pending';
      _taskAction = null;
      _department = null;
      _assignTo = null;
      _departmentId = null;
      _employeeId = null;
      _remarksController.clear();
    });
    await _fetchDepartments();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Edit Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'Search Status',
                      ),
                    ),
                  ),
                  items: statusOptions,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Status',
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                  selectedItem: _status,
                ),
                const SizedBox(height: 16),
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'Search Task Action',
                      ),
                    ),
                  ),
                  items: taskActionOptions,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Task Action *',
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _taskAction = value;
                      if (value != 'Forward to Other Department') {
                        _department = null;
                        _assignTo = null;
                        _departmentId = null;
                        _employeeId = null;
                        assignToOptions = [];
                      }
                    });
                  },
                  selectedItem: _taskAction,
                  validator: (value) =>
                      value == null ? 'Task Action is required' : null,
                ),
                const SizedBox(height: 16),
                if (_taskAction == 'Forward to Other Department') ...[
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Search Department',
                        ),
                      ),
                    ),
                    items: departmentOptions,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Assign to Department *',
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _department = value;
                        final selectedDept = departmentData.firstWhere(
                          (dept) => dept['department'] == value,
                          orElse: () => {},
                        );
                        _departmentId = selectedDept['id'] as String?;
                        _assignTo = null;
                        _employeeId = null;
                        assignToOptions = [];
                        if (_departmentId != null) {
                          _fetchEmployees(_departmentId!);
                        }
                      });
                    },
                    selectedItem: _department,
                    validator: (value) =>
                        value == null ? 'Department is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Search Assignee',
                        ),
                      ),
                    ),
                    items: assignToOptions,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Assign To *',
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _assignTo = value;
                        final selectedEmp = employeeData.firstWhere(
                          (emp) => emp['first_name'] == value,
                          orElse: () => {},
                        );
                        _employeeId = selectedEmp['id'] as String?;
                      });
                    },
                    selectedItem: _assignTo,
                    validator: (value) =>
                        value == null ? 'Assign To is required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _remarksController,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
