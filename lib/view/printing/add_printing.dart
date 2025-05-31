import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import '../../utility/app_routes.dart';

class AddPrinting extends StatefulWidget {
  const AddPrinting({super.key});

  @override
  _AddPrintingState createState() => _AddPrintingState();
}

class _AddPrintingState extends State<AddPrinting> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _1_inkconsumedController =
      TextEditingController();
  final TextEditingController _1_qty1inkconsumedController =
      TextEditingController();
  final TextEditingController _2_inkconsumedController =
      TextEditingController();
  final TextEditingController _2_qty11inkconsumedController =
      TextEditingController();
  final TextEditingController _3_inkconsumedController =
      TextEditingController();
  final TextEditingController _3_qty11inkconsumedController =
      TextEditingController();
  final TextEditingController _4_inkconsumedController =
      TextEditingController();
  final TextEditingController _4_qty11inkconsumedController =
      TextEditingController();
  final TextEditingController _5_inkconsumedController =
      TextEditingController();
  final TextEditingController _5_qty11inkconsumedController =
      TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController howManycolourController = TextEditingController();
  final TextEditingController otherMaterial1Controller =
      TextEditingController();
  final TextEditingController otherMaterialQty1Controller =
      TextEditingController();
  final TextEditingController otherMaterial2Controller =
      TextEditingController();
  final TextEditingController otherMaterialQty2Controller =
      TextEditingController();

  String? selectedReportingData;
  String? id;
  final List<String> reportingOptions = ['Job', 'Material'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        id = prefs.getString('id') ?? '';
      });
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load user data')));
    }
  }

  // Common InputDecoration with darker borders
  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[500],
        fontWeight: FontWeight.w300,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[600]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[600]!, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 10.0,
      ),
    );
  }

  // Reusable ink field widget
  Widget _buildInkField({
    required TextEditingController controller,
    required TextEditingController qtyController,
    required String label,
    required int index,
    required bool isRequired,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(
            label: 'Ink Consumed $index (Shade Code)',
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Enter Ink Consumed $index';
            }
            return null;
          },
        ),
        const SizedBox(height: 12.0),
        TextFormField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(
            label: 'Qty $index (Ink Consumed $index)',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Enter Qty $index';
            }
            if (value != null && value.isNotEmpty && controller.text.isEmpty) {
              return 'Please enter Shade Code for Qty $index';
            }
            return null;
          },
        ),
        const SizedBox(height: 12.0),
      ],
    );
  }

  // Reusable material field widget
  Widget _buildMaterialField({
    required TextEditingController controller,
    required TextEditingController qtyController,
    required String label,
    required int index,
    required bool isRequired,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(
            label: 'Other Material $index (Material Name)',
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Enter Other Material $index';
            }
            return null;
          },
        ),
        const SizedBox(height: 12.0),
        TextFormField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(label: 'Other Material Qty $index'),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Enter Other Material Qty $index';
            }
            if (value != null && value.isNotEmpty && controller.text.isEmpty) {
              return 'Please enter Material Name for Qty $index';
            }
            return null;
          },
        ),
        const SizedBox(height: 12.0),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'user_id': id,
        'reporting_type': selectedReportingData,
        'inks':
            [
              {
                'shade_code': _1_inkconsumedController.text,
                'quantity': _1_qty1inkconsumedController.text,
              },
              {
                'shade_code': _2_inkconsumedController.text,
                'quantity': _2_qty11inkconsumedController.text,
              },
              {
                'shade_code': _3_inkconsumedController.text,
                'quantity': _3_qty11inkconsumedController.text,
              },
              {
                'shade_code': _4_inkconsumedController.text,
                'quantity': _4_qty11inkconsumedController.text,
              },
              {
                'shade_code': _5_inkconsumedController.text,
                'quantity': _5_qty11inkconsumedController.text,
              },
            ].where((ink) => ink['shade_code']!.isNotEmpty).toList(),
        if (selectedReportingData == 'Material') ...{
          'other_materials':
              [
                    {
                      'material_name': otherMaterial1Controller.text,
                      'quantity': otherMaterialQty1Controller.text,
                    },
                    {
                      'material_name': otherMaterial2Controller.text,
                      'quantity': otherMaterialQty2Controller.text,
                    },
                  ]
                  .where((material) => material['material_name']!.isNotEmpty)
                  .toList(),
        },
        if (selectedReportingData == 'Job') ...{
          'size': sizeController.text,
          'brand_name': brandNameController.text,
          'quantity': quantityController.text,
          'colours': howManycolourController.text,
        },
      };

      try {
        final response = await http.post(
          Uri.parse('https://your-api-endpoint.com/add_printing'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Printing data added successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add data: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Add Printing',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.printingReportList);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white),
            ),
            child: Text(
              'Printing List',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.printingReportList);
          //   },
          //   icon: Icon(Icons.list),
          // ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8.0),
              DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                items: reportingOptions,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: _inputDecoration(
                    label: 'Select a Reporting',
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedReportingData = value;
                  });
                },
                selectedItem: selectedReportingData ?? 'Please Select',
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value == 'Please Select') {
                    return 'Please select a reporting type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              _buildInkField(
                controller: _1_inkconsumedController,
                qtyController: _1_qty1inkconsumedController,
                label: 'Ink Consumed 1',
                index: 1,
                isRequired: true,
              ),
              _buildInkField(
                controller: _2_inkconsumedController,
                qtyController: _2_qty11inkconsumedController,
                label: 'Ink Consumed 2',
                index: 2,
                isRequired: false,
              ),
              _buildInkField(
                controller: _3_inkconsumedController,
                qtyController: _3_qty11inkconsumedController,
                label: 'Ink Consumed 3',
                index: 3,
                isRequired: false,
              ),
              _buildInkField(
                controller: _4_inkconsumedController,
                qtyController: _4_qty11inkconsumedController,
                label: 'Ink Consumed 4',
                index: 4,
                isRequired: false,
              ),
              _buildInkField(
                controller: _5_inkconsumedController,
                qtyController: _5_qty11inkconsumedController,
                label: 'Ink Consumed 5',
                index: 5,
                isRequired: false,
              ),
              if (selectedReportingData == 'Material') ...[
                _buildMaterialField(
                  controller: otherMaterial1Controller,
                  qtyController: otherMaterialQty1Controller,
                  label: 'Other Material 1',
                  index: 1,
                  isRequired: true,
                ),
                _buildMaterialField(
                  controller: otherMaterial2Controller,
                  qtyController: otherMaterialQty2Controller,
                  label: 'Other Material 2',
                  index: 2,
                  isRequired: false,
                ),
              ],

              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _1_inkconsumedController.dispose();
    _1_qty1inkconsumedController.dispose();
    _2_inkconsumedController.dispose();
    _2_qty11inkconsumedController.dispose();
    _3_inkconsumedController.dispose();
    _3_qty11inkconsumedController.dispose();
    _4_inkconsumedController.dispose();
    _4_qty11inkconsumedController.dispose();
    _5_inkconsumedController.dispose();
    _5_qty11inkconsumedController.dispose();
    sizeController.dispose();
    brandNameController.dispose();
    quantityController.dispose();
    howManycolourController.dispose();
    otherMaterial1Controller.dispose();
    otherMaterialQty1Controller.dispose();
    otherMaterial2Controller.dispose();
    otherMaterialQty2Controller.dispose();
    super.dispose();
  }
}
