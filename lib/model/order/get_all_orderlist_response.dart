// To parse this JSON data, do
//
//     final getAllOrderlistResponse = getAllOrderlistResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllOrderlistResponse> getAllOrderlistResponseFromJson(String str) =>
    List<GetAllOrderlistResponse>.from(
      json.decode(str).map((x) => GetAllOrderlistResponse.fromJson(x)),
    );

String getAllOrderlistResponseToJson(List<GetAllOrderlistResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllOrderlistResponse {
  bool status;
  String message;
  List<Order> data;

  GetAllOrderlistResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllOrderlistResponse.fromJson(Map<String, dynamic> json) =>
      GetAllOrderlistResponse(
        status: json["status"] == "true",
        message: json["message"] ?? "",
        data: List<Order>.from(json["data"].map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status.toString(),
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Order {
  String id;
  String partyId;
  String typeOfOrder;
  String orderId;
  DateTime orderDate;
  String orderStatus;
  dynamic inkType;
  DateTime createdOn;
  DateTime updatedOn;
  String status;
  String isDeleted;
  String partyName;
  List<SubDetail2> subDetails;

  Order({
    required this.id,
    required this.partyId,
    required this.typeOfOrder,
    required this.orderId,
    required this.orderDate,
    required this.orderStatus,
    required this.inkType,
    required this.createdOn,
    required this.updatedOn,
    required this.status,
    required this.isDeleted,
    required this.partyName,
    required this.subDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"] ?? "",
        partyId: json["party_id"] ?? "",
        typeOfOrder: json["type_of_order"] ?? "",
        orderId: json["order_id"] ?? "",
        orderDate: DateTime.parse(json["order_date"]),
        orderStatus: json["order_status"] ?? "",
        inkType: json["ink_type"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        status: json["status"] ?? "",
        isDeleted: json["is_deleted"] ?? "0",
        partyName: json["party_name"] ?? "",
        subDetails: json["sub_details"] != null
            ? List<SubDetail2>.from(
                json["sub_details"].map((x) => SubDetail2.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "party_id": partyId,
        "type_of_order": typeOfOrder,
        "order_id": orderId,
        "order_date":
            "${orderDate.year.toString().padLeft(4, '0')}-${orderDate.month.toString().padLeft(2, '0')}-${orderDate.day.toString().padLeft(2, '0')}",
        "order_status": orderStatus,
        "ink_type": inkType,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
        "status": status,
        "is_deleted": isDeleted,
        "party_name": partyName,
        "sub_details": List<dynamic>.from(subDetails.map((x) => x.toJson())),
      };
}

class SubDetail2 {
  String id;
  String groupOfArticleId;
  String articleId;
  String? brandTypeId;
  String orderQuantity;
  String remark;
  String orderId;
  String orderStatus;
  dynamic inkType;
  DateTime createdOn;
  DateTime updatedOn;
  String isDeleted;
  String status;
  String groupOfArticle;
  String articleName;
  String? brandName;

  SubDetail2({
    required this.id,
    required this.groupOfArticleId,
    required this.articleId,
    this.brandTypeId,
    required this.orderQuantity,
    required this.remark,
    required this.orderId,
    required this.orderStatus,
    required this.inkType,
    required this.createdOn,
    required this.updatedOn,
    required this.isDeleted,
    required this.status,
    required this.groupOfArticle,
    required this.articleName,
    this.brandName,
  });

  factory SubDetail2.fromJson(Map<String, dynamic> json) => SubDetail2(
        id: json["id"] ?? "",
        groupOfArticleId: json["group_of_article_id"] ?? "",
        articleId: json["article_id"] ?? "",
        brandTypeId: json["brand_type_id"],
        orderQuantity: json["order_quantity"] ?? "",
        remark: json["remark"] ?? "",
        orderId: json["order_id"] ?? "",
        orderStatus: json["order_status"] ?? "",
        inkType: json["ink_type"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        isDeleted: json["is_deleted"] ?? "0",
        status: json["status"] ?? "",
        groupOfArticle: json["group_of_article"] ?? "",
        articleName: json["article_name"] ?? "",
        brandName: json["brand_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "group_of_article_id": groupOfArticleId,
        "article_id": articleId,
        "brand_type_id": brandTypeId,
        "order_quantity": orderQuantity,
        "remark": remark,
        "order_id": orderId,
        "order_status": orderStatus,
        "ink_type": inkType,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
        "is_deleted": isDeleted,
        "status": status,
        "group_of_article": groupOfArticle,
        "article_name": articleName,
        "brand_name": brandName,
      };
}
