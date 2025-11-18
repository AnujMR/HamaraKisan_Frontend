import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardData{
  final String id;
  final String commodity;
  final double price;
  final int quantity;
  final double total;
  final DateTime date;

  DashboardData({
    required this.id,
    required this.commodity,
    required this.price,
    required this.quantity,
    required this.total,
    required this.date,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      id: json['index'],
      commodity: json['commodity'],
      price: json['price'],
      quantity: json['quantity'],
      total: json['total'],
      date: DateTime.parse(json['date']),
    );
  }
}