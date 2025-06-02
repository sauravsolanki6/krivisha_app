import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddProduction extends StatefulWidget {
  const AddProduction({super.key});

  @override
  _AddProductionState createState() => _AddProductionState();
}

class _AddProductionState extends State<AddProduction> {
  final _formKey = GlobalKey<FormState>();

  // Sample data for dropdowns (replace with actual data sources)
  final List<String> machineTypes = ['Machine 1', 'Machine 2', 'Machine 3'];
  final List<String> articleGroups = ['Group A', 'Group B', 'Group C'];
  final List<String> articleNames = ['Article 1', 'Article 2', 'Article 3'];
  final List<String> rawMaterials = ['Material A', 'Material B', 'Material C'];
  final List<String> masterBatches = ['Batch 1', 'Batch 2', 'Batch 3'];
  final List<String> rejectionMaterials = ['Reject A', 'Reject B', 'Reject C'];

  String? selectedMachine;
  List<String> selectedArticleGroups = [];
  List<String> selectedArticleNames = [];
  List<String> selectedRawMaterials = [];
  List<String> selectedMasterBatches = [];
  List<String> selectedRejectionMaterials = [];
  DateTime? selectedDate;

  // Define color palette
  static const Color primaryColor = Color(0xFF1E88E5); // Blue
  static const Color accentColor = Color(0xFFFFA726); // Orange
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light Grey
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121); // Dark Grey
  static const Color hintColor = Color(0xFF757575); // Medium Grey
  static const Color borderColor = Color(0xFFCCCCCC); // Grey for borders

  // Method to handle refresh action
  Future<void> _handleRefresh() async {
    // Simulate a network call or data refresh with a delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Reset form fields
      selectedMachine = null;
      selectedArticleGroups = [];
      selectedArticleNames = [];
      selectedRawMaterials = [];
      selectedMasterBatches = [];
      selectedRejectionMaterials = [];
      selectedDate = null;
      _formKey.currentState?.reset();
    });

    // Optional: Show a snackbar to indicate refresh completion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Form refreshed!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Production',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: primaryColor, // Color of the refresh indicator
              backgroundColor: cardColor, // Background color of the indicator
              child: ListView(
                children: [
                  // Date Field
                  _buildDatePicker(),
                  const SizedBox(height: 20),

                  // Machine Type Dropdown (Single Selection)
                  _buildDropdownSearch(
                    label: 'Machine Type *',
                    hint: 'Choose a machine type',
                    items: machineTypes,
                    selectedItem: selectedMachine,
                    isMultiSelection: false,
                    onChangedSingle: (String? value) {
                      setState(() {
                        selectedMachine = value;
                      });
                    },
                    onChangedMulti: null,
                    validatorSingle: (String? value) =>
                        value == null ? 'Please select a machine type' : null,
                    validatorMulti: null,
                    icon: Icons.build,
                  ),
                  const SizedBox(height: 20),

                  // Group of Article Dropdown (Multi Selection)
                  _buildDropdownSearch(
                    label: 'Article Group *',
                    hint: 'Choose article groups',
                    items: articleGroups,
                    selectedItems: selectedArticleGroups,
                    isMultiSelection: true,
                    onChangedSingle: null,
                    onChangedMulti: (List<String> value) {
                      setState(() {
                        selectedArticleGroups = value;
                      });
                    },
                    validatorSingle: null,
                    validatorMulti: (List<String>? value) =>
                        value == null || value.isEmpty
                            ? 'Please select at least one article group'
                            : null,
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 20),

                  // Article Names / Mould Dropdown (Multi Selection)
                  _buildDropdownSearch(
                    label: 'Article Name / Mould *',
                    hint: 'Choose articles or moulds',
                    items: articleNames,
                    selectedItems: selectedArticleNames,
                    isMultiSelection: true,
                    onChangedSingle: null,
                    onChangedMulti: (List<String> value) {
                      setState(() {
                        selectedArticleNames = value;
                      });
                    },
                    validatorSingle: null,
                    validatorMulti: (List<String>? value) =>
                        value == null || value.isEmpty
                            ? 'Please select at least one article or mould'
                            : null,
                    icon: Icons.widgets,
                  ),
                  const SizedBox(height: 20),

                  // Raw Materials Dropdown (Multi Selection)
                  _buildDropdownSearch(
                    label: 'Raw Material *',
                    hint: 'Choose raw materials',
                    items: rawMaterials,
                    selectedItems: selectedRawMaterials,
                    isMultiSelection: true,
                    onChangedSingle: null,
                    onChangedMulti: (List<String> value) {
                      setState(() {
                        selectedRawMaterials = value;
                      });
                    },
                    validatorSingle: null,
                    validatorMulti: (List<String>? value) =>
                        value == null || value.isEmpty
                            ? 'Please select at least one raw material'
                            : null,
                    icon: Icons.inventory,
                  ),
                  const SizedBox(height: 20),

                  // Master Batch Dropdown (Multi Selection)
                  _buildDropdownSearch(
                    label: 'Master Batch *',
                    hint: 'Choose master batches',
                    items: masterBatches,
                    selectedItems: selectedMasterBatches,
                    isMultiSelection: true,
                    onChangedSingle: null,
                    onChangedMulti: (List<String> value) {
                      setState(() {
                        selectedMasterBatches = value;
                      });
                    },
                    validatorSingle: null,
                    validatorMulti: (List<String>? value) =>
                        value == null || value.isEmpty
                            ? 'Please select at least one master batch'
                            : null,
                    icon: Icons.color_lens,
                  ),
                  const SizedBox(height: 20),

                  // Rejection Raw Material Dropdown (Multi Selection)
                  _buildDropdownSearch(
                    label: 'Rejection Material *',
                    hint: 'Choose rejection materials',
                    items: rejectionMaterials,
                    selectedItems: selectedRejectionMaterials,
                    isMultiSelection: true,
                    onChangedSingle: null,
                    onChangedMulti: (List<String> value) {
                      setState(() {
                        selectedRejectionMaterials = value;
                      });
                    },
                    validatorSingle: null,
                    validatorMulti: (List<String>? value) =>
                        value == null || value.isEmpty
                            ? 'Please select at least one rejection material'
                            : null,
                    icon: Icons.delete_outline,
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, cardColor.withOpacity(0.9)],
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.calendar_today,
          color: primaryColor,
          size: 28,
        ),
        title: Text(
          selectedDate == null
              ? 'Select Production Date *'
              : '${selectedDate!.toLocal()}'.split(' ')[0],
          style: TextStyle(
            color: selectedDate == null ? hintColor : textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: cardColor,
                  ),
                  dialogBackgroundColor: cardColor,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && picked != selectedDate) {
            setState(() {
              selectedDate = picked;
            });
          }
        },
      ),
    );
  }

  Widget _buildDropdownSearch({
    required String label,
    required String hint,
    required List<String> items,
    String? selectedItem,
    List<String>? selectedItems,
    required bool isMultiSelection,
    void Function(String?)? onChangedSingle,
    void Function(List<String>)? onChangedMulti,
    String? Function(String?)? validatorSingle,
    String? Function(List<String>?)? validatorMulti,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: isMultiSelection
          ? DropdownSearch<String>.multiSelection(
              popupProps: PopupPropsMultiSelection.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: 'Search $label',
                    hintText: 'Type to search $label',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                menuProps: MenuProps(
                  backgroundColor: cardColor,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: items,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon, color: primaryColor),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  labelStyle: TextStyle(
                    color: hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: hintColor.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              selectedItems: selectedItems ?? [],
              onChanged: onChangedMulti,
              validator: validatorMulti,
            )
          : DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: 'Search $label',
                    hintText: 'Type to search $label',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                menuProps: MenuProps(
                  backgroundColor: cardColor,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: items,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon, color: primaryColor),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  labelStyle: TextStyle(
                    color: hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: hintColor.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              selectedItem: selectedItem,
              onChanged: onChangedSingle,
              validator: validatorSingle,
            ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please select a production date'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              return;
            }
            // Log or process the selected values
            print('Selected Machine: $selectedMachine');
            print('Selected Article Groups: $selectedArticleGroups');
            print('Selected Article Names: $selectedArticleNames');
            print('Selected Raw Materials: $selectedRawMaterials');
            print('Selected Master Batches: $selectedMasterBatches');
            print('Selected Rejection Materials: $selectedRejectionMaterials');
            print('Selected Date: $selectedDate');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Form submitted successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
