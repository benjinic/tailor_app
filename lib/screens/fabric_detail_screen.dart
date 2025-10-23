// lib/screens/fabric_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:tailor_app/models/fabric.dart';
import 'package:tailor_app/screens/customization_screen.dart';

class FabricDetailScreen extends StatelessWidget {
  final Fabric fabric;
  // 我們需要直接接收品牌和系列名稱，因為 Fabric 物件本身不包含這些資訊
  final String brandName;
  final String seriesName;
  final Color brandColor;

  const FabricDetailScreen({
    super.key,
    required this.fabric,
    required this.brandName,
    required this.seriesName,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 使用傳入的 brandName 作為標題
        title: Text(brandName),
        backgroundColor: brandColor.withOpacity(0.8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 讓子元件填滿寬度
          children: [
            // 頂部卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fabric.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 使用傳入的 seriesName
                        _buildInfoColumn('系列', seriesName),
                        _buildInfoColumn('價格', 'NT\$${fabric.price.toStringAsFixed(0)}'),
                      ],
                    ),
                    const Divider(height: 32),
                     _buildInfoColumn('成分', fabric.composition, isRow: true),
                     const SizedBox(height: 12),
                    _buildInfoColumn('重量', fabric.weight, isRow: true),
                  ],
                ),
              ),
            ),
            const Spacer(), // 這個 Widget 會佔據所有剩餘的垂直空間
            // 底部按鈕
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: brandColor,
                foregroundColor: Colors.white, // 設定按鈕文字顏色
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomizationScreen(fabric: fabric),
                  ),
                );
              },
              child: const Text('開始客製化'),
            ),
          ],
        ),
      ),
    );
  }

  // 輔助函式，用於顯示資訊
  Widget _buildInfoColumn(String label, String value, {bool isRow = false}) {
    if (isRow) {
      return Row(
        children: [
          Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      );
    }
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}