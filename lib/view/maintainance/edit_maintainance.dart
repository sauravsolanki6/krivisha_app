import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:krivisha_app/utility/app_routes.dart';
import 'package:krivisha_app/utility/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:krivisha_app/utility/app_colors.dart';

import '../../controller/maintenance/maintenance_controller.dart';
import '../../core/urls.dart';
import '../../model/maintenance/maintenance_response.dart';

class EditMaintainance extends StatefulWidget {
  const EditMaintainance({super.key});

  @override
  State<EditMaintainance> createState() => _EditMaintenancePageState();
}

class _EditMaintenancePageState extends State<EditMaintainance> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isToDateEnabled = false;
  String? selectedPlant;
  String? selectedPlantId;
  String? selectedMaintenanceType;
  String? selectedMaintenanceRequired;
  String? selectedSubcategory;
  String? selectedSubcategoryId;
  String? selectedSubcategoryTypeId;
  List<String> selectedProblemIds = [];
  String? employeeId;
  int? maintenanceTypeId;
  int? maintenanceRequiredId;
  List<Map<String, dynamic>> plants = [];
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> problems = [];
  bool isLoadingPlants = false;
  bool isLoadingSubcategories = false;
  bool isLoadingProblems = false;
  Maintenance? maintenance;

  final Map<String, int> maintenanceTypeMap = {
    "Emergency": 1,
    "Online Breakdown": 2,
    "Preventive": 3,
    "Outside Work": 4,
    "General": 5,
  };

  final Map<String, int> maintenanceRequiredMap = {
    "Machine": 1,
    "Mould/Article Name": 2,
    "Printing Unit": 3,
    "Plant": 4,
    "Other": 5,
  };

  @override
  void initState() {
    super.initState();
    _fromDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _loadEmployeeData();
    isToDateEnabled = true;
    _fetchPlants();
    _loadMaintenanceData();
  }

  Future<void> _loadMaintenanceData() async {
    try {
      final MaintenanceController maintenanceController =
          Get.find<MaintenanceController>();
      maintenance = maintenanceController.selectedMaintenance.value;

      if (maintenance != null) {
        print('--- Maintenance Data ---');
        print('ID: ${maintenance!.id}');
        print('MWO Code: ${maintenance!.mwoCode}');
        print('Plant ID: ${maintenance!.plantId}');
        print('Plant Name: ${maintenance!.plantName}');
        print('Employee ID: ${maintenance!.employeeId}');
        print('Employee Name: ${maintenance!.firstName}');
        print('Date: ${maintenance!.date}');
        print('Type of Action: ${maintenance!.typeOfAction}');
        print('Maintenance: ${maintenance!.maintenance}');
        print('Maintenance Type: ${maintenance!.maintenanceType}');
        print('Type Name: ${maintenance!.typeName}');
        print('Sub Type ID: ${maintenance!.subTypeId}');
        print('Problem ID: ${maintenance!.problemId}');
        print('Problems: ${maintenance!.problems}');
        print('Status: ${maintenance!.status}');
        print('Created On: ${maintenance!.createdOn}');
        print('Updated On: ${maintenance!.updatedOn}');
        print('Is Deleted: ${maintenance!.isDeleted}');
        print('-----------------------');

        setState(() {
          _fromDateController.text =
              maintenance!.date.isNotEmpty
                  ? maintenance!.date
                  : DateFormat('dd-MM-yyyy').format(DateTime.now());

          _employeeNameController.text =
              maintenance!.firstName ?? _employeeNameController.text;
          employeeId = maintenance!.employeeId ?? employeeId;

          selectedPlant = maintenance!.plantName;
          selectedPlantId = maintenance!.plantId?.toString();

          selectedMaintenanceType =
              maintenanceTypeMap.entries
                  .firstWhere(
                    (entry) =>
                        entry.value.toString() == maintenance!.typeOfAction,
                    orElse: () => const MapEntry('Select a type', 0),
                  )
                  .key;
          maintenanceTypeId = maintenanceTypeMap[selectedMaintenanceType];

          selectedMaintenanceRequired =
              maintenanceRequiredMap.entries
                  .firstWhere(
                    (entry) =>
                        entry.value.toString() ==
                        maintenance!.maintenance.toString(),
                    orElse:
                        () => const MapEntry('Select maintenance required', 0),
                  )
                  .key;
          maintenanceRequiredId =
              maintenanceRequiredMap[selectedMaintenanceRequired];

          selectedSubcategory = maintenance!.typeName;
          selectedSubcategoryId = maintenance!.subTypeId;

          // Initialize problems from maintenance data
          if (maintenance!.problemId.isNotEmpty &&
              maintenance!.problems.isNotEmpty) {
            selectedProblemIds = maintenance!.problemId.split(',');
            final problemNames =
                maintenance!.problems.split(',').map((e) => e.trim()).toList();
            problems = List.generate(
              selectedProblemIds.length,
              (index) => {
                'id': selectedProblemIds[index],
                'problem':
                    index < problemNames.length ? problemNames[index] : '',
              },
            );
          }

          if (maintenanceRequiredId != null && maintenanceRequiredId != 0) {
            _fetchSubcategories(maintenanceRequiredId!);
          }
        });
      } else {
        print('No Maintenance data found in MaintenanceController');
      }
    } catch (e) {
      print('Error loading Maintenance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading maintenance data: $e')),
      );
    }
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? fname = prefs.getString('name');
    String? id = prefs.getString('id');

    setState(() {
      _employeeNameController.text = fname ?? "Unknown Employee";
      employeeId = id;
    });
  }

  Future<void> _fetchPlants() async {
    setState(() {
      isLoadingPlants = true;
    });
    try {
      final response = await http.get(Uri.parse(Networkutility.getAllPlant));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            plants = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoadingPlants = false;
          });
        } else {
          throw Exception('API returned false status');
        }
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      setState(() {
        isLoadingPlants = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching plants: $e')));
    }
  }

  Future<void> _fetchSubcategories(int maintenanceRequiredId) async {
    setState(() {
      isLoadingSubcategories = true;
      subcategories = [];
      selectedSubcategory = maintenance!.typeName;
      selectedSubcategoryId = maintenance!.subTypeId;
      selectedSubcategoryTypeId = null;
      problems = [];
      selectedProblemIds =
          maintenance!.problemId.isNotEmpty
              ? maintenance!.problemId.split(',')
              : [];
      if (maintenance!.problems.isNotEmpty) {
        final problemNames =
            maintenance!.problems.split(',').map((e) => e.trim()).toList();
        problems = List.generate(
          selectedProblemIds.length,
          (index) => {
            'id': selectedProblemIds[index],
            'problem': index < problemNames.length ? problemNames[index] : '',
          },
        );
      }
    });

    try {
      final requestBody = {'maintenance_id': maintenanceRequiredId.toString()};
      final response = await http.post(
        Uri.parse(Networkutility.getSubcategoryMaintenanceApi),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            subcategories = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoadingSubcategories = false;

            if (maintenance!.typeName.isNotEmpty) {
              final selectedSub = subcategories.firstWhere(
                (subcategory) =>
                    _getDisplayName(subcategory) == maintenance!.typeName,
                orElse: () => {'id': null, 'type_id': null},
              );
              selectedSubcategory = maintenance!.typeName;
              selectedSubcategoryId =
                  selectedSub['id']?.toString() ?? maintenance!.subTypeId;
              selectedSubcategoryTypeId = selectedSub['type_id']?.toString();
            }
          });
        } else {
          throw Exception('API returned false status');
        }
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      setState(() {
        isLoadingSubcategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subcategories: $e')),
      );
    }
  }

  Future<void> _fetchProblems(int maintenanceId, String typeId) async {
    setState(() {
      isLoadingProblems = true;
      problems = [];
      selectedProblemIds =
          maintenance!.problemId.isNotEmpty
              ? maintenance!.problemId.split(',')
              : [];
    });

    try {
      final requestBody = {
        'maintenance_id': maintenanceId.toString(),
        'selected_type': typeId,
      };

      print('Request URL: ${Networkutility.getDetailsAsPer}');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(Networkutility.getDetailsAsPer),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            problems = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoadingProblems = false;

            if (maintenance!.problems.isNotEmpty) {
              final problemNames =
                  maintenance!.problems
                      .split(',')
                      .map((e) => e.trim())
                      .toList();
              selectedProblemIds =
                  problems
                      .where(
                        (problem) =>
                            problemNames.contains(problem['problem'] ?? ''),
                      )
                      .map((problem) => (problem['id'] ?? '').toString())
                      .where((id) => id.isNotEmpty)
                      .toList();
              print('Selected Problem IDs after fetch: $selectedProblemIds');
              print('Selected Problems: $problemNames');
            }
          });
        } else {
          throw Exception('API returned false status: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load problems');
      }
    } catch (e) {
      setState(() {
        isLoadingProblems = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching problems: $e')));
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        _fromDateController.text = formattedDate;
        isToDateEnabled = true;
      });
    }
  }

  String _getDisplayName(Map<String, dynamic> subcategory) {
    if (subcategory.containsKey('machine_name') &&
        subcategory['machine_name'] != null) {
      return subcategory['machine_name'] as String;
    } else if (subcategory.containsKey('article_name') &&
        subcategory['article_name'] != null) {
      return subcategory['article_name'] as String;
    } else if (subcategory.containsKey('plant_name') &&
        subcategory['plant_name'] != null) {
      return subcategory['plant_name'] as String;
    }
    return 'Other';
  }

  String _convertDateFormat(String date) {
    try {
      final inputFormat = DateFormat('dd-MM-yyyy');
      final outputFormat = DateFormat('yyyy-MM-dd');
      final parsedDate = inputFormat.parse(date);
      return outputFormat.format(parsedDate);
    } catch (e) {
      print('Error converting date: $e');
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _employeeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offNamed(AppRoutes.maintainanceList);
        return false; // Return false if dialog is dismissed
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Edit Maintenance'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.offNamed(AppRoutes.maintainanceList);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 5),
                isLoadingPlants
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search items...",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      items:
                          plants
                              .map((plant) => plant['plant_name'] as String)
                              .toList(),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select a Plant",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(6.0),
                            ),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedPlant = value;
                          selectedPlantId =
                              plants
                                  .firstWhere(
                                    (plant) => plant['plant_name'] == value,
                                    orElse: () => {'id': null},
                                  )['id']
                                  ?.toString();
                        });
                      },
                      selectedItem: selectedPlant ?? "Select a Plant",
                      validator: (value) {
                        if (value == null || value == "Select a Plant") {
                          return 'Please select a plant';
                        }
                        return null;
                      },
                    ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _fromDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _employeeNameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    suffixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an employee name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search items...",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  items: maintenanceTypeMap.keys.toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select a Maintenance Type",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedMaintenanceType = value;
                      maintenanceTypeId =
                          value != null ? maintenanceTypeMap[value] : null;
                    });
                  },
                  selectedItem: selectedMaintenanceType ?? "Select a type",
                  validator: (value) {
                    if (value == null || value == "Select a type") {
                      return 'Please select a maintenance type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search items...",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  items: maintenanceRequiredMap.keys.toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select a Maintenance Required",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedMaintenanceRequired = value;
                      maintenanceRequiredId =
                          value != null ? maintenanceRequiredMap[value] : null;
                      if (maintenanceRequiredId != null) {
                        _fetchSubcategories(maintenanceRequiredId!);
                      }
                    });
                  },
                  selectedItem:
                      selectedMaintenanceRequired ??
                      "Select maintenance required",
                  validator: (value) {
                    if (value == null ||
                        value == "Select maintenance required") {
                      return 'Please select a maintenance required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                isLoadingSubcategories
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search items...",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      items: subcategories.map(_getDisplayName).toList(),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select a Subcategory Maintenance",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(6.0),
                            ),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      onChanged: (value) async {
                        setState(() {
                          selectedSubcategory = value;
                          final selectedSub = subcategories.firstWhere(
                            (subcategory) =>
                                _getDisplayName(subcategory) == value,
                            orElse: () => {'id': null, 'type_id': null},
                          );
                          selectedSubcategoryId = selectedSub['id']?.toString();
                          selectedSubcategoryTypeId =
                              selectedSub['type_id']?.toString();
                        });
                        if (maintenanceRequiredId != null &&
                            selectedSubcategoryTypeId != null) {
                          await _fetchProblems(
                            maintenanceRequiredId!,
                            selectedSubcategoryTypeId!,
                          );
                        }
                      },
                      selectedItem:
                          selectedSubcategory ??
                          maintenance!.typeName ??
                          "Select Subcategory Maintenance",
                      validator: (value) {
                        if (value == null ||
                            value == "Select Subcategory Maintenance") {
                          return 'Please select a subcategory maintenance';
                        }
                        return null;
                      },
                    ),
                const SizedBox(height: 16),
                isLoadingProblems
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownSearch<String>.multiSelection(
                      popupProps: const PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search problems...",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      items:
                          problems
                              .map(
                                (problem) =>
                                    (problem['problem'] ?? '') as String,
                              )
                              .toList(),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select Detail as per",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(6.0),
                            ),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      onChanged: (List<String> values) {
                        setState(() {
                          selectedProblemIds =
                              problems
                                  .where(
                                    (problem) => values.contains(
                                      problem['problem'] ?? '',
                                    ),
                                  )
                                  .map(
                                    (problem) =>
                                        (problem['id'] ?? '').toString(),
                                  )
                                  .where((id) => id.isNotEmpty)
                                  .toList();
                          print(
                            'Updated Selected Problem IDs: $selectedProblemIds',
                          );
                        });
                      },
                      selectedItems:
                          problems
                              .where(
                                (problem) => selectedProblemIds.contains(
                                  (problem['id'] ?? '').toString(),
                                ),
                              )
                              .map(
                                (problem) =>
                                    (problem['problem'] ?? '') as String,
                              )
                              .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select at least one detail';
                        }
                        return null;
                      },
                    ),
                const SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        final jsonOutput = {
                          'update_id': maintenance!.id ?? '',
                          'plant_id':
                              selectedPlantId !=
                                      maintenance!.plantId?.toString()
                                  ? selectedPlantId ??
                                      maintenance!.plantId?.toString() ??
                                      ''
                                  : maintenance!.plantId?.toString() ?? '',
                          'date':
                              _fromDateController.text != maintenance!.date
                                  ? _convertDateFormat(_fromDateController.text)
                                  : maintenance!.date.isNotEmpty
                                  ? _convertDateFormat(maintenance!.date)
                                  : _convertDateFormat(
                                    DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(DateTime.now()),
                                  ),
                          'employee_id':
                              employeeId != maintenance!.employeeId
                                  ? employeeId ?? maintenance!.employeeId ?? ''
                                  : maintenance!.employeeId ?? '',
                          'maintenance_type':
                              maintenanceTypeId?.toString() !=
                                      maintenance!.typeOfAction
                                  ? maintenanceTypeId?.toString() ??
                                      maintenance!.typeOfAction ??
                                      ''
                                  : maintenance!.typeOfAction ?? '',
                          'maintenance_required':
                              maintenanceRequiredId?.toString() !=
                                      maintenance!.maintenance.toString()
                                  ? maintenanceRequiredId?.toString() ??
                                      maintenance!.maintenance.toString() ??
                                      ''
                                  : maintenance!.maintenance.toString() ?? '',
                          'sub_category':
                              selectedSubcategoryId != maintenance!.subTypeId
                                  ? selectedSubcategoryId ??
                                      maintenance!.subTypeId ??
                                      ''
                                  : maintenance!.subTypeId ?? '',
                          'details':
                              selectedProblemIds.toString() !=
                                      (maintenance!.problemId
                                              ?.split(',')
                                              .map((e) => e.trim())
                                              .toList()
                                              .toString() ??
                                          '')
                                  ? selectedProblemIds
                                  : maintenance!.problemId
                                          ?.split(',')
                                          .map((e) => e.trim())
                                          .toList() ??
                                      [],
                        };

                        final encodedBody = json.encode(jsonOutput);
                        print('--- REQUEST BODY ---\n$encodedBody\n');

                        try {
                          final response = await http.post(
                            Uri.parse(Networkutility.setMaintainanceApi),
                            headers: {'Content-Type': 'application/json'},
                            body: encodedBody,
                          );

                          print('Status Code: ${response.statusCode}');
                          log('Body: ${response.body}');

                          if (response.statusCode == 200) {
                            final jsonData = json.decode(response.body);
                            if (jsonData['status'] == 'true') {
                              Utils.flushBarErrorMessage(
                                "Maintenance data updated successfully!",
                                context,
                                status: "s",
                              );
                              try {
                                await Get.toNamed(AppRoutes.maintainanceList);
                              } catch (e) {
                                print('Navigation error: $e');
                                Utils.flushBarErrorMessage(
                                  "Navigation failed: $e",
                                  context,
                                  status: "e",
                                );
                              }
                            } else {
                              Utils.flushBarErrorMessage(
                                "Submission failed: ${jsonData['message'] ?? 'Unknown error'}",
                                context,
                                status: "e",
                              );
                            }
                          } else {
                            Utils.flushBarErrorMessage(
                              "Failed to update data: HTTP ${response.statusCode}",
                              context,
                              status: "e",
                            );
                          }
                        } catch (e) {
                          Utils.flushBarErrorMessage(
                            "Error updating data: $e",
                            context,
                            status: "e",
                          );
                        }
                      } else {
                        Utils.snackBar(
                          'Please fill all required fields',
                          context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 249, 241, 237),
      ),
    );
  }
}
