// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import 'package:tailor_app/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  // 購物車中的商品種類數量
  int get itemCount {
    return _items.length;
  }

  // 計算小計
  double get subtotal {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  // 計算稅金 (假設 5%)
  double get tax => subtotal * 0.05;

  // 計算總金額
  double get total => subtotal + tax;

  // 新增商品到購物車
  void addItem(CartItem cartItem) {
    // 如果商品已存在（相同的布料和客製化選項），則只增加數量
    // 為了簡化，我們這裡先假設每次加入都是一個新的獨立項目
    _items.putIfAbsent(cartItem.id, () => cartItem);
    notifyListeners(); // 通知監聽者（UI）更新
  }

  // 更新商品數量
  void updateQuantity(String itemId, int quantity) {
    if (_items.containsKey(itemId)) {
      _items.update(itemId, (existingItem) {
        existingItem.quantity = quantity;
        return existingItem;
      });
      notifyListeners();
    }
  }

  // 從購物車移除商品
  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  // 清空購物車
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

