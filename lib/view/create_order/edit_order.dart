import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:krivisha_app/model/order/get_all_orderlist_response.dart';
import 'package:krivisha_app/utility/app_utility.dart';

import '../../core/urls.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';

class EditOrderPage extends StatefulWidget {
  final Order order;

  const EditOrderPage({super.key, required this.order});

  @override
  _EditOrderPageState createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedOrderType,
      _selectedOrderTypeId,
      _selectedPartyName,
      _selectedPartyId,
      _selectedContainerType,
      _selectedContainerTypeId,
      _selectedArticleGroup,
      _selectedArticleGroupId;
  List<Map<String, String>> partyData = [];
  List<Map<String, String>> articleGroupData = [];
  List<Map<String, String>> articleTypeData = [];
  List<Map<String, String>> brandTypeData = [];
  List<Map<String, dynamic>> partyOrderData = [];
  final List<Map<String, String>> orderTypes = [
    {'id': '1', 'name': 'Household'},
    {'id': '2', 'name': 'Container'},
    {'id': '3', 'name': 'Both'},
  ];
  final List<Map<String, String>> containerTypes = [
    {'id': '1', 'name': 'Plain'},
    {'id': '2', 'name': 'Printing'},
  ];
  final List<Map<String, dynamic>> _tableRows = [];
  final List<Map<String, String>> _storedEntries = [];
  bool _disableDropdowns = false, _isLoading = false;
  bool _isArticleGroupValid = true;
  int? _editingIndex;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _initializeOrderData();
    _printReceivedOrder();
    _fetchPartyNames();
    _fetchArticleGroups();
    _addTableRow();
  }

  void _initializeOrderData() {
    // Initialize dropdowns with order data
    _selectedPartyId = widget.order.partyId;
    _selectedPartyName = widget.order.partyName;
    _selectedOrderTypeId = widget.order.typeOfOrder;
    _selectedOrderType = orderTypes.firstWhere(
        (type) => type['id'] == _selectedOrderTypeId,
        orElse: () => {'name': ''})['name'];

    // Handle ink type for Container orders
    if (_selectedOrderTypeId == '2') {
      _selectedContainerTypeId = widget.order.inkType ?? '';
      _selectedContainerType = containerTypes.firstWhere(
          (type) => type['id'] == _selectedContainerTypeId,
          orElse: () => {'name': ''})['name'];
    }

    // Populate stored entries from subDetails
    if (widget.order.subDetails.isNotEmpty) {
      _disableDropdowns = true;
      for (var subDetail in widget.order.subDetails) {
        final entry = {
          'id': subDetail.id, // Store the sub-detail ID
          'partyName': widget.order.partyName,
          'partyId': widget.order.partyId,
          'orderType': _selectedOrderType ?? '',
          'orderTypeId': widget.order.typeOfOrder,
          'containerType': _selectedContainerType ?? '',
          'containerTypeId': _selectedContainerTypeId ?? '',
          'articleGroup': subDetail.groupOfArticle,
          'articleGroupId': subDetail.groupOfArticleId,
          'articleType': subDetail.articleName,
          'articleTypeId': subDetail.articleId,
          'orderQuantity': subDetail.orderQuantity,
          'remark': subDetail.remark ?? '',
          if (_selectedOrderTypeId == '2')
            'brandType': subDetail.brandName ?? '',
          if (_selectedOrderTypeId == '2')
            'brandTypeId': subDetail.brandTypeId ?? '',
        };
        _storedEntries.add(entry);
        log('Added subDetail to _storedEntries: ${jsonEncode(entry)}'); // Debug log
        // Fetch article types for each group in subDetails
        _fetchArticleTypes(subDetail.groupOfArticleId);
      }
    } else {
      log('No subDetails found in order: ${widget.order.orderId}');
    }

    // Fetch brand types if order type is Container
    if (_selectedOrderTypeId == '2' && _selectedPartyId != null) {
      _fetchBrandTypes(_selectedPartyId!);
    }

    // Fetch party order list
    if (_selectedPartyId != null) {
      _fetchPartyOrderList(_selectedPartyId!, offset: 0);
    }

    _addTableRow();
  }

  void _printReceivedOrder() {
    final orderJson = {
      'id': widget.order.id,
      'orderId': widget.order.orderId,
      'partyId': widget.order.partyId,
      'partyName': widget.order.partyName,
      'typeOfOrder': widget.order.typeOfOrder,
      'orderStatus': widget.order.orderStatus,
      'inkType': widget.order.inkType,
      'orderDate': widget.order.orderDate.toIso8601String(),
      'createdOn': widget.order.createdOn.toIso8601String(),
      'updatedOn': widget.order.updatedOn.toIso8601String(),
      'status': widget.order.status,
      'isDeleted': widget.order.isDeleted,
      'subDetails': widget.order.subDetails
          .map((sub) => {
                'id': sub.id,
                'groupOfArticleId': sub.groupOfArticleId,
                'articleId': sub.articleId,
                'brandTypeId': sub.brandTypeId,
                'articleName': sub.articleName,
                'brandName': sub.brandName,
                'orderQuantity': sub.orderQuantity,
                'remark': sub.remark,
                'groupOfArticle': sub.groupOfArticle,
              })
          .toList(),
    };
    log('Received Order: ${jsonEncode(orderJson)}');
  }

  Future<void> _fetchPartyNames() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(Networkutility.getAllParty);
      print('Request to getAllParty: GET $uri');
      final response = await http.get(uri);
      print(
          'Response from getAllParty: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            partyData =
                List<Map<String, String>>.from(jsonData['data'].map((item) => {
                      'id': item['id'].toString(),
                      'party_name': item['party_name'].toString(),
                    }));
            _isLoading = false;
          });
        } else {
          throw Exception('API returned false status: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load party names: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching party names: $e', Colors.redAccent);
    }
  }

  Future<void> _fetchArticleGroups() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(Networkutility.getAllArticleGroup);
      print('Request to get_all_article_group_api: GET $uri');
      final response = await http.get(uri);
      print(
          'Response from get_all_article_group_api: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            articleGroupData =
                List<Map<String, String>>.from(jsonData['data'].map((item) => {
                      'id': item['id'].toString(),
                      'group_of_article': item['group_of_article'].toString(),
                    }));
            _isLoading = false;
          });
        } else {
          throw Exception('API returned false status: ${jsonData['message']}');
        }
      } else {
        throw Exception(
            'Failed to load article groups: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching article groups: $e', Colors.redAccent);
    }
  }

  Future<void> _fetchArticleTypes(String groupId) async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(Networkutility.getAllArticleAcordingGroup);
      final body = jsonEncode({"group_of_article_id": groupId});
      print('Request to get_article_types_api: POST $uri\nBody: $body');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print(
          'Response from get_article_according_group_api: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            articleTypeData =
                List<Map<String, String>>.from(jsonData['data'].map((item) => {
                      'id': item['id'].toString(),
                      'article_name': item['article_name'].toString(),
                    }));
            _isLoading = false;
          });
        } else {
          throw Exception('API returned false status: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load article types: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching article types: $e', Colors.redAccent);
    }
  }

  Future<void> _fetchBrandTypes(String partyId) async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(Networkutility.getBrandsApiList);
      final body = jsonEncode({"party_id": partyId});
      print(
          'Request to get_brands_according_party_api: POST $uri\nBody: $body');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print(
          'Response from get_brands_according_party_api: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'true') {
          setState(() {
            brandTypeData =
                List<Map<String, String>>.from(jsonData['data'].map((item) => {
                      'id': item['id'].toString(),
                      'brand_name': item['brand_name'].toString(),
                    }));
            _isLoading = false;
          });
        } else {
          throw Exception('API returned false status: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load brand types: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching brand types: $e', Colors.redAccent);
    }
  }

  Future<void> _fetchPartyOrderList(String partyId, {int offset = 0}) async {
    try {
      final uri = Uri.parse(Networkutility.getPartyOrderList);
      final body =
          jsonEncode({"limit": 10, "offset": offset, "party_id": partyId});
      print('Request to getPartyOrderList: POST $uri\nBody: $body');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print(
          'Response from getPartyOrderList: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          if (offset == 0) {
            partyOrderData = List<Map<String, dynamic>>.from(jsonData['data']);
          } else {
            partyOrderData
                .addAll(List<Map<String, dynamic>>.from(jsonData['data']));
          }
          if (jsonData['data'].isEmpty) {
            _showSnackBar('No more data', Colors.redAccent);
          }
        });
      } else {
        throw Exception(
            'Failed to fetch party order list: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error fetching party order list: $e', Colors.redAccent);
    }
  }

  Future<void> _saveOrProcessOrder(String action) async {
    setState(() => _isLoading = true);
    try {
      final uri =
          Uri.parse('https://seekhelp.in/krivisha/set_create_order_data_api');
      final jsonData = _generateOrderJson(action);
      print(
          'Request to set_create_order_data_api: POST $uri\nBody: ${jsonEncode(jsonData)}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );
      print(
          'Response from set_create_order_data_api: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          _showSnackBar(responseData['message'], Colors.green);
          Get.offAllNamed(AppRoutes.createorderList);
        } else {
          throw Exception(
              'API returned false status: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to ${action == 'save' ? 'save' : 'process'} order: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar(
          'Error ${action == 'save' ? 'saving' : 'processing'} order: $e',
          Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addTableRow() {
    setState(() {
      _tableRows.add({
        'articleType': '',
        'articleTypeId': '',
        'orderQuantity': TextEditingController(),
        'remark': TextEditingController(),
        if (_selectedOrderType == 'Container') 'brandType': '',
        if (_selectedOrderType == 'Container') 'brandTypeId': '',
      });
    });
  }

  void _removeTableRow(int index) {
    setState(() {
      _tableRows[index]['orderQuantity']?.dispose();
      _tableRows[index]['remark']?.dispose();
      _tableRows.removeAt(index);
    });
  }

  void _addEntry() {
    if (_formKey.currentState!.validate() && _isArticleGroupValid) {
      setState(() {
        final entries = _tableRows
            .map((row) => <String, String>{
                  'partyName': _selectedPartyName ?? '',
                  'partyId': _selectedPartyId ?? '',
                  'orderType': _selectedOrderType ?? '',
                  'orderTypeId': _selectedOrderTypeId ?? '',
                  'containerType': _selectedContainerType ?? '',
                  'containerTypeId': _selectedContainerTypeId ?? '',
                  'articleGroup': _selectedArticleGroup ?? '',
                  'articleGroupId': _selectedArticleGroupId ?? '',
                  'articleType': row['articleType'] ?? '',
                  'articleTypeId': row['articleTypeId'] ?? '',
                  'orderQuantity': row['orderQuantity']!.text,
                  'remark': row['remark']!.text,
                  if (_selectedOrderType == 'Container')
                    'brandType': row['brandType'] ?? '',
                  if (_selectedOrderType == 'Container')
                    'brandTypeId': row['brandTypeId'] ?? '',
                  // Do not include 'id' for new entries
                })
            .toList();
        if (_editingIndex != null) {
          _storedEntries[_editingIndex!] = entries.first;
          log('Updated entry at index $_editingIndex: ${jsonEncode(entries.first)}');
          _editingIndex = null;
        } else {
          _storedEntries.addAll(entries);
          log('Added new entries: ${jsonEncode(entries)}');
          _disableDropdowns = true;
        }
        _selectedArticleGroup = null;
        _selectedArticleGroupId = null;
        _isArticleGroupValid = true;
        _tableRows.clear();
        _addTableRow();
      });
      _showSnackBar(_editingIndex == null ? 'Entry Added!' : 'Entry Updated!',
          const Color(0xFF00695C));
    }
  }

  void _editEntry(int index) {
    setState(() {
      _editingIndex = index;
      final entry = _storedEntries[index];
      _selectedPartyName = entry['partyName'];
      _selectedPartyId = entry['partyId'];
      _selectedOrderType = entry['orderType'];
      _selectedOrderTypeId = entry['orderTypeId'];
      _selectedContainerType = entry['containerType'];
      _selectedContainerTypeId = entry['containerTypeId'];
      _selectedArticleGroup = entry['articleGroup'];
      _selectedArticleGroupId = entry['articleGroupId'];
      _isArticleGroupValid = true;
      _tableRows.clear();
      _tableRows.add({
        'articleType': entry['articleType'] ?? '',
        'articleTypeId': entry['articleTypeId'] ?? '',
        'orderQuantity': TextEditingController(text: entry['orderQuantity']),
        'remark': TextEditingController(text: entry['remark']),
        if (entry['orderType'] == 'Container')
          'brandType': entry['brandType'] ?? '',
        if (entry['orderType'] == 'Container')
          'brandTypeId': entry['brandTypeId'] ?? '',
      });
      if (_selectedArticleGroupId != null) {
        _fetchArticleTypes(_selectedArticleGroupId!);
      }
      if (_selectedPartyId != null && entry['orderType'] == 'Container') {
        _fetchBrandTypes(_selectedPartyId!);
      }
      log('Editing entry at index $index: ${jsonEncode(entry)}');
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      _storedEntries.removeAt(index);
      if (_storedEntries.isEmpty) _disableDropdowns = false;
      if (_selectedArticleGroupId != null &&
          _selectedPartyId != null &&
          _selectedOrderType != null) {
        _isArticleGroupValid = !_storedEntries.any((entry) =>
            entry['articleGroupId'] == _selectedArticleGroupId &&
            entry['partyId'] == _selectedPartyId &&
            entry['orderType'] == _selectedOrderType);
      }
    });
  }

  void _showSubDetailsDialog(List<Map<String, dynamic>> subDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Order Sub-Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text('Group of Article')),
              DataColumn(label: Text('Article Name')),
              DataColumn(label: Text('Order Quantity')),
              DataColumn(label: Text('Remark')),
            ],
            rows: subDetails
                .map((data) => DataRow(cells: [
                      DataCell(Text(data['group_of_article'] ?? '-')),
                      DataCell(Text(data['article_name'] ?? '-')),
                      DataCell(Text(data['order_quantity'] ?? '-')),
                      DataCell(Text(data['remark'] ?? '-')),
                    ]))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showProcessConfirmationDialog() {
    final isPrinting = _selectedContainerType == 'Printing';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Confirm ${isPrinting ? 'Printing' : 'Account'} Processing',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        content: Text(
          'Are you sure you want to process this order to ${isPrinting ? 'Printing' : 'Account'}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveOrProcessOrder('process');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Proceed', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> _generateOrderJson(String action) {
    final jsonData = {
      'save_or_process': action,
      'order_id': widget.order.orderId,
      'employee_id': AppUtility.id,
      'party_id': _selectedPartyId ?? '',
      'type_of_order': _selectedOrderTypeId ?? '',
      'ink_type': _selectedOrderType == 'Container'
          ? _selectedContainerTypeId ?? ''
          : '',
      'order_details': _storedEntries
          .map((entry) => {
                // if (entry.containsKey('id') && entry['id']!.isNotEmpty)
                'id': entry['id'] ?? '',
                'group_id': entry['articleGroupId'] ?? '',
                'article_id': entry['articleTypeId'] ?? '',
                'brand_id': entry['orderType'] == 'Container'
                    ? entry['brandTypeId'] ?? ''
                    : '',
                'quantity': entry['orderQuantity'] ?? '',
                'remark': entry['remark'] ?? ''
              })
          .toList()
    };
    log('Generated Order JSON: ${jsonEncode(jsonData)}');
    return jsonData;
  }

  @override
  void dispose() {
    for (var row in _tableRows) {
      row['orderQuantity']?.dispose();
      row['remark']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final containerEntries =
        _storedEntries.where((e) => e['orderType'] == 'Container').toList();
    final householdEntries =
        _storedEntries.where((e) => e['orderType'] != 'Container').toList();

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFFF7FAFA),
        textTheme: Theme.of(context)
            .textTheme
            .apply(fontFamily: 'Roboto', bodyColor: Colors.black87),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF00695C), width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF00695C), width: 1.5)),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardTheme(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.white),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Order',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
          backgroundColor: AppColors.primary,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropdown(
                            label: 'Party Name*',
                            items:
                                partyData.map((e) => e['party_name']!).toList(),
                            value: _selectedPartyName,
                            onChanged: _disableDropdowns
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedPartyName = value;
                                      _selectedPartyId = partyData.firstWhere(
                                          (party) =>
                                              party['party_name'] ==
                                              value)['id'];
                                      _offset = 0;
                                      partyOrderData.clear();
                                      brandTypeData.clear();
                                      _tableRows.clear();
                                      _isArticleGroupValid = true;
                                      _addTableRow();
                                    });
                                    _fetchPartyOrderList(_selectedPartyId!);
                                    if (_selectedOrderType == 'Container') {
                                      _fetchBrandTypes(_selectedPartyId!);
                                    }
                                  },
                            validator: (value) =>
                                value == null ? 'Required' : null,
                            enabled: !_disableDropdowns,
                          ),
                          const SizedBox(height: 20),
                          _buildDropdown(
                            label: 'Type of Order*',
                            items: orderTypes.map((e) => e['name']!).toList(),
                            value: _selectedOrderType,
                            onChanged: _disableDropdowns
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedOrderType = value;
                                      _selectedOrderTypeId =
                                          orderTypes.firstWhere((type) =>
                                              type['name'] == value)['id'];
                                      _selectedContainerType = null;
                                      _selectedContainerTypeId = null;
                                      brandTypeData.clear();
                                      _tableRows.clear();
                                      _isArticleGroupValid = true;
                                      _addTableRow();
                                    });
                                    if (value == 'Container' &&
                                        _selectedPartyId != null) {
                                      _fetchBrandTypes(_selectedPartyId!);
                                    }
                                  },
                            validator: (value) =>
                                value == null ? 'Required' : null,
                            enabled: !_disableDropdowns,
                          ),
                          if (_selectedOrderType == 'Container') ...[
                            const SizedBox(height: 20),
                            _buildDropdown(
                              label: 'INK Type*',
                              items: containerTypes
                                  .map((e) => e['name']!)
                                  .toList(),
                              value: _selectedContainerType,
                              onChanged: _disableDropdowns
                                  ? null
                                  : (value) => setState(() {
                                        _selectedContainerType = value;
                                        _selectedContainerTypeId =
                                            containerTypes.firstWhere((type) =>
                                                type['name'] == value)['id'];
                                      }),
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                              enabled: !_disableDropdowns,
                            ),
                          ],
                          const SizedBox(height: 20),
                          _buildDropdown(
                            label: 'Article Group*',
                            items: articleGroupData
                                .map((e) => e['group_of_article']!)
                                .toList(),
                            value: _selectedArticleGroup,
                            onChanged: (value) {
                              final selectedId = articleGroupData.firstWhere(
                                  (group) =>
                                      group['group_of_article'] == value)['id'];
                              final isDuplicate = _editingIndex == null &&
                                  _storedEntries.any((entry) =>
                                      entry['articleGroupId'] == selectedId &&
                                      entry['partyId'] == _selectedPartyId &&
                                      entry['orderType'] == _selectedOrderType);
                              if (isDuplicate) {
                                _showSnackBar(
                                    'This article group is already selected for this party and order type!',
                                    Colors.redAccent);
                                setState(() {
                                  _isArticleGroupValid = false;
                                });
                                return;
                              }
                              setState(() {
                                _selectedArticleGroup = value;
                                _selectedArticleGroupId = selectedId;
                                _isArticleGroupValid = true;
                                _tableRows.clear();
                                _addTableRow();
                                articleTypeData.clear();
                              });
                              _fetchArticleTypes(_selectedArticleGroupId!);
                            },
                            validator: (value) =>
                                value == null ? 'Required' : null,
                          ),
                          if (_selectedArticleGroup != null) ...[
                            const SizedBox(height: 20),
                            const Text('Article Details',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _tableRows.length,
                              itemBuilder: (context, index) {
                                final row = _tableRows[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        _buildDropdown(
                                          label: 'Type of Article*',
                                          items: articleTypeData
                                              .map((e) => e['article_name']!)
                                              .toList(),
                                          value: row['articleType'],
                                          onChanged: (value) => setState(() {
                                            row['articleType'] = value ?? '';
                                            row['articleTypeId'] =
                                                articleTypeData.firstWhere(
                                                    (type) =>
                                                        type['article_name'] ==
                                                        value)['id'];
                                          }),
                                          validator: (value) =>
                                              value == null ? 'Required' : null,
                                        ),
                                        if (_selectedOrderType ==
                                            'Container') ...[
                                          const SizedBox(height: 12),
                                          _buildDropdown(
                                            label: 'Brand Type*',
                                            items: brandTypeData
                                                .map((e) => e['brand_name']!)
                                                .toList(),
                                            value: row['brandType'],
                                            onChanged: (value) => setState(() {
                                              row['brandType'] = value ?? '';
                                              row['brandTypeId'] = brandTypeData
                                                  .firstWhere((brand) =>
                                                      brand['brand_name'] ==
                                                      value)['id'];
                                            }),
                                            validator: (value) => value == null
                                                ? 'Required'
                                                : null,
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        _buildTextField(
                                          controller: row['orderQuantity'],
                                          label: 'Order Quantity*',
                                          keyboardType: TextInputType.number,
                                          validator: (value) => value!.isEmpty
                                              ? 'Required'
                                              : null,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildTextField(
                                            controller: row['remark'],
                                            label: 'Remark'),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.redAccent,
                                                size: 18),
                                            onPressed: () =>
                                                _removeTableRow(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: (_isArticleGroupValid &&
                                      _selectedPartyName != null &&
                                      _selectedOrderType != null &&
                                      (_selectedOrderType != 'Container' ||
                                          _selectedContainerType != null))
                                  ? _addEntry
                                  : null,
                              child: Text(_editingIndex == null
                                  ? 'Add Entry'
                                  : 'Update Entry'),
                            ),
                          ),
                          if (containerEntries.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Container Entries',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            _buildDataTable(
                                entries: containerEntries, showBrandType: true),
                          ],
                          if (householdEntries.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Selected Article Type',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            _buildDataTable(
                                entries: householdEntries,
                                showBrandType: false),
                          ],
                          if (_storedEntries.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _showProcessConfirmationDialog,
                                  icon: const Icon(Icons.check),
                                  label: const Text('Process Order'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () => _saveOrProcessOrder('save'),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ],
                          if (partyOrderData.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Party Order List',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            _buildOrderDataTable(),
                            const SizedBox(height: 16),
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() => _offset += 10);
                                  _fetchPartyOrderList(_selectedPartyId!,
                                      offset: _offset);
                                },
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Load More'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _offset = 0;
      partyOrderData.clear();
      _storedEntries.clear();
      _tableRows.clear();
      _disableDropdowns = false;
      _selectedPartyName = null;
      _selectedPartyId = null;
      _selectedOrderType = null;
      _selectedOrderTypeId = null;
      _selectedContainerType = null;
      _selectedContainerTypeId = null;
      _selectedArticleGroup = null;
      _selectedArticleGroupId = null;
      _isArticleGroupValid = true;
      articleTypeData.clear();
      brandTypeData.clear();
      _editingIndex = null;
      _addTableRow();
    });

    try {
      await Future.wait([
        _fetchPartyNames(),
        _fetchArticleGroups(),
      ]);
      if (_selectedPartyId != null) {
        await _fetchPartyOrderList(_selectedPartyId!, offset: 0);
        if (_selectedOrderType == 'Container') {
          await _fetchBrandTypes(_selectedPartyId!);
        }
      }
    } catch (e) {
      _showSnackBar('Error refreshing data: $e', Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return DropdownSearch<String>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Search...',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
      ),
      onChanged: onChanged,
      selectedItem: value,
      validator: validator,
      enabled: enabled,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDataTable({
    required List<Map<String, String>> entries,
    required bool showBrandType,
  }) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          columns: [
            const DataColumn(label: Text('Group')),
            const DataColumn(label: Text('Article Type')),
            if (showBrandType) const DataColumn(label: Text('Brand Type')),
            const DataColumn(label: Text('Quantity')),
            const DataColumn(label: Text('Remark')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: entries.asMap().entries.map((entry) {
            final index = _storedEntries.indexOf(entry.value);
            final data = entry.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                  (states) => index % 2 == 0 ? Colors.grey[50] : Colors.white),
              cells: [
                DataCell(Text(data['articleGroup'] ?? '')),
                DataCell(Text(data['articleType'] ?? '')),
                if (showBrandType) DataCell(Text(data['brandType'] ?? '')),
                DataCell(Text(data['orderQuantity'] ?? '')),
                DataCell(Text(data['remark'] ?? '')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFF00695C), size: 18),
                        onPressed: () => _editEntry(index)),
                    IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent, size: 18),
                        onPressed: () => _deleteEntry(index)),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderDataTable() {
    final statusMap = {
      '1': 'Pending',
      '2': 'Proceed to Account',
      '3': 'Process to Printing',
      '4': 'Complete',
    };
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('SR NO.')),
            DataColumn(label: Text('Party Name')),
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Order Details')),
            DataColumn(label: Text('Order Date')),
            DataColumn(label: Text('Status')),
          ],
          rows: partyOrderData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                  (states) => index % 2 == 0 ? Colors.grey[50] : Colors.white),
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(data['party_name'] ?? '')),
                DataCell(Text(data['order_id'] ?? '')),
                DataCell(IconButton(
                    icon: const Icon(Icons.visibility,
                        color: Color(0xFF00695C), size: 18),
                    onPressed: () => _showSubDetailsDialog(
                        List<Map<String, dynamic>>.from(data['sub_details'])))),
                DataCell(Text(data['order_date'] ?? '')),
                DataCell(Text(statusMap[data['order_status']] ?? 'Unknown')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
