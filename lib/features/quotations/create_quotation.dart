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
// Local line-item model (no Bloc needed — pure local state)
// ──────────────────────────────────────────────────────────────────────────────

class _LineItem {
  _LineItem({required this.item})
      : quantity = 1,
        discount = 0,
        qtyController = TextEditingController(text: '1'),
        discountController = TextEditingController(text: '0');

  final ItemMasterModel item;
  int quantity;
  double discount; // percent 0–100

  /// Input controllers kept per-row so the table fields are independent.
  final TextEditingController qtyController;
  final TextEditingController discountController;

  double get lineTotal =>
      quantity * item.sellingPrice * (1 - discount / 100);

  void dispose() {
    qtyController.dispose();
    discountController.dispose();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// QuotationFormPage
// ──────────────────────────────────────────────────────────────────────────────

/// ─────────────────────────────────────────────────────────────────────────
/// Alulanka Ayurvedic Hospital — "Create Quotation" form.
///
/// Section 3 "Item Details" follows the Sales Order UI:
///   • Search bar  →  live API results dropdown  →  add to table
///   • Table rows: Item Name | Unit | Qty | Unit Price | Discount % |
///                 Total Price | Delete
///   • Summary: Sub Total / global Discount % / Total Amount
///   • Attachments placeholder (file name shown, 10 MB limit note)
///
/// No Bloc/Cubit wiring — local State + real API search,
/// ready to wire a real QuotationCubit for submission later.
/// ─────────────────────────────────────────────────────────────────────────
class QuotationFormPage extends StatefulWidget {
  const QuotationFormPage({
    super.key,
    this.leadData,
    this.initialData,
  });

  /// Data carried over from a lead being converted (customer, contact, etc.).
  final Map<String, dynamic>? leadData;

  /// Present when editing an existing quotation.
  final Map<String, dynamic>? initialData;

  @override
  State<QuotationFormPage> createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  final _notesController = TextEditingController();

  // ── Item search ───────────────────────────────────────────────────────────
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  late final ItemMasterRepository _itemRepo;

  List<ItemMasterModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  /// Toggle: false = Items (isTreatment=false), true = Treatments
  bool _searchTreatments = false;

  Timer? _debounce;

  // ── Line items table ──────────────────────────────────────────────────────
  final List<_LineItem> _lineItems = [];

  // ── Global discount ───────────────────────────────────────────────────────
  final _globalDiscountController = TextEditingController(text: '0');
  double _globalDiscount = 0;

  // ── Attachment placeholder ────────────────────────────────────────────────
  String? _attachmentName;

  // ── Submission ────────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  // ── Overlay for the search dropdown ──────────────────────────────────────
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();

    _itemRepo = ItemMasterRepository(getIt<ApiClient>());

    final lead = widget.leadData;
    final editing = widget.initialData;

    _nameController = TextEditingController(
      text: editing?['name']?.toString() ?? lead?['name']?.toString() ?? '',
    );
    _addressController = TextEditingController(
      text:
          editing?['address']?.toString() ?? lead?['address']?.toString() ?? '',
    );
    _contactController = TextEditingController(
      text: editing?['phone']?.toString() ?? lead?['phone']?.toString() ?? '',
    );

    _searchController.addListener(_onSearchChanged);
    _searchFocus.addListener(_onFocusChanged);
    _globalDiscountController.addListener(_onGlobalDiscountChanged);
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

  void _onGlobalDiscountChanged() {
    final v = double.tryParse(_globalDiscountController.text) ?? 0;
    setState(() => _globalDiscount = v.clamp(0, 100));
  }

  // ── Search ────────────────────────────────────────────────────────────────

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

  // ── Overlay dropdown ──────────────────────────────────────────────────────

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
          width: MediaQuery.of(context).size.width - 32.w,
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
                          final alreadyAdded = _lineItems
                              .any((l) => l.item.itemMasterId == item.itemMasterId);
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

  // ── Add / Remove line items ───────────────────────────────────────────────

  void _addItem(ItemMasterModel item) {
    final alreadyAdded =
        _lineItems.any((l) => l.item.itemMasterId == item.itemMasterId);
    if (alreadyAdded) return;

    setState(() {
      _lineItems.add(_LineItem(item: item));
    });
    _searchController.clear();
    _hideDropdown();
    _searchFocus.unfocus();
  }

  void _removeItem(int index) {
    setState(() {
      _lineItems[index].dispose();
      _lineItems.removeAt(index);
    });
  }

  // ── Totals ────────────────────────────────────────────────────────────────

  double get _subTotal =>
      _lineItems.fold(0.0, (sum, l) => sum + l.lineTotal);

  double get _totalAmount => _subTotal * (1 - _globalDiscount / 100);

  // ── Submit ────────────────────────────────────────────────────────────────

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.isEmpty) {
      _showSnack('Please add at least one item or treatment');
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack(
        widget.initialData != null
            ? 'Quotation updated successfully!'
            : 'Quotation created successfully!',
      );
      Navigator.of(context).pop(true);
    });
  }

  void _onCancel() => Navigator.of(context).pop();

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _globalDiscountController.dispose();
    for (final l in _lineItems) {
      l.dispose();
    }
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEditing = widget.initialData != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Quotation' : 'Create Quotation',
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
                  // ── 1. Customer Details ──────────────────────────────────
                  _sectionCard(
                    cs: cs,
                    sectionNumber: '1',
                    title: 'Customer Details',
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Customer Name',
                          hint: '',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        Gap.v16,
                        AppTextField(
                          label: 'Customer Address',
                          hint: '',
                          controller: _addressController,
                          prefixIcon: Icons.home_outlined,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        Gap.v16,
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
                      ],
                    ),
                  ),

                  Gap.v16,

                  // ── 2. Notes ─────────────────────────────────────────────
                  _sectionCard(
                    cs: cs,
                    sectionNumber: '2',
                    title: 'Notes',
                    child: AppTextField(
                      label: 'Notes (Optional)',
                      hint: '',
                      controller: _notesController,
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                  ),

                  Gap.v16,

                  // ── 3. Item Details ──────────────────────────────────────
                  _sectionCard(
                    cs: cs,
                    sectionNumber: '3',
                    title: 'Item Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(cs),
                        if (_lineItems.isNotEmpty) ...[
                          Gap.v16,
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _lineItems.length,
                            separatorBuilder: (_, __) => Gap.v12,
                            itemBuilder: (context, index) {
                              return _buildItemCard(index, cs);
                            },
                          ),
                          Gap.v16,
                          _buildSummary(cs),
                        ],
                      ],
                    ),
                  ),

                  Gap.v16,

                  // ── 4. Attachments ───────────────────────────────────────
                  _sectionCard(
                    cs: cs,
                    sectionNumber: '4',
                    title: 'Attachments',
                    child: _buildAttachments(cs),
                  ),

                  Gap.v24,

                  // ── Submit / Cancel ──────────────────────────────────────
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
                              : (isEditing ? 'Update' : 'Submit'),
                          onPressed: _onSubmit,
                          height: 48.h,
                          fontSize: 15.sp,
                          borderRadius: 10.r,
                          backgroundColor: AppColor.primaryDark,
                        ),
                      ),
                    ],
                  ),

                  Gap.v16,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section card wrapper
  // ──────────────────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required ColorScheme cs,
    required String sectionNumber,
    required String title,
    required Widget child,
  }) {
    return Container(
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
          // Section header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Text(
              '$sectionNumber. $title',
              style: AppTextStyle.h6.withColor(cs.onSurface),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: child,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Search bar
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle: Item or Treatment using Radio buttons
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
        Gap.v10,
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
                      child: CircularProgressIndicator(
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

  // ──────────────────────────────────────────────────────────────────────────
  // Item table
  // ──────────────────────────────────────────────────────────────────────────

  // Widget _buildItemTable(ColorScheme cs) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Table header
  //       _tableHeader(cs),
  //       const Divider(height: 1),
  //       // Rows
  //       ...List.generate(_lineItems.length, (i) {
  //         final isLast = i == _lineItems.length - 1;
  //         return Column(
  //           children: [
  //             _tableRow(cs, i),
  //             if (!isLast) Divider(height: 1.h, color: cs.outlineVariant),
  //           ],
  //         );
  //       }),
  //     ],
  //   );
  // }

  Widget _buildItemCard(int index, ColorScheme cs) {
    final line = _lineItems[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            children: [

              CircleAvatar(
                radius: 22,
                child: Icon(Icons.inventory_2_outlined),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      line.item.itemName,
                      style: AppTextStyle.label.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      line.item.unitName,
                      style: AppTextStyle.bodySmall,
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () => _removeItem(index),
              )
            ],
          ),

          SizedBox(height: 16),

          /// Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text("Unit Price"),

              Text(
                "LKR ${line.item.sellingPrice.toStringAsFixed(2)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: 16),

          /// Quantity
          Row(
            children: [

              Text("Qty"),

              Spacer(),

              IconButton(
                onPressed: () {
                  setState(() {
                    if (line.quantity > 1) {
                      line.quantity--;
                      line.qtyController.text =
                          line.quantity.toString();
                    }
                  });
                },
                icon: Icon(Icons.remove_circle_outline),
              ),

              Text(
                line.quantity.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    line.quantity++;
                    line.qtyController.text =
                        line.quantity.toString();
                  });
                },
                icon: Icon(Icons.add_circle),
              ),
            ],
          ),

          SizedBox(height: 16),

          /// Discount
          TextFormField(
            controller: line.discountController,
            decoration: InputDecoration(
              labelText: "Discount %",
            ),
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) {
              setState(() {
                line.discount =
                    (double.tryParse(v) ?? 0).clamp(0, 100);
              });
            },
          ),

          SizedBox(height: 16),

          Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "Total",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "LKR ${line.lineTotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Row(
        children: [
          _hCell(cs, 'Item Name', flex: 4),
          _hCell(cs, 'Unit', flex: 2),
          _hCell(cs, 'Qty', flex: 2),
          _hCell(cs, 'Unit Price', flex: 3),
          _hCell(cs, 'Disc. %', flex: 2),
          _hCell(cs, 'Total', flex: 3),
          SizedBox(width: 56.w), // Delete button column
        ],
      ),
    );
  }

  Widget _hCell(ColorScheme cs, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyle.labelSmall
            .withColor(cs.onSurfaceVariant)
            .copyWith(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _tableRow(ColorScheme cs, int index) {
    final line = _lineItems[index];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item name
          Expanded(
            flex: 4,
            child: Text(
              line.item.itemName,
              style: AppTextStyle.bodySmall.withColor(cs.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Unit
          Expanded(
            flex: 2,
            child: Text(
              line.item.unitName,
              style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Quantity
          Expanded(
            flex: 2,
            child: _inlineNumberField(
              controller: line.qtyController,
              cs: cs,
              onChanged: (v) {
                setState(() {
                  line.quantity = int.tryParse(v) ?? 1;
                  if (line.quantity < 1) line.quantity = 1;
                });
              },
            ),
          ),
          // Unit price
          Expanded(
            flex: 3,
            child: Text(
              line.item.sellingPrice.toStringAsFixed(2),
              style: AppTextStyle.bodySmall.withColor(cs.onSurface),
            ),
          ),
          // Discount %
          Expanded(
            flex: 2,
            child: _inlineNumberField(
              controller: line.discountController,
              cs: cs,
              isDecimal: true,
              onChanged: (v) {
                setState(() {
                  line.discount = (double.tryParse(v) ?? 0).clamp(0, 100);
                });
              },
            ),
          ),
          // Total
          Expanded(
            flex: 3,
            child: Text(
              line.lineTotal.toStringAsFixed(2),
              style: AppTextStyle.bodySmall
                  .withColor(cs.onSurface)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // Delete
          SizedBox(
            width: 56.w,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(color: cs.error.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              onPressed: () => _removeItem(index),
              child: Text(
                'Delete',
                style: AppTextStyle.caption.withColor(cs.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineNumberField({
    required TextEditingController controller,
    required ColorScheme cs,
    bool isDecimal = false,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      height: 34.h,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        inputFormatters: isDecimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyle.bodySmall.withColor(cs.onSurface),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          filled: true,
          fillColor: cs.surfaceContainerHighest,
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
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Summary block
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSummary(ColorScheme cs) {
    return Column(
      children: [
        const Divider(),
        _summaryRow(cs, 'Sub Total', _subTotal.toStringAsFixed(2)),
        Gap.v8,
        _summaryDiscountRow(cs),
        Gap.v8,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.primaryDark.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTextStyle.label
                    .withColor(cs.onSurface)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'LKR ${_totalAmount.toStringAsFixed(2)}',
                style: AppTextStyle.label
                    .withColor(AppColor.primaryDark)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(ColorScheme cs, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.bodyMedium.withColor(cs.onSurface)),
          Text(
            'LKR $value',
            style: AppTextStyle.bodyMedium
                .withColor(cs.onSurface)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _summaryDiscountRow(ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('- Discount (%)',
              style: AppTextStyle.bodyMedium.withColor(cs.onSurface)),
          SizedBox(
            width: 72.w,
            height: 34.h,
            child: TextFormField(
              controller: _globalDiscountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: AppTextStyle.bodySmall.withColor(cs.onSurface),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
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
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Attachments
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildAttachments(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (if any)',
          style: AppTextStyle.label.withColor(cs.onSurfaceVariant),
        ),
        Gap.v8,
        Row(
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file, size: 16.sp),
              label: Text(
                'Choose Files',
                style: AppTextStyle.bodySmall.withColor(cs.onSurface),
              ),
            ),
            Gap.h10,
            Expanded(
              child: Text(
                _attachmentName ?? 'No file chosen',
                style: AppTextStyle.bodySmall.withColor(cs.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Gap.v4,
        Text(
          'File size limit: 10MB',
          style: AppTextStyle.caption.withColor(cs.onSurfaceVariant),
        ),
      ],
    );
  }

  void _pickFile() {
    // Placeholder — wire to file_picker or image_picker when package is added.
    setState(() => _attachmentName = 'example_document.pdf');
    _showSnack('File picker not yet wired (placeholder)');
  }
}