// lib/data/customization_data.dart

import '../models/customization_option.dart';

// 存放所有客製化選項的靜態列表
final List<CustomizationGroup> customizationGroups = [
  CustomizationGroup(
    title: '服裝類型',
    options: [
      CustomizationOption(name: '西裝套裝', additionalCost: 8000),
      CustomizationOption(name: '西裝外套', additionalCost: 5000),
      CustomizationOption(name: '襯衫', additionalCost: 2000),
      CustomizationOption(name: '背心', additionalCost: 3000),
      CustomizationOption(name: '洋裝', additionalCost: 6000),
      CustomizationOption(name: '大衣', additionalCost: 12000),
    ],
  ),
  CustomizationGroup(
    title: '剪裁風格',
    options: [
      CustomizationOption(name: '經典剪裁', additionalCost: 0),
      CustomizationOption(name: '修身剪裁', additionalCost: 1000),
      CustomizationOption(name: '寬鬆剪裁', additionalCost: 800),
      CustomizationOption(name: '復古剪裁', additionalCost: 1500),
    ],
  ),
  CustomizationGroup(
    title: '尺寸調整',
    options: [
      CustomizationOption(name: '標準尺寸', additionalCost: 0),
      CustomizationOption(name: '客製尺寸', additionalCost: 2000),
      CustomizationOption(name: '加大尺寸', additionalCost: 1500),
      CustomizationOption(name: '嬌小尺寸', additionalCost: 1200),
    ],
  ),
  CustomizationGroup(
    title: '特殊工藝',
    options: [
      CustomizationOption(name: '無特殊工藝', additionalCost: 0),
      CustomizationOption(name: '刺繡工藝', additionalCost: 3000),
      CustomizationOption(name: '珠飾工藝', additionalCost: 4500),
      CustomizationOption(name: '手繪工藝', additionalCost: 6000),
    ],
  ),
];
