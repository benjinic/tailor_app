// lib/models/customer.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// 定義 Customer 物件的結構，讓程式碼更安全、更清晰
class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.createdAt,
  });

  // 一個工廠建構函式，可以從 Firestore 的文件中建立一個 Customer 物件
  // 這裡包含了我們修正過的、更強壯的日期處理邏輯
  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    DateTime parsedDate;
    final dynamic creationDateData = data['creationDate'];

    if (creationDateData is Timestamp) {
      // 如果是正確的 Timestamp 格式，直接轉換
      parsedDate = creationDateData.toDate();
    } else {
      // 如果是其他格式 (例如 String 或 null)，給一個預設值
      parsedDate = DateTime.now();
    }

    return Customer(
      id: doc.id,
      name: data['name'] ?? '姓名未提供',
      phone: data['phone'],
      email: data['email'],
      address: data['address'],
      notes: data['notes'],
      createdAt: parsedDate,
    );
  }
}
