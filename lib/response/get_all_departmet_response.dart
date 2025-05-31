// To parse this JSON data, do
//
//     final getAllDepartmentResponse = getAllDepartmentResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllDepartmentResponse> getAllDepartmentResponseFromJson(String str) =>
    List<GetAllDepartmentResponse>.from(
      json.decode(str).map((x) => GetAllDepartmentResponse.fromJson(x)),
    );

String getAllDepartmentResponseToJson(List<GetAllDepartmentResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllDepartmentResponse {
  String status;
  String message;
  List<AllDepartments> data;

  GetAllDepartmentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllDepartmentResponse.fromJson(Map<String, dynamic> json) =>
      GetAllDepartmentResponse(
        status: json["status"],
        message: json["message"],
        data: List<AllDepartments>.from(
          json["data"].map((x) => AllDepartments.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AllDepartments {
  String id;
  String department;
  String plantId;
  String isDeleted;
  String status;
  DateTime createdOn;
  DateTime updatedOn;

  AllDepartments({
    required this.id,
    required this.department,
    required this.plantId,
    required this.isDeleted,
    required this.status,
    required this.createdOn,
    required this.updatedOn,
  });

  factory AllDepartments.fromJson(Map<String, dynamic> json) => AllDepartments(
    id: json["id"],
    department: json["department"],
    plantId: json["plant_id"],
    isDeleted: json["is_deleted"],
    status: json["status"],
    createdOn: DateTime.parse(json["created_on"]),
    updatedOn: DateTime.parse(json["updated_on"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "department": department,
    "plant_id": plantId,
    "is_deleted": isDeleted,
    "status": status,
    "created_on": createdOn.toIso8601String(),
    "updated_on": updatedOn.toIso8601String(),
  };
}
