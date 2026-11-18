import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  Future<void> _editUnit(BuildContext context, WidgetRef ref, {ShopUnit? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final symbol = TextEditingController(text: existing?.symbol ?? '');
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => HrSheetScaffold(
        title: (existing == null ? 'addUnit' : 'editUnit').tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: 'unitName'.tr()),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: symbol,
              decoration: InputDecoration(labelText: 'unitSymbol'.tr(), hintText: 'e.g. L, kg, pcs'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || symbol.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: Text('saveUnit'.tr()),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      final actions = ref.read(stockActionsProvider);
      if (existing == null) {
        await actions.createUnit(name: name.text.trim(), symbol: symbol.text.trim());
      } else {
        await actions.updateUnit(existing.id, name: name.text.trim(), symbol: symbol.text.trim());
      }
      ref.invalidate(unitsProvider);
      ref.invalidate(productsProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }

  Future<void> _deleteUnit(BuildContext context, WidgetRef ref, ShopUnit unit) async {
    final ok = await showHrBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => HrSheetScaffold(
        title: 'deleteUnit'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('deleteUnitConfirm'.tr(), style: const TextStyle(fontSize: 16, color: HrColors.ink)),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: HrColors.out),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('delete'.tr()),
            ),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(stockActionsProvider).deleteUnit(unit.id);
      ref.invalidate(unitsProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, ShopUnit unit) async {
    final action = await showHrBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: HrColors.forest),
              title: Text('editUnit'.tr()),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: HrColors.out),
              title: Text('deleteUnit'.tr(), style: const TextStyle(color: HrColors.out)),
              onTap: () => Navigator.pop(ctx, 'delete'),
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
    if (action == 'edit') {
      await _editUnit(context, ref, existing: unit);
    } else if (action == 'delete') {
      await _deleteUnit(context, ref, unit);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editUnit(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(HrLayout.side, 8, HrLayout.side, 0),
            child: Text('units'.tr(), style: Theme.of(context).textTheme.headlineLarge),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: units.when(
              loading: () => const HrListSkeleton(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                if (list.isEmpty) return Center(child: Text('noData'.tr()));
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(unitsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(HrLayout.side, 0, HrLayout.side, 88),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final u = list[i];
                      return Card(
                        child: ListTile(
                          dense: true,
                          title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(u.symbol, style: const TextStyle(color: HrColors.muted)),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _actions(context, ref, u),
                          ),
                          onTap: () => _actions(context, ref, u),
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
    );
  }
}
