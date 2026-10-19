import 'dart:async';

import 'package:erp_hr/core/network/api_client.dart';
import 'package:erp_hr/core/utils/colors.dart';
import 'package:erp_hr/core/utils/spacing.dart';
import 'package:erp_hr/core/utils/text_styles.dart';
import 'package:erp_hr/features/quotations/data/models/item_master_model.dart';
import 'package:erp_hr/features/quotations/data/repositories/item_master_repository.dart';
import 'package:erp_hr/injector.dart';
import 'package:erp_hr/shared/widget/app_button.dart';
import 'package:erp_hr/shared/widget/app_text_field.dart';
import 'package:erp_hr/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Local line-item model for Lead creation (no discount)
// ──────────────────────────────────────────────────────────────────────────────

class _LeadLineItem {
  _LeadLineItem({
    required this.item,
  })  : quantity = 1,
        qtyController = TextEditingController(text: '1');

  final ItemMasterModel item;
  int quantity;
  final TextEditingController qtyController;

  double get lineTotal => quantity * item.sellingPrice;

  void dispose() {
    qtyController.dispose();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// CreateLeadPage
// ──────────────────────────────────────────────────────────────────────────────

/// ─────────────────────────────────────────────────────────────────────────
/// Alulanka Ayurvedic Hospital — "Get Lead" form.
///
/// Integrated with live item search:
///   • Radio buttons to pick Item or Treatment.
///   • AppTextField search bar, fetching from live API with dropdown overlay.
///   • Selected items/treatments list showing: Item Name | Unit | Qty | Unit Price | Total | Action (Delete)
///   • No discount columns.
///   • Updates the "Forecasted Value (LKR)" field automatically.
/// ─────────────────────────────────────────────────────────────────────────
class CreateLeadPage extends StatefulWidget {
  const CreateLeadPage({super.key, this.initialData});
  final Map<String, dynamic>? initialData;

  @override
  State<CreateLeadPage> createState() => _CreateLeadPageState();
}

class _CreateLeadPageState extends State<CreateLeadPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _forecastedValueController;
  late final TextEditingController _contactController;

  // ── Item search state ──────────────────────────────────────────────────────
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  late final ItemMasterRepository _itemRepo;

  List<ItemMasterModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  /// false = Item, true = Treatment
  bool _searchTreatments = false;

  Timer? _debounce;

  // ── Selected picked items ──────────────────────────────────────────────────
  final List<_LeadLineItem> _lineItems = [];

  // Tracks if the user manually modified Forecasted Value, so we don't overwrite it.
  bool _forecastedValueEditedByUser = false;

  bool _isSubmitting = false; // visual loading state

  // ── Overlay for search dropdown ────────────────────────────────────────────
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();

    _itemRepo = ItemMasterRepository(getIt<ApiClient>());

    _nameController = TextEditingController(
      text: widget.initialData?['name']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialData?['address']?.toString() ?? '',
    );

    final amount = widget.initialData?['forecastedValue'];
    final amountStr = amount != null
        ? (amount is double ? amount.toStringAsFixed(0) : amount.toString())
        : '';
    _forecastedValueController = TextEditingController(text: amountStr);

    _contactController = TextEditingController(
      text: widget.initialData?['phone']?.toString() ?? '',
    );

    if (amountStr.isNotEmpty) {
      _forecastedValueEditedByUser = true;
    }

    _searchController.addListener(_onSearchChanged);
    _searchFocus.addListener(_onFocusChanged);
    _forecastedValueController.addListener(_onForecastedValueChangedByUser);
  }

  // ── Listeners ─────────────────────────────────────────────────────────────

  void _onFocusChanged() {
    if (!_searchFocus.hasFocus) {
      _hideDropdown();
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _doSearch(q));
  }

  void _onForecastedValueChangedByUser() {
    // If the controller value does not match the auto value, user edited it
    if (_forecastedValueController.text != _formatAmount(_autoForecastedValue())) {
      _forecastedValueEditedByUser = true;
    }
  }

  // ── Search & Overlay ──────────────────────────────────────────────────────

  Future<void> _doSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    final result = await _itemRepo.searchItems(
      query,
      isTreatment: _searchTreatments,
    );

