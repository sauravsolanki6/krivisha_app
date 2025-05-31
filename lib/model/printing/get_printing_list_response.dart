// To parse this JSON data, do
//
//     final getAllPrintingListResponse = getAllPrintingListResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllPrintingListResponse> getAllPrintingListResponseFromJson(
  String str,
) =>
    List<GetAllPrintingListResponse>.from(
      json.decode(str).map((x) => GetAllPrintingListResponse.fromJson(x)),
    );

String getAllPrintingListResponseToJson(
  List<GetAllPrintingListResponse> data,
) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllPrintingListResponse {
  String status;
  String message;
  List<Printing> data;

  GetAllPrintingListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllPrintingListResponse.fromJson(Map<String, dynamic> json) =>
      GetAllPrintingListResponse(
        status: json["status"],
        message: json["message"],
        data: List<Printing>.from(
          json["data"].map((x) => Printing.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Printing {
  String id;
  String partyId;
  String typeOfOrder;
  String orderId;
  DateTime orderDate;
  String orderStatus;
  String inkType;
  DateTime createdOn;
  DateTime updatedOn;
  String status;
  String isDeleted;
  String partyName;
  List<SubDetail> subDetails;

  Printing({
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

  factory Printing.fromJson(Map<String, dynamic> json) => Printing(
        id: json["id"],
        partyId: json["party_id"],
        typeOfOrder: json["type_of_order"],
        orderId: json["order_id"],
        orderDate: DateTime.parse(json["order_date"]),
        orderStatus: json["order_status"],
        inkType: json["ink_type"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        status: json["status"],
        isDeleted: json["is_deleted"],
        partyName: json["party_name"],
        subDetails: List<SubDetail>.from(
          json["sub_details"].map((x) => SubDetail.fromJson(x)),
        ),
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

class SubDetail {
  String id;
  String groupOfArticleId;
  String articleId;
  String brandTypeId;
  String orderQuantity;
  String remark;
  String orderId;
  String orderStatus;
  String inkType;
  DateTime createdOn;
  DateTime updatedOn;
  String isDeleted;
  String status;
  String groupOfArticle;
  String brandName;
  String articleName;

  SubDetail({
    required this.id,
    required this.groupOfArticleId,
    required this.articleId,
    required this.brandTypeId,
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
    required this.brandName,
    required this.articleName,
  });

  factory SubDetail.fromJson(Map<String, dynamic> json) => SubDetail(
        id: json["id"],
        groupOfArticleId: json["group_of_article_id"],
        articleId: json["article_id"],
        brandTypeId: json["brand_type_id"],
        orderQuantity: json["order_quantity"],
        remark: json["remark"],
        orderId: json["order_id"],
        orderStatus: json["order_status"],
        inkType: json["ink_type"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        isDeleted: json["is_deleted"],
        status: json["status"],
        groupOfArticle: json["group_of_article"],
        brandName: json["brand_name"],
        articleName: json["article_name"],
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
        "brand_name": brandName,
        "article_name": articleName,
      };
}
