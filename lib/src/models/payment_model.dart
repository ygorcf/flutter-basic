import 'dart:convert';

import 'package:flutter_basic/src/models/item_model.dart';

List<Payment> paymentsFromJson(String str) => List<Payment>.from(
    json.decode(str).map((payment) => Payment.fromJson(payment)));

String paymentsToJson(List<Payment> data) =>
    json.encode(List<dynamic>.from(data.map((payment) => payment.toJson())));

class Payment {
  String accessToken;
  String clientId;
  String email;
  int installments;
  String merchantCode;
  String paymentCode;
  List<Item> items;
  String value;

  Payment(
      {this.accessToken,
      this.clientId,
      this.email,
      this.installments,
      this.merchantCode,
      this.paymentCode,
      this.items,
      this.value});

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        accessToken: json['accessToken'],
        clientId: json['clientId'],
        email: json['email'],
        installments: json['installments'],
        merchantCode: json['merchantCode'],
        paymentCode: json['paymentCode'],
        items: itemsFromJson(json['items']),
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'clientId': clientId,
        'email': email,
        'installments': installments,
        if (merchantCode != null) 'merchantCode': merchantCode,
        'paymentCode': paymentCode,
        'items': itemsToJson(items),
        'value': value,
      };
}
