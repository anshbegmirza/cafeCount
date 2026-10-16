import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  Future<void> _addUnit(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final symbol = TextEditingController();
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => HrSheetScaffold(
        title: 'addUnit'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: 'unitName'.tr()),
              textCapitalization: TextCapitalization.words,
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
      await ref.read(stockActionsProvider).createUnit(
            name: name.text.trim(),
            symbol: symbol.text.trim(),
          );
      ref.invalidate(unitsProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addUnit(context, ref),
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
