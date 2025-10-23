// lib/screens/fabric_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:tailor_app/data/fabric_data.dart';
import 'package:tailor_app/models/fabric.dart';
// 確保引入了新的系列頁面
import 'package:tailor_app/screens/fabric_series_screen.dart';

class FabricSelectionScreen extends StatelessWidget {
  const FabricSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('布料品牌'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 每行顯示四個品牌
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: fabricBrandsData.length,
        itemBuilder: (context, index) {
          final brand = fabricBrandsData[index];
          return _buildBrandCard(context, brand);
        },
      ),
    );
  }

  // 建立一個品牌卡片 Widget
  Widget _buildBrandCard(BuildContext context, FabricBrand brand) {
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // 點擊後直接導航到新的系列頁面
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FabricSeriesScreen(brand: brand),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: brand.logoStartColor.withOpacity(0.8),
              child: Text(
                brand.logoInitials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              brand.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis, // 如果名稱太長，顯示省略號
            ),
          ],
        ),
      ),
    );
  }
}

