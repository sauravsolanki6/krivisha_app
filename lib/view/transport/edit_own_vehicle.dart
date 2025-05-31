import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:krivisha_app/utility/app_routes.dart';

import '../../core/urls.dart';
import '../../model/transport/own_vehicle_response.dart';

class EditOwnVehicle extends StatefulWidget {
  final OwnVehicles? vehicle;
  const EditOwnVehicle({super.key, this.vehicle});

  @override
  State<EditOwnVehicle> createState() => _EditOwnVehicleState();
}

class _EditOwnVehicleState extends State<EditOwnVehicle> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text inputs
  final _challanController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _kmController = TextEditingController();
  final _marketfreightController = TextEditingController();
  final _dieselController = TextEditingController();
  final _driverexpController = TextEditingController();
  final _maintenanceController = TextEditingController();

  // Selected values
  String? _selectedVehicle;
  String? _selectedVehicleId;
  String? _selectedCity;
  String? _selectedCityId;
  String? _selectedPincode;
  String? _selectedPurpose;
  String? _selectedParty;
  String? _selectedPartyId;

  // Data for dropdowns
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _parties = [];
  final List<Map<String, dynamic>> _purposes = [
    {'id': 1, 'name': 'Delivery'},
    {'id': 2, 'name': 'Pick Up'},
    {'id': 3, 'name': 'Others'},
  ];

  // Store selected purpose IDs
  List<String> _selectedPurposeIds = [];

  @override
  void initState() {
    super.initState();
    // Autofill form with vehicle data if available
    if (widget.vehicle != null) {
      _selectedVehicleId = widget.vehicle!.vehicalId.toString();
      _selectedVehicle = widget.vehicle!.vehical;
      _challanController.text = widget.vehicle!.challanDcNo;
      _invoiceController.text = widget.vehicle!.invoiceNo;
      _selectedCityId = widget.vehicle!.locationId.toString();
      _selectedCity = widget.vehicle!.city;
      _selectedPincode = widget.vehicle!.pincode;
      _pincodeController.text = widget.vehicle!.pincode;
      _selectedPurposeIds =
          widget.vehicle!.purpose.split(',').map((e) => e.trim()).toList();
      _selectedPartyId = widget.vehicle!.partyId.toString();
      _selectedParty = widget.vehicle!.partyName;
      _kmController.text = widget.vehicle!.inKm.toString();
      _marketfreightController.text = widget.vehicle!.marketFreight.toString();
      _dieselController.text = widget.vehicle!.dieselTopup.toString();
      _driverexpController.text = widget.vehicle!.driverExpense.toString();
      _maintenanceController.text = widget.vehicle!.maintenance.toString();
    }
    _fetchVehicles();
    _fetchCities();
    _fetchParties();
  }

  @override
  void dispose() {
    _challanController.dispose();
    _invoiceController.dispose();
    _pincodeController.dispose();
    _kmController.dispose();
    _marketfreightController.dispose();
    _dieselController.dispose();
    _driverexpController.dispose();
    _maintenanceController.dispose();
    super.dispose();
  }

  // Fetch vehicles from API
  Future<void> _fetchVehicles() async {
    try {
      final response = await http.get(Uri.parse(Networkutility.getallVehicle));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            _vehicles = List<Map<String, dynamic>>.from(jsonData['data']);
          });
        } else {
          print('Vehicle API Error: ${jsonData['message']}');
        }
      } else {
        print('Vehicle HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  // Fetch cities from API
  Future<void> _fetchCities() async {
    try {
      final response =
          await http.get(Uri.parse(Networkutility.getallLocations));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            _cities = List<Map<String, dynamic>>.from(jsonData['data']);
          });
        } else {
          print('Location API Error: ${jsonData['message']}');
        }
      } else {
        print('Location HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  // Fetch parties from API
  Future<void> _fetchParties() async {
    try {
      final response = await http.get(Uri.parse(Networkutility.getAllParty));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            _parties = List<Map<String, dynamic>>.from(jsonData['data']);
          });
        } else {
          print('Party API Error: ${jsonData['message']}');
        }
      } else {
        print('Party HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching parties: $e');
    }
  }

  // Refresh handler
  Future<void> _handleRefresh() async {
    setState(() {
      _formKey.currentState?.reset();
      _selectedVehicle = null;
      _selectedVehicleId = null;
      _selectedCity = null;
      _selectedCityId = null;
      _selectedPincode = null;
      _selectedPurpose = null;
      _selectedParty = null;
      _selectedPartyId = null;
      _selectedPurposeIds.clear();
      _challanController.clear();
      _invoiceController.clear();
      _pincodeController.clear();
      _kmController.clear();
      _marketfreightController.clear();
      _dieselController.clear();
      _driverexpController.clear();
      _maintenanceController.clear();
    });
    await Future.wait([
      _fetchVehicles(),
      _fetchCities(),
      _fetchParties(),
    ]);
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Edit Own Vehicle Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: OutlinedButton(
              onPressed: () {
                Get.offNamed(AppRoutes.ownvehicleList);
                print('Navigate to own vehicle list');
              },
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 30),
              ),
              child: const Text(
                'Own Vehicle List',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                // Vehicle Dropdown with null validation
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  items: _vehicles
                      .map((vehicle) => vehicle['vehical'] as String)
                      .toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Vehicle *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicle = value;
                      _selectedVehicleId = _vehicles
                          .firstWhere(
                              (vehicle) => vehicle['vehical'] == value)['id']
                          .toString();
                    });
                    print('Selected Vehicle: $value, ID: $_selectedVehicleId');
                  },
                  selectedItem: _selectedVehicle,
                  validator: (value) =>
                      value == null ? 'Please select a vehicle' : null,
                ),
                const SizedBox(height: 16),
                // Challan DC No with null validation
                TextFormField(
                  controller: _challanController,
                  decoration: const InputDecoration(
                    labelText: 'Challan DC No *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Challan DC No';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Invoice No
                TextFormField(
                  controller: _invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice No *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Invoice No';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // City Dropdown
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  items: _cities.map((city) => city['city'] as String).toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select City *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      final selectedCityData = _cities.firstWhere(
                        (city) => city['city'] == value,
                        orElse: () => {},
                      );
                      _selectedCityId = selectedCityData['id']?.toString();
                      _selectedPincode =
                          selectedCityData['pincode']?.toString();
                      _pincodeController.text = _selectedPincode ?? '';
                    });
                    print(
                        'Selected City: $value, ID: $_selectedCityId, Pincode: $_selectedPincode');
                  },
                  selectedItem: _selectedCity,
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                ),
                const SizedBox(height: 16),
                // Pincode Field (Read-only)
                TextFormField(
                  controller: _pincodeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Selected Pincode *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a city to autofill pincode';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Purpose Dropdown
                DropdownSearch<String>.multiSelection(
                  popupProps: const PopupPropsMultiSelection.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search purposes...',
                      ),
                    ),
                  ),
                  items: _purposes
                      .map((purpose) => purpose['name'] as String)
                      .toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Purpose *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (List<String> selectedNames) {
                    setState(() {
                      _selectedPurposeIds = selectedNames
                          .map((name) => _purposes
                              .firstWhere(
                                  (purpose) => purpose['name'] == name)['id']
                              .toString())
                          .toList();
                    });
                    print('Selected Purpose IDs: $_selectedPurposeIds');
                  },
                  selectedItems: _selectedPurposeIds
                      .map((id) => _purposes.firstWhere((purpose) =>
                          purpose['id'].toString() == id)['name'] as String)
                      .toList(),
                  validator: (List<String>? value) {
                    return value == null || value.isEmpty
                        ? 'Please select at least one purpose'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                // Party Name Dropdown
                DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    fit: FlexFit.loose,
                  ),
                  items: _parties
                      .map((party) => party['party_name'] as String)
                      .toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Party Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedParty = value;
                      _selectedPartyId = _parties
                          .firstWhere(
                              (party) => party['party_name'] == value)['id']
                          .toString();
                    });
                    print('Selected Party: $value, ID: $_selectedPartyId');
                  },
                  selectedItem: _selectedParty,
                  validator: (value) =>
                      value == null ? 'Please select a party name' : null,
                ),
                const SizedBox(height: 16),
                // KM
                TextFormField(
                  controller: _kmController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'In KM *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter KM';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Market Freight
                TextFormField(
                  controller: _marketfreightController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Market Freight *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Market Freight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Diesel Top-up
                TextFormField(
                  controller: _dieselController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Diesel Top-up *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Diesel Top-up';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Driver Expenses
                TextFormField(
                  controller: _driverexpController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Driver Expenses *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Driver Expenses';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Maintenance
                TextFormField(
                  controller: _maintenanceController,
                  decoration: const InputDecoration(
                    labelText: 'Maintenance *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Maintenance';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                    height: 24), // Extra padding at the bottom for scroll
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Prepare the request body
              final requestBody = {
                "update_id": widget.vehicle?.id.toString() ??
                    "", // Pass vehicle id as update_id
                "vehical_id": _selectedVehicleId ?? "",
                "challan_dc_no": _challanController.text.trim(),
                "invoice_no": _invoiceController.text.trim(),
                "location_id": _selectedCityId ?? "",
                "pincode": _pincodeController.text.trim(),
                "purpose": _selectedPurposeIds,
                "party_id": _selectedPartyId ?? "",
                "in_km": _kmController.text.trim(),
                "market_freight": _marketfreightController.text.trim(),
                "diesel_topup": _dieselController.text.trim(),
                "driver_expense": _driverexpController.text.trim(),
                "maintenance": _maintenanceController.text.trim(),
              };

              try {
                // Make the POST request
                final response = await http.post(
                  Uri.parse(Networkutility.setOwnvehicle),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(requestBody),
                );

                // Print request body for debugging
                print('Request Body: ${jsonEncode(requestBody)}');

                // Handle response
                if (response.statusCode == 200) {
                  final responseData = jsonDecode(response.body);
                  print('Response Body: ${response.body}');

                  if (responseData['status'] == 'true') {
                    // Success: Navigate to own vehicle list
                    Get.offNamed(AppRoutes.ownvehicleList);
                    print('Success: ${responseData['message']}');

                    // Clear form
                    setState(() {
                      _formKey.currentState?.reset();
                      _selectedVehicle = null;
                      _selectedVehicleId = null;
                      _selectedCity = null;
                      _selectedCityId = null;
                      _selectedPincode = null;
                      _selectedPurposeIds.clear();
                      _selectedParty = null;
                      _selectedPartyId = null;
                      _challanController.clear();
                      _invoiceController.clear();
                      _pincodeController.clear();
                      _kmController.clear();
                      _marketfreightController.clear();
                      _dieselController.clear();
                      _driverexpController.clear();
                      _maintenanceController.clear();
                    });
                  } else {
                    // Handle API error
                    print('API Error: ${responseData['message']}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${responseData['message']}'),
                      ),
                    );
                  }
                } else {
                  // Handle HTTP error
                  print('HTTP Error: ${response.statusCode}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Server error: ${response.statusCode}'),
                    ),
                  );
                }
              } catch (e) {
                // Handle network or other errors
                print('Error submitting data: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error submitting data: $e')),
                );
              }
            } else {
              // Validation failed, show a general error message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all required fields'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Submit'),
        ),
      ),
    );
  }
}
