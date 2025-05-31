// To parse this JSON data, do
//
//     final setAddTaskResponse = setAddTaskResponseFromJson(jsonString);

import 'dart:convert';

List<SetAddTaskResponse> setAddTaskResponseFromJson(String str) => List<SetAddTaskResponse>.from(json.decode(str).map((x) => SetAddTaskResponse.fromJson(x)));

String setAddTaskResponseToJson(List<SetAddTaskResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SetAddTaskResponse {
    String message;
    String status;

    SetAddTaskResponse({
        required this.message,
        required this.status,
    });

    factory SetAddTaskResponse.fromJson(Map<String, dynamic> json) => SetAddTaskResponse(
        message: json["message"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
    };
}
