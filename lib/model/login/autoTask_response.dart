// To parse this JSON data, do
//
//     final autoTaskResponse = autoTaskResponseFromJson(jsonString);

import 'dart:convert';

List<AutoTaskResponse> autoTaskResponseFromJson(String str) =>
    List<AutoTaskResponse>.from(
        json.decode(str).map((x) => AutoTaskResponse.fromJson(x)));

String autoTaskResponseToJson(List<AutoTaskResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AutoTaskResponse {
  String status;
  String message;
  List<Autotask> data;

  AutoTaskResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AutoTaskResponse.fromJson(Map<String, dynamic> json) =>
      AutoTaskResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<Autotask>.from(
                json["data"].map((x) => Autotask.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Autotask {
  String id;
  String taskId;
  String employeeId;
  String orderDepartment;
  String date;
  String taskStatus;
  String? taskAction;
  String status;
  String isDeleted;
  String createdOn;
  String updatedOn;
  String employeeName;

  Autotask({
    required this.id,
    required this.taskId,
    required this.employeeId,
    required this.orderDepartment,
    required this.date,
    required this.taskStatus,
    this.taskAction,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.employeeName,
  });

  factory Autotask.fromJson(Map<String, dynamic> json) => Autotask(
        id: json["id"] ?? "",
        taskId: json["task_id"] ?? "",
        employeeId: json["employee_id"] ?? "",
        orderDepartment: json["order_department"] ?? "",
        date: json["date"] ?? "",
        taskStatus: json["task_status"] ?? "",
        taskAction: json["task_action"],
        status: json["status"] ?? "",
        isDeleted: json["is_deleted"] ?? "",
        createdOn: json["created_on"] ?? "",
        updatedOn: json["updated_on"] ?? "",
        employeeName: json["employee_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "task_id": taskId,
        "employee_id": employeeId,
        "order_department": orderDepartment,
        "date": date,
        "task_status": taskStatus,
        "task_action": taskAction,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn,
        "employee_name": employeeName,
      };
}
