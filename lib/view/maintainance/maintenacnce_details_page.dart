import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controller/maintenance/maintenance_controller.dart';
import '../../model/maintenance/maintenance_response.dart';
import '../../utility/app_colors.dart';

class MaintenanceDetailsPage extends StatefulWidget {
  const MaintenanceDetailsPage({super.key});

  @override
  State<MaintenanceDetailsPage> createState() => _MaintenanceDetailsPageState();
}

class _MaintenanceDetailsPageState extends State<MaintenanceDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Maintenance? maintenance;

  final Map<String, int> maintenanceTypeMap = {
    "Emergency": 1,
    "Online Breakdown": 2,
    "Preventive": 3,
    "Outside Work": 4,
    "General": 5,
  };

  @override
  void initState() {
    super.initState();
    print('MaintenanceDetailsPage initialized');
    final MaintenanceController maintenanceController =
        Get.find<MaintenanceController>();
    maintenance = maintenanceController.selectedMaintenance.value;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getActionTypeName(String typeOfAction) {
    return maintenanceTypeMap.entries
        .firstWhere(
          (entry) => entry.value.toString() == typeOfAction,
          orElse: () => const MapEntry('Unknown', 0),
        )
        .key;
  }

  String _formatDateToIndian(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Maintenance',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          maintenance == null
              ? Center(
                child: Text(
                  'No data available',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                child: FadeTransition(
                  opacity: _animation,
                  child: _buildInfoCard(
                    context,
                    title: 'Maintenance Details',
                    status:
                        maintenance!.status == '1'
                            ? 'Pending'
                            : maintenance!.status == '2'
                            ? 'Completed'
                            : 'Unknown',
                    children: [
                      _buildInfoRow(Icons.perm_identity, 'ID', maintenance!.id),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.code,
                        'MWO Code',
                        maintenance!.mwoCode ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_month,
                        'Date',
                        _formatDateToIndian(maintenance!.date),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.build,
                        'Action Type',
                        _getActionTypeName(maintenance!.typeOfAction),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.description,
                        'Problems',
                        maintenance!.problems.isNotEmpty
                            ? maintenance!.problems
                            : 'No details',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.factory,
                        'Plant Name',
                        maintenance!.plantName ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.person,
                        'Employee',
                        maintenance!.firstName ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.settings,
                        'Type',
                        maintenance!.maintenanceType ?? 'N/A',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.category,
                        'Category',
                        maintenance!.typeName ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String status,
    required List<Widget> children,
  }) {
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange.shade400;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'completed':
        statusColor = Colors.green.shade600;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey.shade400;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ScaleTransition(
      scale: _animation,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String detail) {
    return ScaleTransition(
      scale: _animation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              detail,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
