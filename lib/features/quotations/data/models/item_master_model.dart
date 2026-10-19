/// Represents a single item/treatment from the Item Master API.
///
/// Maps to the objects inside `data.result` of:
///   GET /api/itemMaster/GetItemMastersByCompanyIdWithQuery/{companyId}
///       ?searchQuery=...&isTreatment=...
class ItemMasterModel {
  const ItemMasterModel({
    required this.itemMasterId,
    required this.itemName,
    required this.itemCode,
    required this.unitPrice,
    required this.sellingPrice,
    required this.unitName,
    required this.isTreatment,
  });

  final int itemMasterId;
  final String itemName;
  final String itemCode;
  final double unitPrice;
  final double sellingPrice;
  final String unitName;

  /// Derived from `category.isTreatment` in the API response.
  final bool isTreatment;

  factory ItemMasterModel.fromJson(Map<String, dynamic> json) {
    // Safely read nested unit name
    final unitMap = json['unit'] as Map<String, dynamic>?;
    final unitName = (unitMap?['unitName'] as String?) ?? '';

    // isTreatment lives inside the category object
    final categoryMap = json['category'] as Map<String, dynamic>?;
    final isTreatment = (categoryMap?['isTreatment'] as bool?) ?? false;

    return ItemMasterModel(
      itemMasterId: (json['itemMasterId'] as num).toInt(),
      itemName: (json['itemName'] as String?) ?? '',
      itemCode: (json['itemCode'] as String?) ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      unitName: unitName,
      isTreatment: isTreatment,
    );
  }

  @override
  String toString() => 'ItemMasterModel($itemMasterId, $itemName)';
}
