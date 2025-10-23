// lib/data/fabric_data.dart
import 'package:flutter/material.dart';
import '../models/fabric.dart';

// 這是基於您 Web App 的靜態布料資料。
// 在後續步驟中，我們會將這些資料遷移到 Firestore 中。
final List<FabricBrand> fabricBrandsData = [
  const FabricBrand(
    id: 'LORO_PIANA',
    name: 'LORO PIANA',
    logoInitials: 'LP',
    logoStartColor: Color(0xFFc2a25d),
    logoEndColor: Color(0xFF8c6d3a),
    series: [
      FabricSeries(
        id: 'SUPER130',
        name: "Super 130's",
        fabrics: [
          Fabric(id: 'lp_s130_1', name: 'Loro Piana Super 130\'s 深藍', price: 45000, composition: '100% 澳洲美麗諾羊毛', weight: '280g/m²'),
          Fabric(id: 'lp_s130_2', name: 'Loro Piana Super 130\'s 炭灰', price: 45000, composition: '100% 澳洲美麗諾羊毛', weight: '280g/m²'),
          Fabric(id: 'lp_s130_3', name: 'Loro Piana Super 130\'s 黑色', price: 45000, composition: '100% 澳洲美麗諾羊毛', weight: '280g/m²'),
        ],
      ),
       FabricSeries(
        id: 'SUPER150',
        name: "Super 150's",
        fabrics: [
          Fabric(id: 'lp_s150_1', name: 'Loro Piana Super 150\'s 深藍', price: 55000, composition: '100% 澳洲美麗諾羊毛', weight: '260g/m²'),
          Fabric(id: 'lp_s150_2', name: 'Loro Piana Super 150\'s 炭灰', price: 55000, composition: '100% 澳洲美麗諾羊毛', weight: '260g/m²'),
        ],
      ),
    ],
  ),
  const FabricBrand(
    id: 'VBC',
    name: 'VBC',
    logoInitials: 'VBC',
    logoStartColor: Color(0xFF2563eb),
    logoEndColor: Color(0xFF3b82f6),
    series: [
      FabricSeries(
        id: 'SUNNY_SEASON',
        name: 'Sunny Season',
        fabrics: [
          Fabric(id: 'vbc_sunny_1', name: 'VBC Sunny Season 淺藍', price: 32000, composition: '100%純羊毛', weight: '240g/m²'),
          Fabric(id: 'vbc_sunny_2', name: 'VBC Sunny Season 米色', price: 32000, composition: '100%純羊毛', weight: '240g/m²'),
        ],
      ),
       FabricSeries(
        id: 'PERENNIAL',
        name: 'Perennial',
        fabrics: [
          Fabric(id: 'vbc_perennial_1', name: 'VBC Perennial 深藍', price: 28000, composition: '100%純羊毛', weight: '280g/m²'),
          Fabric(id: 'vbc_perennial_2', name: 'VBC Perennial 炭灰', price: 28000, composition: '100%純羊毛', weight: '280g/m²'),
        ],
      ),
    ],
  ),
    const FabricBrand(
    id: 'DRAGO',
    name: 'DRAGO',
    logoInitials: 'DG',
    logoStartColor: Color(0xFF16a34a),
    logoEndColor: Color(0xFF22c55e),
    series: [
      FabricSeries(
        id: 'SUPER120',
        name: "Super 120's",
        fabrics: [
          Fabric(id: 'drago_s120_1', name: 'Drago Super 120\'s 深藍', price: 28000, composition: '100%純羊毛', weight: '290g/m²'),
          Fabric(id: 'drago_s120_2', name: 'Drago Super 120\'s 灰色', price: 28000, composition: '100%純羊毛', weight: '290g/m²'),
        ],
      ),
    ],
  ),
  // 為了簡潔，此處省略其他品牌，但可以按照此格式繼續添加
];
