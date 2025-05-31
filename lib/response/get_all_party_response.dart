// To parse this JSON data, do
//
//     final getAllPartyResponse = getAllPartyResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllPartyResponse> getAllPartyResponseFromJson(String str) => List<GetAllPartyResponse>.from(json.decode(str).map((x) => GetAllPartyResponse.fromJson(x)));

String getAllPartyResponseToJson(List<GetAllPartyResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllPartyResponse {
    String status;
    String message;
    List<AllPartyData> data;

    GetAllPartyResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetAllPartyResponse.fromJson(Map<String, dynamic> json) => GetAllPartyResponse(
        status: json["status"],
        message: json["message"],
        data: List<AllPartyData>.from(json["data"].map((x) => AllPartyData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class AllPartyData {
    String id;
    String partyName;
    String partyType;
    String mobile;
    String gstPan;
    String address;
    String cityId;

    AllPartyData({
        required this.id,
        required this.partyName,
        required this.partyType,
        required this.mobile,
        required this.gstPan,
        required this.address,
        required this.cityId,
    });

    factory AllPartyData.fromJson(Map<String, dynamic> json) => AllPartyData(
        id: json["id"],
        partyName: json["party_name"],
        partyType: json["party_type"],
        mobile: json["mobile"],
        gstPan: json["gst_pan"],
        address: json["address"],
        cityId: json["city_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "party_name": partyName,
        "party_type": partyType,
        "mobile": mobile,
        "gst_pan": gstPan,
        "address": address,
        "city_id": cityId,
    };
}





