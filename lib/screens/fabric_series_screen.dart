// lib/screens/fabric_series_screen.dart

import 'package:flutter/material.dart';
import 'package:tailor_app/models/fabric.dart';
// --- 修改：直接引入客製化頁面 ---
import 'package:tailor_app/screens/customization_screen.dart';

class FabricSeriesScreen extends StatelessWidget {
  final FabricBrand brand;

  const FabricSeriesScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        backgroundColor: brand.logoStartColor.withOpacity(0.8),
      ),
      body: ListView.builder(
        itemCount: brand.series.length,
        itemBuilder: (context, index) {
          final series = brand.series[index];
          return _buildSeriesTile(context, series);
        },
      ),
    );
  }

  Widget _buildSeriesTile(BuildContext context, FabricSeries series) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(series.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        subtitle: Text('${series.fabrics.length} 種布料'),
        children: series.fabrics.map((fabric) {
          return ListTile(
            title: Text(fabric.name),
            subtitle: Text('NT\$${fabric.price.toStringAsFixed(0)}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 4.0),
            onTap: () {
              // --- 修改：點擊後直接跳轉到客製化頁面 ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomizationScreen(fabric: fabric),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

