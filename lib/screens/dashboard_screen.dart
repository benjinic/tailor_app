// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// --- 新增：引入 Firestore 和 Intl 套件 ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 用於格式化數字
// --- (其他 import 不變) ---
import 'package:tailor_app/providers/cart_provider.dart';
import 'package:tailor_app/screens/cart_screen.dart';
import 'package:tailor_app/screens/client_list_screen.dart';
import 'package:tailor_app/screens/fabric_selection_screen.dart';
import 'package:tailor_app/screens/order_history_screen.dart';


// 將 DashboardScreen 改為 StatefulWidget 以便管理數據讀取
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- 現在可以正確識別 FirebaseFirestore 和 NumberFormat ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'zh_HK', symbol: 'NT\$', decimalDigits: 0);

  // --- 建立讀取數據流的輔助函式 ---

  // 讀取客戶總數
  Stream<int> _getClientCountStream() {
    return _firestore.collection('client').snapshots().map((snapshot) => snapshot.size);
  }

  // 讀取訂單總數
  Stream<int> _getOrderCountStream() {
    return _firestore.collection('orders').snapshots().map((snapshot) => snapshot.size);
  }

  // 計算今日營業額
  Stream<double> _getTodaysRevenueStream() {
    // 獲取今天的開始和結束時間戳
    final now = DateTime.now();
    final startOfToday = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfToday = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    return _firestore
        .collection('orders')
        .where('orderDate', isGreaterThanOrEqualTo: startOfToday)
        .where('orderDate', isLessThanOrEqualTo: endOfToday)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['total'] ?? 0.0).toDouble();
      }
      return total;
    });
  }

  // 計算總營業額
  Stream<double> _getTotalRevenueStream() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['total'] ?? 0.0).toDouble();
      }
      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALEXIS BESPOKE 主目錄'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: ch,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: '查看購物車',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        ],
      ),
      // 使用 ListView 允許頁面滾動
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 新增：數據統計區塊 ---
          _buildStatsSection(),
          const SizedBox(height: 24), // 增加間距
          // --- 原有的功能入口網格 ---
          _buildNavigationGrid(context),
        ],
      ),
    );
  }

  // 建立數據統計區塊的 Widget
  Widget _buildStatsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '營運概覽',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 使用 GridView 顯示四個統計數據
            GridView.count(
              crossAxisCount: 2, // 每行顯示兩個數據
              shrinkWrap: true, // 讓 GridView 高度自適應
              physics: const NeverScrollableScrollPhysics(), // 禁用 GridView 自身的滾動
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5, // 調整項目寬高比
              children: [
                _buildStatItem<double>( // <-- 指定泛型類型
                  label: '今日營業額',
                  stream: _getTodaysRevenueStream(),
                  formatter: _currencyFormat.format, // 使用貨幣格式化
                ),
                _buildStatItem<int>( // <-- 指定泛型類型
                  label: '客戶總數',
                  stream: _getClientCountStream(),
                  formatter: (value) => value.toString(), // 顯示整數
                ),
                 _buildStatItem<int>( // <-- 指定泛型類型
                  label: '總訂單數',
                  stream: _getOrderCountStream(),
                  formatter: (value) => value.toString(),
                ),
                _buildStatItem<double>( // <-- 指定泛型類型
                  label: '歷史總營業額',
                  stream: _getTotalRevenueStream(),
                  formatter: _currencyFormat.format,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 建立單個統計數據項目的 Widget (使用 StreamBuilder)
  Widget _buildStatItem<T>({
    required String label,
    required Stream<T> stream,
    required String Function(T) formatter,
  }) {
    return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
       ),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            // 使用 StreamBuilder 來監聽數據流並更新 UI
            StreamBuilder<T>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                      height: 18, 
                      child: Center(child: LinearProgressIndicator(minHeight: 2)) 
                    );
                }
                if (snapshot.hasError) {
                  print('統計數據錯誤 ($label): ${snapshot.error}'); // 打印錯誤
                  return const Text(
                    '錯誤',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  );
                }
                // --- 修改：處理 snapshot.data 為 null 的情況 ---
                if (!snapshot.hasData || snapshot.data == null) {
                  // 根據類型給出 0 或 0.0
                  final zeroValue = (T == int) ? 0 as T : 0.0 as T;
                  return Text(
                    formatter(zeroValue),
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  );
                }
                // 格式化並顯示數據
                return Text(
                  formatter(snapshot.data!),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
    );
  }

  // 建立功能入口網格的 Widget
  Widget _buildNavigationGrid(BuildContext context) {
     return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.0,
      children: [
         _buildDashboardItem(
            context,
            icon: Icons.people_outline,
            label: '客戶管理',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClientListScreen()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.style_outlined,
            label: '布料管理',
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FabricSelectionScreen()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.receipt_long_outlined,
            label: '訂單管理',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.settings_outlined,
            label: '系統設定',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('系統設定功能開發中...')),
              );
            },
          ),
      ],
    );
  }

  // (與之前相同) 建立單個功能入口的 Widget
  Widget _buildDashboardItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
   }
}

