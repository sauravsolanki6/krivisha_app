// To parse this JSON data, do
//
//     final ownvehicleListResponse = ownvehicleListResponseFromJson(jsonString);

import 'dart:convert';

List<OwnvehicleListResponse> ownvehicleListResponseFromJson(String str) =>
    List<OwnvehicleListResponse>.from(
      json.decode(str).map((x) => OwnvehicleListResponse.fromJson(x)),
    );

String ownvehicleListResponseToJson(List<OwnvehicleListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OwnvehicleListResponse {
  String status;
  String message;
  List<OwnVehicles> data;

  OwnvehicleListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OwnvehicleListResponse.fromJson(Map<String, dynamic> json) =>
      OwnvehicleListResponse(
        status: json["status"],
        message: json["message"],
        data: List<OwnVehicles>.from(
          json["data"].map((x) => OwnVehicles.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class OwnVehicles {
  String id;
  String vehicalId;
  String challanDcNo;
  String invoiceNo;
  String locationId;
  String pincode;
  String purpose;
  String partyId;
  String inKm;
  String marketFreight;
  String dieselTopup;
  String driverExpense;
  String maintenance;
  String status;
  String isDeleted;
  DateTime createdOn;
  DateTime updatedOn;
  String vehical;
  String city;
  dynamic partyName;

  OwnVehicles({
    required this.id,
    required this.vehicalId,
    required this.challanDcNo,
    required this.invoiceNo,
    required this.locationId,
    required this.pincode,
    required this.purpose,
    required this.partyId,
    required this.inKm,
    required this.marketFreight,
    required this.dieselTopup,
    required this.driverExpense,
    required this.maintenance,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.vehical,
    required this.city,
    required this.partyName,
  });

  factory OwnVehicles.fromJson(Map<String, dynamic> json) => OwnVehicles(
        id: json["id"],
        vehicalId: json["vehical_id"],
        challanDcNo: json["challan_dc_no"],
        invoiceNo: json["invoice_no"],
        locationId: json["location_id"],
        pincode: json["pincode"],
        purpose: json["purpose"],
        partyId: json["party_id"],
        inKm: json["in_km"],
        marketFreight: json["market_freight"],
        dieselTopup: json["diesel_topup"],
        driverExpense: json["driver_expense"],
        maintenance: json["maintenance"],
        status: json["status"],
        isDeleted: json["is_deleted"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        vehical: json["vehical"],
        city: json["city"],
        partyName: json["party_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehical_id": vehicalId,
        "challan_dc_no": challanDcNo,
        "invoice_no": invoiceNo,
        "location_id": locationId,
        "pincode": pincode,
        "purpose": purpose,
        "party_id": partyId,
        "in_km": inKm,
        "market_freight": marketFreight,
        "diesel_topup": dieselTopup,
        "driver_expense": driverExpense,
        "maintenance": maintenance,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
        "vehical": vehical,
        "city": city,
        "party_name": partyName,
      };
}
