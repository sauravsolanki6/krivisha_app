// To parse this JSON data, do
//
//     final taskResponse = taskResponseFromJson(jsonString);

import 'dart:convert';

List<TaskResponse> taskResponseFromJson(String str) => List<TaskResponse>.from(
    json.decode(str).map((x) => TaskResponse.fromJson(x)));

String taskResponseToJson(List<TaskResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskResponse {
  String status;
  String message;
  List<Task> data;

  TaskResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) => TaskResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<Task>.from(json["data"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Task {
  String id;
  String taskId;
  String taskHead;
  String employeeId;
  String partyId;
  String completeByDate;
  String completeByTime;
  String priority;
  String remark;
  String departmentId;
  String assignToId;
  String taskStatus;
  String? taskAction;
  String? detailsOfTask;
  String status;
  String isDeleted;
  String createdOn;
  String updatedOn;
  String employeeName;
  String department;
  String partyName;
  String? assignedToName;

  Task({
    required this.id,
    required this.taskId,
    required this.taskHead,
    required this.employeeId,
    required this.partyId,
    required this.completeByDate,
    required this.completeByTime,
    required this.priority,
    required this.remark,
    required this.departmentId,
    required this.assignToId,
    required this.taskStatus,
    this.taskAction,
    this.detailsOfTask,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.employeeName,
    required this.department,
    required this.partyName,
    this.assignedToName,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"] ?? "",
        taskId: json["task_id"] ?? "",
        taskHead: json["task_head"] ?? "",
        employeeId: json["employee_id"] ?? "",
        partyId: json["party_id"] ?? "",
        completeByDate: json["complete_by_date"] ?? "",
        completeByTime: json["complete_by_time"] ?? "",
        priority: json["priority"] ?? "",
        remark: json["remark"] ?? "",
        departmentId: json["department_id"] ?? "",
        assignToId: json["assign_to_id"] ?? "",
        taskStatus: json["task_status"] ?? "",
        taskAction: json["task_action"],
        detailsOfTask: json["details_of_task"],
        status: json["status"] ?? "",
        isDeleted: json["is_deleted"] ?? "",
        createdOn: json["created_on"] ?? "",
        updatedOn: json["updated_on"] ?? "",
        employeeName: json["employee_name"] ?? "",
        department: json["department"] ?? "",
        partyName: json["party_name"] ?? "",
        assignedToName: json["assigned_to_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "task_id": taskId,
        "task_head": taskHead,
        "employee_id": employeeId,
        "party_id": partyId,
        "complete_by_date": completeByDate,
        "complete_by_time": completeByTime,
        "priority": priority,
        "remark": remark,
        "department_id": departmentId,
        "assign_to_id": assignToId,
        "task_status": taskStatus,
        "task_action": taskAction,
        "details_of_task": detailsOfTask,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn,
        "employee_name": employeeName,
        "department": department,
        "party_name": partyName,
        "assigned_to_name": assignedToName,
      };
}
