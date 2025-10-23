// lib/models/fabric.dart

import 'package:flutter/material.dart';

// 單一布料的模型
class Fabric {
  final String id;
  final String name;
  final int price;
  final String composition;
  final String weight;

  const Fabric({
    required this.id,
    required this.name,
    required this.price,
    required this.composition,
    required this.weight,
  });
}

// 布料系列的模型
class FabricSeries {
  final String id;
  final String name;
  final List<Fabric> fabrics;

  const FabricSeries({
    required this.id,
    required this.name,
    required this.fabrics,
  });
}

// 布料品牌的模型
class FabricBrand {
  final String id;
  final String name;
  final String logoInitials;
  // 這裡的屬性名稱是 logoStartColor 和 logoEndColor
  final Color logoStartColor;
  final Color logoEndColor;
  final List<FabricSeries> series;

  const FabricBrand({
    required this.id,
    required this.name,
    required this.logoInitials,
    required this.logoStartColor,
    required this.logoEndColor,
    required this.series,
  });
}