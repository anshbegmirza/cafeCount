import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<void> _editCategory(BuildContext context, WidgetRef ref, {ShopCategory? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => HrSheetScaffold(
        title: (existing == null ? 'addCategory' : 'editCategory').tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: 'categoryName'.tr()),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: Text('saveCategory'.tr()),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      final actions = ref.read(stockActionsProvider);
      if (existing == null) {
        await actions.createCategory(name: name.text.trim());
      } else {
        await actions.updateCategory(existing.id, name: name.text.trim());
      }
      ref.invalidate(categoriesProvider);
      ref.invalidate(productsProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, ShopCategory cat) async {
    final ok = await showHrBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => HrSheetScaffold(
        title: 'deleteCategory'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('deleteCategoryConfirm'.tr(), style: const TextStyle(fontSize: 16, color: HrColors.ink)),
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
      await ref.read(stockActionsProvider).deleteCategory(cat.id);
      ref.invalidate(categoriesProvider);
      ref.invalidate(productsProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }

  Future<void> _actions(BuildContext context, WidgetRef ref, ShopCategory cat) async {
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
              title: Text('editCategory'.tr()),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: HrColors.out),
              title: Text('deleteCategory'.tr(), style: const TextStyle(color: HrColors.out)),
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
      await _editCategory(context, ref, existing: cat);
    } else if (action == 'delete') {
      await _deleteCategory(context, ref, cat);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editCategory(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(HrLayout.side, 8, HrLayout.side, 0),
            child: Text('categories'.tr(), style: Theme.of(context).textTheme.headlineLarge),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: categories.when(
              loading: () => const HrListSkeleton(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                if (list.isEmpty) return Center(child: Text('noData'.tr()));
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(categoriesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(HrLayout.side, 0, HrLayout.side, 88),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = list[i];
                      return Card(
                        child: ListTile(
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _actions(context, ref, c),
                          ),
                          onTap: () => _actions(context, ref, c),
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
