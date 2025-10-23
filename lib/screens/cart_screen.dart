// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_app/providers/cart_provider.dart';
import 'package:tailor_app/screens/checkout_screen.dart'; // <-- 引入結帳頁面

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('我的購物車'),
          ),
          body: cart.items.isEmpty
              ? const Center(
                  child: Text(
                    '您的購物車是空的',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items.values.toList()[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: FittedBox(
                                child: Text('NT\$${item.unitPrice.toStringAsFixed(0)}'),
                              ),
                            ),
                          ),
                          title: Text(item.fabric.name),
                          subtitle: Text(
                            '客製化: ${item.customizationSummary.isEmpty ? '標準' : item.customizationSummary}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('x ${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  cart.removeItem(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: cart.items.isEmpty ? null : _buildCheckoutBar(context, cart),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ... (價格顯示部分不變)
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // --- 修改：導航到結帳頁面 ---
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              },
              child: const Text('前往結帳'),
            ),
          ),
        ],
      ),
    );
  }
  // ... (其他輔助函式不變)
}