import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/formatters.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _search = TextEditingController();
  String? _q;
  Product? _selected;
  double _qty = 1;
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider(_q));

    // Nested scaffold so the confirm bar stays above the app bottom nav and stays tappable.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(HrLayout.side, 8, HrLayout.side, 0),
            child: Text('withdrawStock'.tr(), style: Theme.of(context).textTheme.headlineLarge),
          ),
          Padding(
            padding: const EdgeInsets.all(HrLayout.side),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'searchProducts'.tr(),
              ),
              onChanged: (v) => setState(() {
                final t = v.trim();
                _q = t.isEmpty ? null : t;
                _selected = null;
              }),
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const HrListSkeleton(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                if (list.isEmpty) return Center(child: Text('noData'.tr()));
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(productsProvider),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final p = list[i];
                      final selected = _selected?.id == p.id;
                      return Card(
                        margin: HrLayout.cardMargin,
                        color: selected ? HrColors.cream : HrColors.paper,
                        child: ListTile(
                          title: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          subtitle: Text('${'available'.tr()}: ${formatQtyUnit(p.currentQty, p.unit)}'),
                          trailing: HrStatusChip(p.stockStatus),
                          onTap: () => setState(() {
                            _selected = p;
                            _qty = 1;
                          }),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selected == null
          ? null
          : Material(
              color: HrColors.paper,
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(HrLayout.side, 12, HrLayout.side, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${_selected!.name} · ${formatQtyUnit(_selected!.currentQty, _selected!.unit)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    HrQtyStepper(
                      value: _qty,
                      unit: _selected!.unit,
                      min: 1,
                      onChanged: (v) => setState(() => _qty = v),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _confirm,
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: HrColors.cream),
                            )
                          : Text('confirmWithdraw'.tr()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirm() async {
    final p = _selected;
    if (p == null || _qty <= 0 || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(stockActionsProvider).withdraw(p.id, _qty);
      ref.invalidate(productsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(historyProvider);
      if (!mounted) return;
      showHrToast(
        context,
        title: 'withdrawSuccess'.tr(),
        detail: '${p.name} · ${formatQtyUnit(_qty, p.unit)}',
        success: true,
      );
      setState(() {
        _selected = null;
        _qty = 1;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.message : e.toString();
      showHrToast(
        context,
        title: e is ApiException && e.code == 'STOCK_INSUFFICIENT'
            ? 'notEnoughStock'.tr()
            : 'errorGeneric'.tr(),
        detail: msg,
        success: false,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