    result.fold(
      (failure) {
        setState(() {
          _isSearching = false;
          _searchError = failure.message;
        });
        _showOverlay();
      },
      (items) {
        setState(() {
          _isSearching = false;
          _searchResults = items;
          _searchError = null;
        });
        if (items.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      },
    );
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideDropdown() {
    _removeOverlay();
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Positioned(
          width: MediaQuery.of(context).size.width - 72.w, // matches width inside card padding
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, 52.h),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16.r),
              color: cs.surface,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280.h),
                child: _searchError != null
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Text(
                          _searchError!,
                          style: AppTextStyle.bodySmall
                              .withColor(cs.error),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (_, i) {
                          final item = _searchResults[i];
                          final alreadyAdded = _lineItems.any(
                              (l) => l.item.itemMasterId == item.itemMasterId);
                          return InkWell(
                            onTap: alreadyAdded ? null : () => _addItem(item),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: alreadyAdded
                                    ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                                    : cs.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: alreadyAdded
                                      ? cs.outlineVariant.withValues(alpha: 0.5)
                                      : cs.outlineVariant,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: item.isTreatment
                                          ? Colors.blue.withValues(alpha: 0.1)
                                          : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      item.isTreatment
                                          ? Icons.medical_services_outlined
                                          : Icons.inventory_2_outlined,
                                      color: item.isTreatment ? Colors.blue : Colors.orange,
                                      size: 20.sp,
                                    ),
                                  ),
                                  Gap.h12,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: item.isTreatment
                                                    ? Colors.blue.withValues(alpha: 0.12)
                                                    : Colors.orange.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                item.isTreatment ? 'Treatment' : 'Product',
                                                style: AppTextStyle.caption.copyWith(
                                                  fontSize: 9.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.isTreatment ? Colors.blue : Colors.orange,
                                                ),
                                              ),
                                            ),
                                            Gap.h6,
                                            if (item.itemCode.isNotEmpty)
                                              Text(
                                                '#${item.itemCode}',
                                                style: AppTextStyle.caption.withColor(cs.onSurfaceVariant),
                                              ),
                                          ],
                                        ),
                                        Gap.v4,
                                        Text(
                                          item.itemName,
                                          style: AppTextStyle.bodyMedium.bold.withColor(
                                            alreadyAdded ? cs.onSurfaceVariant : cs.onSurface,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Gap.v2,
                                        Text(
                                          'Unit: ${item.unitName.isNotEmpty ? item.unitName : "N/A"} · Price: LKR ${item.sellingPrice.toStringAsFixed(2)}',
                                          style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Gap.h12,
                                  alreadyAdded
                                      ? Container(
                                          padding: EdgeInsets.all(6.r),
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryDark.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: AppColor.primaryDark,
                                            size: 16.sp,
                                          ),
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(6.r),
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryDark.withValues(alpha: 0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: AppColor.primaryDark,
                                            size: 16.sp,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Add/Remove Items ──────────────────────────────────────────────────────

  void _addItem(ItemMasterModel item) {
    setState(() {
      _lineItems.add(_LeadLineItem(item: item));
      _updateForecastedValue();
    });
    _searchController.clear();
    _hideDropdown();
    _searchFocus.unfocus();
  }

  void _removeItem(int index) {
    setState(() {
      _lineItems[index].dispose();
      _lineItems.removeAt(index);
      _updateForecastedValue();
    });
  }

  // ── Calculation helper ────────────────────────────────────────────────────

  double _autoForecastedValue() {
    return _lineItems.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  String _formatAmount(double value) => value.toStringAsFixed(0);

  void _updateForecastedValue() {
    if (!_forecastedValueEditedByUser) {
      _forecastedValueController.text = _formatAmount(_autoForecastedValue());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _nameController.dispose();
    _addressController.dispose();
    _forecastedValueController.removeListener(_onForecastedValueChangedByUser);
    _forecastedValueController.dispose();
    _contactController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    for (final l in _lineItems) {
      l.dispose();
    }
    super.dispose();
  }

  void _onCancel() => Navigator.of(context).pop();

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_lineItems.isEmpty) {
      _showSnack('Please select at least one item or treatment');
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack(
        widget.initialData != null
            ? 'Lead updated successfully!'
            : 'Lead created successfully!',
      );
      Navigator.of(context).pop();
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = widget.initialData != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Lead' : 'Create Lead',
        isNeedBackButton: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _hideDropdown();
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: AbsorbPointer(
            absorbing: _isSubmitting,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please Enter the Following Details',
                          style: AppTextStyle.bodyMedium,
                        ),
                        Gap.v20,

                        // Customer Name
                        AppTextField(
                          label: 'Customer Name',
                          hint: '',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        Gap.v16,

                        // Customer Address
                        AppTextField(
                          label: 'Customer Address',
                          hint: '',
                          controller: _addressController,
                          prefixIcon: Icons.home_outlined,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        Gap.v16,

                        // Items & Treatments selector
                        _buildItemsAndTreatmentsSelector(cs),
                        Gap.v16,

                        // Forecasted Value
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Forecasted Value (LKR)',
                                hint: '',
                                controller: _forecastedValueController,
                                prefixIcon: Icons.trending_up_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            if (_lineItems.isNotEmpty &&
                                _forecastedValueEditedByUser)
                              Padding(
                                padding: EdgeInsets.only(left: 8.w, top: 18.h),
                                child: IconButton(
                                  tooltip: 'Reset to suggested total',
                                  onPressed: () {
                                    setState(() {
                                      _forecastedValueEditedByUser = false;
                                      _forecastedValueController.text =
                                          _formatAmount(_autoForecastedValue());
                                    });
                                  },
                                  icon: Icon(Icons.autorenew,
                                      size: 18.sp, color: cs.primary),
                                ),
                              ),
                          ],
                        ),
                        if (_lineItems.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              _forecastedValueEditedByUser
                                  ? 'Manually adjusted. Tap reset to use suggested total LKR ${_formatAmount(_autoForecastedValue())}.'
                                  : 'Suggested total based on selected items & treatments.',
                              style: AppTextStyle.bodySmall
                                  .withColor(cs.onSurfaceVariant),
                            ),
                          ),
                        Gap.v16,

                        // Contact Number
                        AppTextField(
                          label: 'Contact No',
                          hint: '',
                          controller: _contactController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        Gap.v24,

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.outlined(
                                label: 'Cancel',
                                onPressed: _onCancel,
                                height: 48.h,
                                fontSize: 15.sp,
                                borderRadius: 10.r,
                              ),
                            ),
                            Gap.h16,
                            Expanded(
                              child: AppButton(
                                label: _isSubmitting
                                    ? 'Saving...'
                                    : (isEditing ? 'Update' : 'Create'),
                                onPressed: _onSubmit,
                                height: 48.h,
                                fontSize: 15.sp,
                                borderRadius: 10.r,
                                backgroundColor: AppColor.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── Items & Treatments Selector ────────────────────────

  Widget _buildItemsAndTreatmentsSelector(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items & Treatments',
          style: AppTextStyle.label.withColor(cs.onSurface),
        ),
        Gap.v8,
        _buildSearchBar(cs),
        if (_lineItems.isNotEmpty) ...[
          Gap.v12,
          _buildItemTable(cs),
        ],
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: _searchTreatments,
              activeColor: AppColor.primaryDark,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _searchTreatments = val);
                  if (_searchController.text.trim().isNotEmpty) {
                    _doSearch(_searchController.text.trim());
                  }
                }
              },
            ),
            Text('Item', style: AppTextStyle.bodyMedium.withColor(cs.onSurface)),
            Gap.h16,
            Radio<bool>(
              value: true,
              groupValue: _searchTreatments,
              activeColor: AppColor.primaryDark,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _searchTreatments = val);
                  if (_searchController.text.trim().isNotEmpty) {
                    _doSearch(_searchController.text.trim());
                  }
                }
              },
            ),
            Text('Treatment', style: AppTextStyle.bodyMedium.withColor(cs.onSurface)),
          ],
        ),
        Gap.v8,
        CompositedTransformTarget(
          link: _layerLink,
          child: AppTextField(
            controller: _searchController,
            focusNode: _searchFocus,
            hint: _searchTreatments
                ? 'Search for a treatment...'
                : 'Search for an item...',
            prefixIcon: Icons.search,
            suffixIcon: _isSearching
                ? Padding(
                    padding: EdgeInsets.all(12.r),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryDark,
                      ),
                    ),
                  )
                : (_searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _hideDropdown();
                        },
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      )
                    : null),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTable(ColorScheme cs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lineItems.length,
      separatorBuilder: (_, __) => Gap.v12,
      itemBuilder: (context, index) {
        return _buildAddedItemCard(index, cs);
      },
    );
  }

  Widget _buildAddedItemCard(int index, ColorScheme cs) {
    final line = _lineItems[index];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Name + Delete button
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: line.item.isTreatment
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  line.item.isTreatment
                      ? Icons.medical_services_outlined
                      : Icons.inventory_2_outlined,
                  color: line.item.isTreatment ? Colors.blue : Colors.orange,
                  size: 22.sp,
                ),
              ),
              Gap.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.item.itemName,
                      style: AppTextStyle.bodyMedium.bold.withColor(cs.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.v2,
                    Text(
                      'Unit: ${line.item.unitName.isNotEmpty ? line.item.unitName : "N/A"}',
                      style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: cs.error,
                onPressed: () => _removeItem(index),
              ),
            ],
          ),
          Gap.v16,
          // Pricing Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unit Price',
                style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
              ),
              Text(
                'LKR ${line.item.sellingPrice.toStringAsFixed(2)}',
                style: AppTextStyle.bodySmall.bold.withColor(cs.onSurface),
              ),
            ],
          ),
          Gap.v12,
          // Quantity Controller Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity',
                style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (line.quantity > 1) {
                          line.quantity--;
                          line.qtyController.text = line.quantity.toString();
                          _updateForecastedValue();
                        }
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: cs.primary,
                  ),
                  SizedBox(
                    width: 50.w,
                    child: TextFormField(
                      controller: line.qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium.bold.withColor(cs.onSurface),
                      onChanged: (v) {
                        setState(() {
                          line.quantity = int.tryParse(v) ?? 1;
                          if (line.quantity < 1) line.quantity = 1;
                          _updateForecastedValue();
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(color: AppColor.primaryDark, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        line.quantity++;
                        line.qtyController.text = line.quantity.toString();
                        _updateForecastedValue();
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: cs.primary,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Gap.v8,
          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: AppTextStyle.bodyMedium.bold.withColor(cs.onSurface),
              ),
              Text(
                'LKR ${line.lineTotal.toStringAsFixed(2)}',
                style: AppTextStyle.bodyMedium.bold.withColor(AppColor.primaryDark),
              ),
            ],

          ),
        ],
      ),
    );
  }
}