import 'package:dartz/dartz.dart';
import 'package:erp_hr/core/domain/failures/failure.dart';
import 'package:erp_hr/core/network/api_client.dart';
import 'package:erp_hr/core/network/api_endpoints.dart';
import 'package:erp_hr/features/quotations/data/models/item_master_model.dart';

/// Handles item master search calls for the quotation / lead item picker.
///
/// Usage:
/// ```dart
/// final repo = ItemMasterRepository(apiClient);
/// final result = await repo.searchItems('ahamalki', isTreatment: false);
/// result.fold(
///   (failure) => showError(failure.message),
///   (items)   => setState(() => _searchResults = items),
/// );
/// ```
class ItemMasterRepository {
  ItemMasterRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Search items or treatments by [query] for [companyId] (default 1).
  ///
  /// Set [isTreatment] to `true` to search treatments, `false` for items.
  Future<Either<Failure, List<ItemMasterModel>>> searchItems(
    String query, {
    bool isTreatment = false,
    int companyId = 1,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.itemMasterSearch(companyId),
      queryParameters: {
        'searchQuery': query,
        'isTreatment': isTreatment,
      },
    );

    return result.fold(
      Left.new,
      (json) {
        try {
          final data = json['data'] as Map<String, dynamic>?;
          final resultList = data?['result'] as List<dynamic>? ?? [];
          final items = resultList
              .whereType<Map<String, dynamic>>()
              .map(ItemMasterModel.fromJson)
              .toList();
          return Right(items);
        } catch (e) {
          return Left(
            Failure.localFailure(
              message: 'Failed to parse item masters: $e',
            ),
          );
        }
      },
    );
  }
}
