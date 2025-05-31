// To parse this JSON data, do
//
//     final getEmployeeAccordingDepartmentResponse = getEmployeeAccordingDepartmentResponseFromJson(jsonString);

import 'dart:convert';

List<GetEmployeeAccordingDepartmentResponse>
getEmployeeAccordingDepartmentResponseFromJson(String str) =>
    List<GetEmployeeAccordingDepartmentResponse>.from(
      json
          .decode(str)
          .map((x) => GetEmployeeAccordingDepartmentResponse.fromJson(x)),
    );

String getEmployeeAccordingDepartmentResponseToJson(
  List<GetEmployeeAccordingDepartmentResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetEmployeeAccordingDepartmentResponse {
  String status;
  String message;
  List<EmployeeAccordingDepartment> data;

  GetEmployeeAccordingDepartmentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetEmployeeAccordingDepartmentResponse.fromJson(
    Map<String, dynamic> json,
  ) => GetEmployeeAccordingDepartmentResponse(
    status: json["status"],
    message: json["message"],
    data: List<EmployeeAccordingDepartment>.from(
      json["data"].map((x) => EmployeeAccordingDepartment.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class EmployeeAccordingDepartment {
  String id;
  String empId;
  String refCode;
  dynamic uanNo;
  String title;
  String firstName;
  String middleName;
  String lastName;

  EmployeeAccordingDepartment({
    required this.id,
    required this.empId,
    required this.refCode,
    required this.uanNo,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  factory EmployeeAccordingDepartment.fromJson(Map<String, dynamic> json) =>
      EmployeeAccordingDepartment(
        id: json["id"]??"",
        empId: json["emp_id"]??"",
        refCode: json["ref_code"]??"",
        uanNo: json["uan_no"]??"",
        title: json["title"]??"",
        firstName: json["first_name"]??"",
        middleName: json["middle_name"]??"",
        lastName: json["last_name"]??"",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "emp_id": empId,
    "ref_code": refCode,
    "uan_no": uanNo,
    "title": title,
    "first_name": firstName,
    "middle_name": middleName,
    "last_name": lastName,
  };
}
