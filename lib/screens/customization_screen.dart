// lib/screens/customization_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailor_app/models/cart_item.dart';
import 'package:tailor_app/models/fabric.dart';
import 'package:tailor_app/data/customization_data.dart';
import 'package:tailor_app/models/customization_option.dart';
import 'package:tailor_app/providers/cart_provider.dart';
import 'package:tailor_app/screens/cart_screen.dart'; // 引入購物車頁面

class CustomizationScreen extends StatefulWidget {
  final Fabric fabric; // 接收從上一頁傳來的布料物件

  const CustomizationScreen({super.key, required this.fabric});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  // 使用 Map 來儲存每一組的選中項
  late Map<String, CustomizationOption> _selectedOptions;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // 初始化選中項，預設選中每組的第一個 (通常是免費的)
    _selectedOptions = {
      for (var group in customizationGroups)
        group.title: group.options.first,
    };
    _calculateTotalPrice(); // 計算初始總價
  }

  // 計算總價
  void _calculateTotalPrice() {
    double customCost = 0.0;
    _selectedOptions.values.forEach((option) {
      customCost += option.additionalCost;
    });
    setState(() {
      _totalPrice = widget.fabric.price + customCost;
    });
  }

  // 加入購物車的邏輯，包含錯誤處理
  void _addToCart() {
    try {
      // 嘗試獲取 CartProvider
      final cart = Provider.of<CartProvider>(context, listen: false);

      // 建立購物車商品物件
      final newItem = CartItem(
        // --- 修正：使用正確的 toIso8601String() 函式 ---
        id: DateTime.now().toIso8601String(), // 使用 ISO 8601 標準時間字串確保 ID 唯一
        fabric: widget.fabric,
        selectedOptions: Map.from(_selectedOptions), // 創建選項的副本
        unitPrice: _totalPrice,
        quantity: 1,
      );

      // 將商品加入購物車
      cart.addItem(newItem);

      // 顯示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已成功加入購物車！'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green, // 綠色背景表示成功
        ),
      );

      // 直接用購物車頁面取代目前頁面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } catch (error) {
      // 如果在獲取 Provider 或執行過程中出錯，顯示錯誤提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加入購物車失敗: $error'),
          backgroundColor: Colors.red, // 紅色背景表示錯誤
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fabric.name} - 客製化'),
      ),
      body: Column(
        children: [
          // 可滾動的選項列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: customizationGroups.length,
              itemBuilder: (context, index) {
                final group = customizationGroups[index];
                return _buildOptionGroup(group); // 建立每個選項組的 UI
              },
            ),
          ),
          // 底部的總價和按鈕區域
          _buildBottomBar(),
        ],
      ),
    );
  }

  // 建立一個選項組的 UI Widget
  Widget _buildOptionGroup(CustomizationGroup group) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 選項組標題
            Text(
              group.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 使用 Wrap 讓選項按鈕可以自動換行
            Wrap(
              spacing: 8.0, // 水平間距
              runSpacing: 4.0, // 垂直間距
              children: group.options.map((option) {
                // 檢查此選項是否為當前選中項
                final isSelected = _selectedOptions[group.title] == option;
                // ChoiceChip 是一個適合單選的按鈕 Widget
                return ChoiceChip(
                  label: Text(option.displayName), // 顯示選項名稱和價格
                  selected: isSelected,
                  onSelected: (selected) {
                    // 當使用者選擇此選項時
                    if (selected) {
                      setState(() {
                        _selectedOptions[group.title] = option; // 更新選中的選項
                        _calculateTotalPrice(); // 重新計算總價
                      });
                    }
                  },
                  // 設定選中時的樣式
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.8),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black, // 選中時文字變白
                  ),
                );
              }).toList(), // 將所有選項按鈕轉換為列表
            ),
          ],
        ),
      ),
    );
  }

  // 建立底部的價格顯示和「加入購物車」按鈕
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 24.0), // 底部留出更多空間
      decoration: BoxDecoration(
        color: Colors.white, // 白色背景
        // 頂部加上陰影，使其看起來浮動在列表上方
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5), // 陰影向上偏移
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 高度只包裹內容
        children: [
          // 顯示總價
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('客製化總價:', style: TextStyle(fontSize: 18)),
              Text(
                'NT\$${_totalPrice.toStringAsFixed(0)}', // 格式化價格，不顯示小數點
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // 綠色表示價格
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 「加入購物車」按鈕
          SizedBox(
            width: double.infinity, // 按鈕寬度填滿
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: _addToCart, // 點擊時觸發 _addToCart 函式
              child: const Text('加入購物車'),
            ),
          ),
        ],
      ),
    );
  }
}

