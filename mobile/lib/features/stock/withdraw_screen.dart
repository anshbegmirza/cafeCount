import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
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
  String _q = '';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text('withdrawStock'.tr(), style: Theme.of(context).textTheme.headlineLarge),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'searchProducts'.tr(),
            ),
            onChanged: (v) => setState(() {
              _q = v.trim();
              _selected = null;
            }),
          ),
        ),
        Expanded(
          child: products.when(
            loading: () => const Center(child: CircularProgressIndicator(color: HrColors.forest)),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (list) {
              if (list.isEmpty) return Center(child: Text('noData'.tr()));
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  final selected = _selected?.id == p.id;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: selected ? HrColors.cream : HrColors.paper,
                    child: ListTile(
                      title: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      subtitle: Text('${'available'.tr()}: ${p.currentQty} ${p.unit}'),
                      trailing: HrStatusChip(p.stockStatus),
                      onTap: () => setState(() {
                        _selected = p;
                        _qty = 1;
                      }),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (_selected != null)
          Container(
            color: HrColors.paper,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_selected!.name} · ${_selected!.currentQty} ${_selected!.unit}',
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
                    child: Text('confirmWithdraw'.tr()),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirm() async {
    final p = _selected;
    if (p == null || _qty <= 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(stockActionsProvider).withdraw(p.id, _qty);
      ref.invalidate(productsProvider(_q));
      ref.invalidate(dashboardProvider);
      ref.invalidate(historyProvider);
      if (mounted) {
        showHrToast(context, title: 'withdrawSuccess'.tr(), detail: '${p.name} · $_qty ${p.unit}', success: true);
        setState(() {
          _selected = null;
          _qty = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException ? e.message : e.toString();
        showHrToast(
          context,
          title: 'notEnoughStock'.tr(),
          detail: msg,
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
