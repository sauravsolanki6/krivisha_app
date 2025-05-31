// To parse this JSON data, do
//
//     final allCity = allCityFromJson(jsonString);

import 'dart:convert';

AllCity allCityFromJson(String str) => AllCity.fromJson(json.decode(str));

String allCityToJson(AllCity data) => json.encode(data.toJson());

class AllCity {
    String id;
    String city;
    String districtName;
    String stateName;
    String pincode;

    AllCity({
        required this.id,
        required this.city,
        required this.districtName,
        required this.stateName,
        required this.pincode,
    });

    factory AllCity.fromJson(Map<String, dynamic> json) => AllCity(
        id: json["id"],
        city: json["city"],
        districtName: json["district_name"],
        stateName: json["state_name"],
        pincode: json["pincode"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "city": city,
        "district_name": districtName,
        "state_name": stateName,
        "pincode": pincode,
    };
}
