// To parse this JSON data, do
//
//     final getVehicles = getVehiclesFromJson(jsonString);

import 'dart:convert';

List<GetVehicles> getVehiclesFromJson(String str) => List<GetVehicles>.from(json.decode(str).map((x) => GetVehicles.fromJson(x)));

String getVehiclesToJson(List<GetVehicles> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVehicles {
    String status;
    String message;
    List<Datum> data;

    GetVehicles({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetVehicles.fromJson(Map<String, dynamic> json) => GetVehicles(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String id;
    String vehical;
    String status;
    String isDeleted;
    DateTime createdOn;
    DateTime updatedOn;

    Datum({
        required this.id,
        required this.vehical,
        required this.status,
        required this.isDeleted,
        required this.createdOn,
        required this.updatedOn,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        vehical: json["vehical"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "vehical": vehical,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
    };
}
