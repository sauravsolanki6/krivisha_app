// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

List<LoginResponse> loginResponseFromJson(String str) => List<LoginResponse>.from(json.decode(str).map((x) => LoginResponse.fromJson(x)));

String loginResponseToJson(List<LoginResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LoginResponse {
    String status;
    String message;
    Data data;

    LoginResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String id;
    String empId;
    String refCode;
    String title;
    String firstName;
    String middleName;
    String pushToken;
    String appointmentedSalary;

    Data({
        required this.id,
        required this.empId,
        required this.refCode,
        required this.title,
        required this.firstName,
        required this.middleName,
        required this.pushToken,
        required this.appointmentedSalary,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        empId: json["emp_id"],
        refCode: json["ref_code"],
        title: json["title"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        pushToken: json["push_token"],
        appointmentedSalary: json["appointmented_salary"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "emp_id": empId,
        "ref_code": refCode,
        "title": title,
        "first_name": firstName,
        "middle_name": middleName,
        "push_token": pushToken,
        "appointmented_salary": appointmentedSalary,
    };
}
