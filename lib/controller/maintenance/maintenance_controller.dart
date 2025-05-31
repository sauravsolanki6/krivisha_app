// File: lib/controller/maintenance_controller.dart
import 'package:get/get.dart';

import '../../model/maintenance/maintenance_response.dart'; // Adjust the import path as needed

class MaintenanceController extends GetxController {
  // Reactive variable to hold the selected Maintenance object
  var selectedMaintenance = Rxn<Maintenance>();

  // Method to set the selected maintenance
  void setSelectedMaintenance(Maintenance maintenance) {
    selectedMaintenance.value = maintenance;
  }

  // Method to clear the selected maintenance (optional)
  void clearSelectedMaintenance() {
    selectedMaintenance.value = null;
  }
}