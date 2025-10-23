// lib/screens/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tailor_app/models/order.dart'; // 引入我們更新後的 Order 模型

class OrderDetailScreen extends StatelessWidget {
  final Order order; // 接收從列表頁傳來的 Order 物件

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_HK', symbol: 'NT\$', decimalDigits: 0);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm:ss'); // 更詳細的日期時間格式

    return Scaffold(
      appBar: AppBar(
        title: Text('訂單詳情 #${order.id.substring(0, 6)}...'), // 顯示部分 ID
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 訂單基本資訊卡片
          _buildInfoCard(
            title: '訂單資訊',
            children: [
              _buildInfoRow('訂單編號:', order.id),
              _buildInfoRow('訂單日期:', dateFormat.format(order.orderDate.toDate())),
              _buildInfoRow('客戶姓名:', order.customerName),
              _buildInfoRow('付款方式:', order.paymentMethod),
              _buildInfoRow('訂單狀態:', order.status), // 顯示訂單狀態
            ],
          ),
          const SizedBox(height: 16),

          // 商品列表卡片
          _buildInfoCard(
            title: '商品列表 (${order.items.length} 項)',
            children: [
              // 表頭
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                   children: [
                      Expanded(flex: 3, child: Text('商品名稱', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('數量', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('單價', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                   ],
                ),
              ),
              const Divider(),
              // 商品項目
              ...order.items.map((item) => _buildOrderItemTile(item, currencyFormat)).toList(),
            ],
          ),
           const SizedBox(height: 16),

          // 金額明細卡片
          _buildInfoCard(
             title: '金額明細',
             children: [
                _buildPriceRow('小計:', currencyFormat.format(order.subtotal)),
                _buildPriceRow('稅金 (5%):', currencyFormat.format(order.tax)),
                const Divider(height: 16),
                _buildPriceRow('總金額:', currencyFormat.format(order.total), isTotal: true),
             ],
          ),
        ],
      ),
    );
  }

  // 輔助函式：建立資訊卡片
  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // 輔助函式：建立單行基本資訊
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

   // 輔助函式：建立商品列表項
  Widget _buildOrderItemTile(OrderItem item, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
              children: [
                Expanded(flex: 3, child: Text(item.fabricName)),
                Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text(currencyFormat.format(item.unitPrice), textAlign: TextAlign.right)),
              ],
           ),
           // 如果有客製化選項，顯示出來
           if (item.customizationSummary.isNotEmpty && item.customizationSummary != '標準配置')
              Padding(
                 padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                 child: Text(
                    '客製化: ${item.customizationSummary}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                 ),
              ),
         ],
      ),
    );
  }

  // 輔助函式：建立金額明細行
  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
