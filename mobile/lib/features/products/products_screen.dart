import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatters.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';
import '../catalog/catalog_api.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key, this.initialStatusFilter});
  final String? initialStatusFilter;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _search = TextEditingController();
  String? _q;
  late String? _status; // null | low | out

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatusFilter;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider(_q));
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddProduct(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(HrLayout.side, 8, HrLayout.side, 0),
            child: Text('products'.tr(), style: Theme.of(context).textTheme.headlineLarge),
          ),
          Padding(
            padding: const EdgeInsets.all(HrLayout.side),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'searchProducts'.tr(),
              ),
              onChanged: (v) => setState(() => _q = v.trim()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: HrLayout.chipRowPadding,
            child: Row(
              children: [
                HrFilterChip(label: 'all'.tr(), selected: _status == null, onTap: () => setState(() => _status = null)),
                HrFilterChip(label: 'lowStock'.tr(), selected: _status == 'low', onTap: () => setState(() => _status = 'low')),
                HrFilterChip(label: 'outOfStock'.tr(), selected: _status == 'out', onTap: () => setState(() => _status = 'out')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: products.when(
              loading: () => const HrListSkeleton(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                final filtered = _status == null
                    ? list
                    : list.where((p) => p.stockStatus == _status || (_status == 'low' && (p.stockStatus == 'low' || p.stockStatus == 'out'))).toList();
                if (filtered.isEmpty) return Center(child: Text('noData'.tr()));
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(productsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final p = filtered[i];
                      return HrProductCard(
                        name: p.name,
                        subtitle: '${formatQtyUnit(p.currentQty, p.unit)} · min ${formatQtyUnit(p.minStock, p.unit)}',
                        status: p.stockStatus,
                        onTap: isAdmin ? () => _productActions(context, p) : null,
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  HrStatusChip(p.stockStatus),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => _productActions(context, p),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _productActions(BuildContext context, Product p) async {
    final action = await showHrBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        Text(
                          '${formatQtyUnit(p.currentQty, p.unit)} · min ${formatQtyUnit(p.minStock, p.unit)}',
                          style: const TextStyle(color: HrColors.muted),
                        ),
                      ],
                    ),
                  ),
                  HrStatusChip(p.stockStatus),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: HrColors.forest),
              title: Text('addStock'.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(ctx, 'add'),
            ),
            ListTile(
              leading: const Icon(Icons.tune, color: HrColors.forest),
              title: Text('adjustStock'.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(ctx, 'adjust'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: HrColors.forest),
              title: Text('editProduct'.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    if (action == 'add') {
      await _addStockSheet(context, p);
    } else if (action == 'adjust') {
      if (!context.mounted) return;
      await _adjustStockSheet(context, p);
    } else if (action == 'edit') {
      if (!context.mounted) return;
      await _editProductSheet(context, p);
    }
  }

  Future<void> _addStockSheet(BuildContext context, Product p) async {
    var qty = 1.0;
    final note = TextEditingController();
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => HrSheetScaffold(
          title: 'addStock'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${'available'.tr()}: ${formatQtyUnit(p.currentQty, p.unit)}', style: const TextStyle(color: HrColors.muted)),
                ],
              ),
              const SizedBox(height: 16),
              Text('quantityToAdd'.tr(), style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              HrQtyStepper(value: qty, unit: p.unit, min: 1, onChanged: (v) => setLocal(() => qty = v)),
              const SizedBox(height: 8),
              Text(
                '${'newTotal'.tr()}: ${formatQtyUnit(p.currentQty + qty, p.unit)}',
                style: const TextStyle(color: HrColors.ok, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(controller: note, decoration: InputDecoration(labelText: 'note'.tr())),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('confirmAdd'.tr())),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(stockActionsProvider).add(p.id, qty, note: note.text.trim().isEmpty ? null : note.text.trim());
      ref.invalidate(productsProvider);
      ref.invalidate(dashboardProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
    }
  }

  Future<void> _adjustStockSheet(BuildContext context, Product p) async {
    var qty = p.currentQty;
    final reason = TextEditingController();
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final delta = qty - p.currentQty;
          return HrSheetScaffold(
            title: 'adjustStock'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text('${'systemCount'.tr()}: ${formatQtyUnit(p.currentQty, p.unit)}', style: const TextStyle(color: HrColors.muted)),
                const SizedBox(height: 16),
                Text('newQty'.tr(), style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                HrQtyStepper(value: qty, unit: p.unit, min: 0, onChanged: (v) => setLocal(() => qty = v)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: HrColors.cream, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    delta > 0 ? '+${formatQtyUnit(delta, p.unit)}' : formatQtyUnit(delta, p.unit),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: reason, decoration: InputDecoration(labelText: 'reason'.tr())),
                const SizedBox(height: 20),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('saveAdjustment'.tr())),
              ],
            ),
          );
        },
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(stockActionsProvider).adjust(p.id, qty, note: reason.text.trim().isEmpty ? null : reason.text.trim());
      ref.invalidate(productsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(historyProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
    }
  }

  Widget _unitField({
    required List<ShopUnit> units,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final selected = units.any((u) => u.symbol == value) ? value : null;
    return InputDecorator(
      isEmpty: selected == null,
      decoration: const InputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text('selectUnit'.tr()),
          value: selected,
          style: const TextStyle(fontSize: 16, color: HrColors.ink),
          selectedItemBuilder: (ctx) => [
            for (final u in units)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(u.symbol, style: const TextStyle(fontSize: 16, color: HrColors.ink)),
              ),
          ],
          items: [
            for (final u in units)
              DropdownMenuItem(
                value: u.symbol,
                child: Text('${u.symbol} · ${u.name}'),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _editProductSheet(BuildContext context, Product p) async {
    final name = TextEditingController(text: p.name);
    final min = TextEditingController(text: p.minStock.toString());
    String? unitSymbol = p.unit;
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, sheetRef, _) {
          final unitsAsync = sheetRef.watch(unitsProvider);
          return StatefulBuilder(
            builder: (ctx, setLocal) => HrSheetScaffold(
              title: 'editProduct'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(controller: name, decoration: InputDecoration(labelText: 'name'.tr())),
                  const SizedBox(height: 12),
                  unitsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(e.toString()),
                    data: (units) => _unitField(
                      units: units,
                      value: unitSymbol,
                      onChanged: (v) => setLocal(() => unitSymbol = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: min,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'minStock'.tr()),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: unitSymbol == null ? null : () => Navigator.pop(ctx, true),
                    child: Text('saveChanges'.tr()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (ok != true || unitSymbol == null) return;
    try {
      await ref.read(stockActionsProvider).updateProduct(
            p.id,
            name: name.text.trim(),
            unit: unitSymbol!,
            minStock: double.tryParse(min.text.trim()) ?? p.minStock,
          );
      ref.invalidate(productsProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
    }
  }

  Future<void> _showAddProduct(BuildContext context) async {
    final name = TextEditingController();
    final min = TextEditingController(text: '0');
    final start = TextEditingController(text: '0');
    String? unitSymbol;
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, sheetRef, _) {
          final unitsAsync = sheetRef.watch(unitsProvider);
          return StatefulBuilder(
            builder: (ctx, setLocal) => HrSheetScaffold(
              title: 'newProduct'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(labelText: 'name'.tr()),
                    onChanged: (_) => setLocal(() {}),
                  ),
                  const SizedBox(height: 12),
                  unitsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(e.toString()),
                    data: (units) => _unitField(
                      units: units,
                      value: unitSymbol,
                      onChanged: (v) => setLocal(() => unitSymbol = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: min,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: 'minStock'.tr()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: start,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: 'startingQty'.tr()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: unitSymbol == null || name.text.trim().isEmpty
                        ? null
                        : () => Navigator.pop(ctx, true),
                    child: Text('saveProduct'.tr()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (ok != true || unitSymbol == null) return;
    try {
      await ref.read(stockActionsProvider).createProduct(
            name: name.text.trim(),
            unit: unitSymbol!,
            minStock: double.tryParse(min.text.trim()) ?? 0,
            initialQty: double.tryParse(start.text.trim()) ?? 0,
          );
      ref.invalidate(productsProvider);
      ref.invalidate(dashboardProvider);
      if (context.mounted) showHrToast(context, title: 'productAdded'.tr(), success: true);
    } catch (e) {
      if (context.mounted) showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
    }
  }
}
