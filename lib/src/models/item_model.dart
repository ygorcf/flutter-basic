import 'dart:convert';

List<Item> itemsFromJson(String str) =>
    List<Item>.from(json.decode(str).map((item) => Item.fromJson(item)));

String itemsToJson(List<Item> data) =>
    json.encode(List<dynamic>.from(data.map((item) => item.toJson())));

class Item {
  String id;
  String name;
  int quantity;
  String unitOfMeasure;
  int unitPrice;

  Item({this.id, this.name, this.quantity, this.unitOfMeasure, this.unitPrice});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['sku'],
        name: json['name'],
        quantity: json['quantity'],
        unitOfMeasure: json['unitOfMeasure'],
        unitPrice: json['unitPrice'],
      );

  Map<String, dynamic> toJson() => {
        'sku': id,
        'name': name,
        'quantity': quantity,
        'unitOfMeasure': unitOfMeasure,
        'unitPrice': unitPrice,
      };
}
