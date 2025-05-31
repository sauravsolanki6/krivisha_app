class Maintenance {
  final String id;
  final String mwoCode;
  final String plantId;
  final String employeeId;
  final String date;
  final String typeOfAction;
  final String maintenance;
  final String subTypeId;
  final String problemId;
  final String status;
  final String createdOn;
  final String updatedOn;
  final String isDeleted;
  final String problems;
  final String plantName;
  final String firstName;
  final String maintenanceType;
  final String typeName;

  Maintenance({
    required this.id,
    required this.mwoCode,
    required this.plantId,
    required this.employeeId,
    required this.date,
    required this.typeOfAction,
    required this.maintenance,
    required this.subTypeId,
    required this.problemId,
    required this.status,
    required this.createdOn,
    required this.updatedOn,
    required this.isDeleted,
    required this.problems,
    required this.plantName,
    required this.firstName,
    required this.maintenanceType,
    required this.typeName,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'] ?? '',
      mwoCode: json['mwo_code'] ?? '',
      plantId: json['plant_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      date: json['date'] ?? '',
      typeOfAction: json['type_of_action'] ?? '',
      maintenance: json['maintaince'] ?? '',
      subTypeId: json['sub_type_id'] ?? '',
      problemId: json['problem_id'] ?? '',
      status: json['status'] ?? '',
      createdOn: json['created_on'] ?? '',
      updatedOn: json['updated_on'] ?? '',
      isDeleted: json['is_deleted'] ?? '',
      problems: json['problems'] ?? '',
      plantName: json['plant_name'] ?? '',
      firstName: json['first_name'] ?? '',
      maintenanceType: json['maintenance_type'] ?? '',
      typeName: json['type_name'] ?? '',
    );
  }
}