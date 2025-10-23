// lib/models/order.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// 我們不再需要 Customer 模型，因為我們只儲存了 ID 和 Name
// import 'package:tailor_app/models/customer.dart';

// Firestore 中的單個訂單商品模型
class OrderItem {
  final String fabricName;
  final String customizationSummary;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.fabricName,
    required this.customizationSummary,
    required this.quantity,
    required this.unitPrice,
  });

  // 從 Firestore Map 建立 OrderItem 物件
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      fabricName: map['fabricName'] ?? '未知布料',
      customizationSummary: map['customizationSummary'] ?? '標準',
      quantity: (map['quantity'] ?? 1).toInt(),
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
    );
  }

  // 將 OrderItem 轉換為可以寫入 Firestore 的 Map 格式
  Map<String, dynamic> toJson() {
    return {
      'fabricName': fabricName,
      'customizationSummary': customizationSummary,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

// 訂單主模型
class Order {
  final String id; // Firestore 文件 ID (從 DocumentSnapshot 獲取)
  final String? customerId; // 關聯的客戶 ID
  final String customerName; // 客戶姓名 (可能是 '散客')
  final List<OrderItem> items; // 訂單中的所有商品
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod; // 付款方式
  final Timestamp orderDate; // 訂單日期 (保持 Timestamp)
  final String status; // 訂單狀態

  Order({
    required this.id,
    this.customerId,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.orderDate,
    required this.status,
  });

  // 從 Firestore DocumentSnapshot 建立 Order 物件
  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    // 解析 items 列表
    final itemsList = (data['items'] as List<dynamic>?)
            ?.map((itemData) => OrderItem.fromMap(itemData as Map<String, dynamic>))
            .toList() ?? // 如果 items 為 null 或格式錯誤，則給一個空列表
        [];

    return Order(
      id: doc.id, // ID 來自 Firestore 文件本身
      customerId: data['customerId'] as String?,
      customerName: data['customerName'] as String? ?? '散客',
      items: itemsList,
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] as String? ?? '未知',
      // 直接使用 Timestamp，不需要轉換
      orderDate: data['orderDate'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] as String? ?? '未知狀態',
    );
  }

  // 將 Order 轉換為可以寫入 Firestore 的 Map 格式
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate,
      'status': status,
    };
  }
}
