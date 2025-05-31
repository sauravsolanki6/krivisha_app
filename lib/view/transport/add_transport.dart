import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';

import '../../utility/app_routes.dart';

class AddTransport extends StatefulWidget {
  const AddTransport({super.key});

  @override
  _AddTransportState createState() => _AddTransportState();
}

class _AddTransportState extends State<AddTransport> {
  final _formKey = GlobalKey<FormState>();

  // Sample data for dropdowns (replace with your actual data source)
  final List<String> orderIds = ['ORD001', 'ORD002', 'ORD003'];
  final List<String> divisions = ['Division A', 'Division B', 'Division C'];
  final List<String> parties = ['Party 1', 'Party 2', 'Party 3'];
  final List<String> locations = ['Location A', 'Location B', 'Location C'];
  final List<String> pincodes = ['400001', '400002', '400003'];
  final List<String> transports = ['Transport A', 'Transport B', 'Transport C'];

  // Controllers for text fields
  final _dcNoController = TextEditingController();
  final _invoiceNoController = TextEditingController();
  final _invoiceValueController = TextEditingController();
  final _freightAmountController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverMobileController = TextEditingController();
  final _freightPaymentStatusController = TextEditingController();
  final _remarkController = TextEditingController();

  @override
  void dispose() {
    _dcNoController.dispose();
    _invoiceNoController.dispose();
    _invoiceValueController.dispose();
    _freightAmountController.dispose();
    _vehicleController.dispose();
    _vehicleNoController.dispose();
    _driverNameController.dispose();
    _driverMobileController.dispose();
    _freightPaymentStatusController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Add Transport',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.toNamed(AppRoutes.transportList);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white),
            ),
            child: Text(
              'Transport List',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.transportList);
          //   },
          //   icon: Icon(Icons.list),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionContainer(
                title: 'Order Details',
                children: [
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: orderIds,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Order ID *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {},
                    validator:
                        (value) =>
                            value == null ? 'Order ID is required' : null,
                    selectedItem: orderIds.first,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dcNoController,
                    decoration: const InputDecoration(
                      labelText: 'DC No *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'DC No is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _invoiceNoController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice No *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invoice No is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: divisions,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Division *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {},
                    validator:
                        (value) =>
                            value == null ? 'Division is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: parties,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Party *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {},
                    validator:
                        (value) => value == null ? 'Party is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _invoiceValueController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Value *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invoice Value is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _freightAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Freight Amount *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Freight Amount is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionContainer(
                title: 'Location Details',
                children: [
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: locations,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Location *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {},
                    validator:
                        (value) =>
                            value == null ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: pincodes,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Pincode *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {},
                    validator:
                        (value) => value == null ? 'Pincode is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionContainer(
                title: 'Transport Details',
                children: [
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    items: transports,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Transport *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {},
                    validator:
                        (value) =>
                            value == null ? 'Transport is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vehicle is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleNoController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle No *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vehicle No is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _driverNameController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Driver Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _driverMobileController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Mobile *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Driver Mobile is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _freightPaymentStatusController,
                    decoration: const InputDecoration(
                      labelText: 'Freight Payment Status *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Freight Payment Status is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionContainer(
                title: 'Additional Information',
                children: [
                  TextFormField(
                    controller: _remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form submitted successfully'),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Light background with primary color
        border: Border.all(color: Colors.grey), // Border with primary color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(
                      context,
                    ).primaryColor, // Title text with primary color
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
