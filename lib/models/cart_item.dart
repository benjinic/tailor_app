// lib/models/cart_item.dart

import 'package:tailor_app/models/customization_option.dart';
import 'package:tailor_app/models/fabric.dart';

class CartItem {
  final String id; // 每個購物車項目的唯一 ID
  final Fabric fabric; // 選擇的布料
  final Map<String, CustomizationOption> selectedOptions; // 所有客製化選項
  int quantity; // 數量
  final double unitPrice; // 此客製化組合的單價

  CartItem({
    required this.id,
    required this.fabric,
    required this.selectedOptions,
    this.quantity = 1,
    required this.unitPrice,
  });

  // 計算此項目的總價 (單價 * 數量)
  double get totalPrice => unitPrice * quantity;

  // 用於顯示在購物車中的客製化摘要
  String get customizationSummary {
    return selectedOptions.values
        .where((opt) => opt.additionalCost > 0) // 只顯示有額外費用的選項
        .map((opt) => opt.name)
        .join(', ');
  }
}
