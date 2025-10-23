// lib/models/customization_option.dart

// 定義一個選項組的結構，例如 "服裝類型"
class CustomizationGroup {
  final String title; // 組的標題，例如 "服裝類型"
  final List<CustomizationOption> options; // 該組包含的所有選項

  CustomizationGroup({required this.title, required this.options});
}

// 定義單一選項的結構，例如 "西裝套裝"
class CustomizationOption {
  final String name; // 選項的名稱
  final double additionalCost; // 該選項的額外費用

  CustomizationOption({required this.name, required this.additionalCost});

  // 格式化顯示名稱和價格
  String get displayName => '$name (+NT\$${additionalCost.toStringAsFixed(0)})';
}
