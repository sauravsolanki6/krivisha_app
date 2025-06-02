import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import 'production_report.dart';

class ProductionList extends StatefulWidget {
  const ProductionList({super.key});

  @override
  _ProductionListState createState() => _ProductionListState();
}

class _ProductionListState extends State<ProductionList> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Production> _productions = [];
  int _offset = 0;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreData = true;

  // Dummy data
  final List<Production> _dummyData = List.generate(
    20, // Generate 20 records for testing
    (index) => Production(
      srNo: (index + 1).toString(),
      date: '2025-05-${(index % 30 + 1).toString().padLeft(2, '0')}',
      supervisorName:
          'Supervisor ${['John Doe', 'Jane Smith', 'Alex Brown'][index % 3]}',
      machine: 'Machine ${['M1', 'M2', 'M3'][index % 3]}',
      groupOfArticle: 'Group ${['A', 'B', 'C'][index % 3]}',
      articleNames: 'Article ${index + 1}',
      rawMaterials: 'Material ${['Plastic', 'Rubber', 'Metal'][index % 3]}',
      masterBatch: 'Batch ${index + 1}',
      rejection: '${index % 5} units',
      uploadedPictures: '${index % 3 + 1} images',
      remark: 'Remark for record ${index + 1}',
      status: ['1', '2', '0'][index % 3], // In Progress, Completed, Unknown
    ),
  );

  @override
  void initState() {
    super.initState();
    _fetchProductionList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreData) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchProductionList({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _offset = 0;
        _productions.clear();
        _hasMoreData = true;
        _isLoading = true;
      });
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Fetch from dummy data
      final startIndex = _offset;
      final endIndex = (_offset + _limit).clamp(0, _dummyData.length);
      final newData = _dummyData.sublist(startIndex, endIndex);

      setState(() {
        _productions.addAll(newData);
        _isLoading = false;
        _isLoadingMore = false;
        _hasMoreData = endIndex < _dummyData.length;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _fetchMoreData() async {
    setState(() {
      _isLoadingMore = true;
      _offset += _limit;
    });
    await _fetchProductionList();
  }

  Future<void> _onRefresh() async {
    await _fetchProductionList(isRefresh: true);
  }

  // Placeholder for edit action
  void _onEditProduction(Production production) {
    // Replace with actual edit logic, e.g., navigate to an edit page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit production ${production.srNo}')),
    );
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => EditProductionPage(production: production)));
  }

  // Placeholder for report action
  void _onGenerateReport(Production production) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductionReport()),
    );
    // Replace with actual report generation
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ProductionReportPage(production: production)));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1':
        return Colors.orange.shade300; // In Progress
      case '2':
        return Colors.green; // Completed
      default:
        return Colors.grey.shade300; // Unknown
    }
  }

  String _formatDateToIndian(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 140,
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
                                width: 80, height: 16, color: Colors.white),
                            Container(
                                width: 80, height: 16, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Production List',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: _isLoading
            ? _buildShimmer()
            : _productions.isEmpty
                ? const Center(child: Text('No production records found'))
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _productions.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _productions.length && _isLoadingMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final production = _productions[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductionDetailsPage(
                                    production: production),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(production.status),
                                    borderRadius: const BorderRadius.horizontal(
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'SR. NO: ${production.srNo}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.info_outline,
                                                    color: Colors.blue),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductionDetailsPage(
                                                              production:
                                                                  production),
                                                    ),
                                                  );
                                                },
                                                tooltip: 'View Details',
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.orange),
                                                onPressed: () =>
                                                    _onEditProduction(
                                                        production),
                                                tooltip: 'Edit Production',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.description,
                                                    color: Colors.green),
                                                onPressed: () =>
                                                    _onGenerateReport(
                                                        production),
                                                tooltip: 'Production Report',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date: ${_formatDateToIndian(production.date)}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        'Supervisor: ${production.supervisorName}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        'Machine: ${production.machine}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        'Article: ${production.articleNames}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        'Rejection: ${production.rejection}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        'Status: ${production.status == '1' ? 'In Progress' : production.status == '2' ? 'Completed' : 'Unknown'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(
                                              production.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

class Production {
  final String srNo;
  final String date;
  final String supervisorName;
  final String machine;
  final String groupOfArticle;
  final String articleNames;
  final String rawMaterials;
  final String masterBatch;
  final String rejection;
  final String uploadedPictures;
  final String remark;
  final String status;

  Production({
    required this.srNo,
    required this.date,
    required this.supervisorName,
    required this.machine,
    required this.groupOfArticle,
    required this.articleNames,
    required this.rawMaterials,
    required this.masterBatch,
    required this.rejection,
    required this.uploadedPictures,
    required this.remark,
    required this.status,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    return Production(
      srNo: json['sr_no']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      supervisorName: json['supervisor_name']?.toString() ?? '',
      machine: json['machine']?.toString() ?? '',
      groupOfArticle: json['group_of_article']?.toString() ?? '',
      articleNames: json['article_names']?.toString() ?? '',
      rawMaterials: json['raw_materials']?.toString() ?? '',
      masterBatch: json['master_batch']?.toString() ?? '',
      rejection: json['rejection']?.toString() ?? '',
      uploadedPictures: json['uploaded_pictures']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class ProductionDetailsPage extends StatelessWidget {
  final Production production;

  const ProductionDetailsPage({super.key, required this.production});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('SR. NO:', production.srNo),
            _buildDetailRow('Date:', production.date),
            _buildDetailRow('Supervisor Name:', production.supervisorName),
            _buildDetailRow('Machine:', production.machine),
            _buildDetailRow('Group of Article:', production.groupOfArticle),
            _buildDetailRow('Article Names / Mould:', production.articleNames),
            _buildDetailRow('Raw Materials:', production.rawMaterials),
            _buildDetailRow('Master Batch:', production.masterBatch),
            _buildDetailRow('Rejection:', production.rejection),
            _buildDetailRow('Uploaded Pictures:', production.uploadedPictures),
            _buildDetailRow('Remark:', production.remark),
            _buildDetailRow(
                'Status:',
                production.status == '1'
                    ? 'In Progress'
                    : production.status == '2'
                        ? 'Completed'
                        : 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
