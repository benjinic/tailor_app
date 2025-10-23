// lib/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailor_app/models/customer.dart';
// 使用 'app_order' 前綴來區分我們的 Order 模型
import 'package:tailor_app/models/order.dart' as app_order;
import 'package:tailor_app/providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  String _selectedPaymentMethod = '現金';
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
     try {
      final snapshot = await FirebaseFirestore.instance.collection('client').get();
      final customersData = snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
       // 異步操作後檢查 Widget 是否還存在於 Widget 樹中
       if (mounted) {
         setState(() {
           _customers = customersData;
           _isLoading = false;
         });
       }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('讀取客戶列表失敗: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _processOrder() async {
    // 防止重複提交
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購物車是空的，無法結帳'), backgroundColor: Colors.orange),
        );
       setState(() => _isProcessing = false);
       return;
    }


    final orderItems = cart.items.values.map((cartItem) => app_order.OrderItem(
      fabricName: cartItem.fabric.name,
      customizationSummary: cartItem.customizationSummary,
      quantity: cartItem.quantity,
      unitPrice: cartItem.unitPrice,
    )).toList();

    // --- 再次確認 Order 建構函式呼叫正確 ---
    // 建立新訂單時，**不需要** 提供 id
    final newOrder = app_order.Order(
      // id: 'some-id', // <--- 建立新訂單時 **不要** 提供 ID
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name ?? '散客', // 必填
      items: orderItems, // 必填
      subtotal: cart.subtotal, // 必填
      tax: cart.tax, // 必填
      total: cart.total, // 必填
      paymentMethod: _selectedPaymentMethod, // 必填
      orderDate: Timestamp.now(), // 必填
      status: '新訂單', // 必填
    );
    // --- 確保結束 ---

    try {
      await FirebaseFirestore.instance.collection('orders').add(newOrder.toJson());
      cart.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('訂單已成功建立！'), backgroundColor: Colors.green),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('建立訂單失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final currentCustomerValue = _customers.any((c) => c.id == _selectedCustomer?.id)
        ? _selectedCustomer
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('確認結帳'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionCard( // 呼叫輔助函式
                  title: '選擇客戶 (可選)',
                  child: DropdownButtonFormField<Customer>(
                    value: currentCustomerValue,
                    hint: const Text('選擇一位客戶...'),
                    isExpanded: true,
                    items: _customers.map((customer) {
                      return DropdownMenuItem(
                        value: customer,
                        child: Text(customer.name),
                      );
                    }).toList(),
                    onChanged: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                      });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard( // 呼叫輔助函式
                  title: '選擇付款方式',
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    items: ['現金', '信用卡', '行動支付'].map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (method) {
                      if (method != null) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      }
                    },
                     decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionCard( // 呼叫輔助函式
                  title: '訂單總覽',
                  child: Column(
                    children: [
                      _buildPriceRow('小計', cart.subtotal), // 呼叫輔助函式
                      _buildPriceRow('稅金 (5%)', cart.tax), // 呼叫輔助函式
                      const Divider(height: 16),
                      _buildPriceRow('總金額', cart.total, isTotal: true), // 呼叫輔助函式
                    ],
                  ),
                )
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: _isProcessing
              ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
              : const Icon(Icons.check_circle_outline),
          label: Text(_isProcessing ? '處理中...' : '確認付款'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: _isProcessing ? null : _processOrder,
        ),
      ),
    );
  }

  // --- 確保 _buildSectionCard 輔助函式定義在 _CheckoutScreenState 內部 ---
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // --- 確保 _buildPriceRow 輔助函式定義在 _CheckoutScreenState 內部 ---
  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    final currencyFormat = NumberFormat.currency(locale: 'zh_HK', symbol: 'NT\$', decimalDigits: 0); // 確保格式化
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(currencyFormat.format(value), style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)), // 使用格式化
        ],
      ),
    );
  }
} // --- 確保 _CheckoutScreenState 的結尾括號存在 ---

