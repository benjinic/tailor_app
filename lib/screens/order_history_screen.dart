// lib/screens/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 用於格式化日期和貨幣
// 引入 Order 模型和 OrderDetailScreen
import 'package:tailor_app/models/order.dart';
import 'package:tailor_app/screens/order_detail_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 預先設定好貨幣和日期格式化工具
    final currencyFormat = NumberFormat.currency(locale: 'zh_HK', symbol: 'NT\$', decimalDigits: 0);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm'); // 日期時間格式

    return Scaffold(
      appBar: AppBar(
        title: const Text('訂單歷史記錄'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 監聽 'orders' 集合，並按訂單日期 'orderDate' 降序排列 (最新的在前)
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // --- 狀態處理 ---
          // 狀態一：正在載入資料
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 狀態二：載入過程中發生錯誤
          if (snapshot.hasError) {
            print('讀取訂單錯誤: ${snapshot.error}'); // 在控制台印出詳細錯誤，方便除錯
            return const Center(child: Text('無法載入訂單資料，請稍後再試'));
          }
          // 狀態三：沒有資料或集合為空
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '目前沒有任何訂單記錄',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // --- 成功獲取資料 ---
          final ordersDocs = snapshot.data!.docs;

          // 使用 ListView.builder 高效地建立列表
          return ListView.builder(
            itemCount: ordersDocs.length, // 列表項數量等於訂單數量
            itemBuilder: (context, index) {
              // 將 Firestore 的 DocumentSnapshot 轉換為我們定義的 Order 物件
              // 這樣可以更安全、更方便地存取資料
              final order = Order.fromFirestore(
                ordersDocs[index] as DocumentSnapshot<Map<String, dynamic>>,
              );
              
              // 格式化訂單日期字串
              final orderDateString = dateFormat.format(order.orderDate.toDate());

              // 建立每一行的卡片式列表項
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // 左側顯示付款方式的第一個字
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: FittedBox( // 自動縮小文字以適應空間
                       fit: BoxFit.scaleDown,
                       child: Text(
                         // 安全地獲取第一個字，避免空字串錯誤
                         order.paymentMethod.isNotEmpty ? order.paymentMethod.substring(0,1) : '?',
                         style: const TextStyle(fontWeight: FontWeight.bold)
                       ),
                    )
                  ),
                  // 標題顯示日期和客戶名稱
                  title: Text(
                    '${orderDateString.split(' ')[0]} - ${order.customerName}', // 只顯示日期部分
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // 副標題顯示時間和付款方式
                  subtitle: Text(
                     '時間: ${orderDateString.split(' ')[1]} / 方式: ${order.paymentMethod}'
                  ),
                  // 右側顯示格式化後的總金額
                  trailing: Text(
                    currencyFormat.format(order.total),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // 點擊列表項的行為
                  onTap: () {
                    // 導航到訂單詳情頁面，並將完整的 order 物件傳遞過去
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

