import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductionReport extends StatefulWidget {
  const ProductionReport({Key? key}) : super(key: key);

  @override
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionReport> {
  // Controllers for text fields
  final List<Map<String, TextEditingController>> _controllers = [];
  // List to store selected status for each row
  final List<String?> _selectedStatuses = [];

  // List of time slot labels
  final List<String> _timeSlots = [
    '8-9',
    '9-10',
    '10-11',
    '11-12',
    '12-13',
    '13-14',
    '14-15',
    '15-16',
    '16-17',
    '17-18',
    '18-19',
    '19-20',
    '20-21',
    '21-22',
    '22-23',
    '23-00',
    '00-01',
    '01-02',
    '02-03',
    '03-04',
    '04-05',
    '05-06',
    '06-07',
    '07-08'
  ];

  @override
  void initState() {
    super.initState();
    _initializeRows();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _initializeRows() {
    _controllers.add({
      'articleName': TextEditingController(text: 'Jarr'),
      'approvedQty': TextEditingController(),
      'averageWeight': TextEditingController(),
      'plantManagerStatus': TextEditingController(),
      'remark': TextEditingController(),
      ...Map.fromEntries(_timeSlots.expand((slot) => [
            MapEntry('${slot}_qty', TextEditingController()),
            MapEntry('${slot}_weight', TextEditingController()),
          ])),
    });
    _controllers.add({
      'articleName': TextEditingController(text: 'MLD-2025-AX45'),
      'approvedQty': TextEditingController(),
      'averageWeight': TextEditingController(),
      'plantManagerStatus': TextEditingController(),
      'remark': TextEditingController(),
      ...Map.fromEntries(_timeSlots.expand((slot) => [
            MapEntry('${slot}_qty', TextEditingController()),
            MapEntry('${slot}_weight', TextEditingController()),
          ])),
    });
    _selectedStatuses.addAll(List.filled(_controllers.length, null));
  }

  @override
  void dispose() {
    for (var controllerMap in _controllers) {
      controllerMap.forEach((key, controller) => controller.dispose());
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Confirm',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            content: Text(
              'Are you sure you want to go back?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: GoogleFonts.poppins(color: Colors.blueGrey[700]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  style: GoogleFonts.poppins(color: Colors.blueGrey[700]),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onSubmit() {
    print('Submit button pressed');
  }

  @override
  Widget build(BuildContext context) {
    final double dynamicGap = MediaQuery.of(context).size.height * 0.015;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'Production Dashboard',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 8.0,
                      dataRowHeight: 150.0,
                      dividerThickness: 1.0, // Add divider thickness
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            'Article Name',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Approved Qty',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Average Weight',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        ..._timeSlots.map((slot) => DataColumn(
                              label: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.blueGrey[200]!,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    slot,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        DataColumn(
                          label: Text(
                            'Plant Manager Approval Status',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Remark of Plant Manager',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Log',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ),
                      ],
                      rows: _controllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, TextEditingController> controllers =
                            entry.value;
                        return DataRow(
                          cells: [
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: TextField(
                                  controller: controllers['articleName'],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter article name',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  readOnly: true,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: TextField(
                                  controller: controllers['approvedQty'],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter quantity',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: TextField(
                                  controller: controllers['averageWeight'],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter weight',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            ..._timeSlots.map((slot) => DataCell(
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.blueGrey[200]!,
                                          width: 1.0,
                                        ),
                                      ),
                                      color: Colors.grey[
                                          50], // Light background for time slot cells
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 4.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueGrey[100]!),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: TextField(
                                            controller:
                                                controllers['${slot}_qty'],
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Qty',
                                              hintStyle: GoogleFonts.poppins(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                            ),
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: dynamicGap),
                                        Container(
                                          padding: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueGrey[100]!),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: TextField(
                                            controller:
                                                controllers['${slot}_weight'],
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Weight',
                                              hintStyle: GoogleFonts.poppins(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                            ),
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Select status',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                    value: _selectedStatuses[index],
                                    items: ['Approve', 'Not Approve']
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style:
                                              GoogleFonts.poppins(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatuses[index] = value;
                                        controllers['plantManagerStatus']
                                            ?.text = value ?? '';
                                      });
                                    },
                                    style: GoogleFonts.poppins(
                                      color: Colors.blueGrey[800],
                                      fontSize: 14,
                                    ),
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: TextField(
                                  controller: controllers['remark'],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter remark',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                  ),
                                  style: GoogleFonts.poppins(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement save functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey[600],
                                    foregroundColor: Colors.white,
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Save'),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement log functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey[400],
                                    foregroundColor: Colors.white,
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Log'),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
