import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(staffProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStaff(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('staff'.tr(), style: Theme.of(context).textTheme.headlineLarge),
          ),
          Expanded(
            child: staff.when(
              loading: () => const Center(child: CircularProgressIndicator(color: HrColors.forest)),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (users) {
                if (users.isEmpty) return Center(child: Text('noData'.tr()));
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(staffProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final u = users[i];
                      final active = u['isActive'] == true || u['isActive'] == 1;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(u['username']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                          subtitle: Text('${u['email']} · ${u['role']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                active ? 'active'.tr() : 'inactive'.tr(),
                                style: TextStyle(color: active ? HrColors.ok : HrColors.muted, fontWeight: FontWeight.w600),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _actions(context, ref, u),
                              ),
                            ],
                          ),
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

  Future<void> _actions(BuildContext context, WidgetRef ref, Map<String, dynamic> u) async {
    final active = u['isActive'] == true || u['isActive'] == 1;
    final action = await showHrBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: HrColors.forest),
              title: Text('editStaff'.tr()),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            if (active)
              ListTile(
                leading: const Icon(Icons.person_off_outlined, color: HrColors.out),
                title: Text('deactivate'.tr(), style: const TextStyle(color: HrColors.out)),
                onTap: () => Navigator.pop(ctx, 'deactivate'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
            ),
          ],
        ),
      ),
    );
    if (action == 'edit' && context.mounted) await _editStaff(context, ref, u);
    if (action == 'deactivate' && context.mounted) await _deactivate(context, ref, u);
  }

  Future<void> _editStaff(BuildContext context, WidgetRef ref, Map<String, dynamic> u) async {
    // API has no user profile PATCH beyond active — show read-only + role note; keep sheet for UX consistency.
    await showHrBottomSheet<void>(
      context: context,
      builder: (ctx) => HrSheetScaffold(
        title: 'editStaff'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              readOnly: true,
              controller: TextEditingController(text: u['username']?.toString() ?? ''),
              decoration: InputDecoration(labelText: 'username'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: u['email']?.toString() ?? ''),
              decoration: InputDecoration(labelText: 'email'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: u['role']?.toString() ?? ''),
              decoration: InputDecoration(labelText: 'role'.tr()),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          ],
        ),
      ),
    );
  }

  Future<void> _deactivate(BuildContext context, WidgetRef ref, Map<String, dynamic> u) async {
    final id = u['id'] as int;
    final ok = await showHrBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => HrSheetScaffold(
        title: 'deactivate'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('deactivateConfirm'.tr(), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(u['username']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: HrColors.out),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('deactivate'.tr()),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(stockActionsProvider).setUserActive(id, false);
      ref.invalidate(staffProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
    }
  }

  Future<void> _addStaff(BuildContext context, WidgetRef ref) async {
    final username = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    var role = 'employee';
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => HrSheetScaffold(
          title: 'newEmployee'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: username, decoration: InputDecoration(labelText: 'username'.tr())),
              const SizedBox(height: 12),
              TextField(controller: email, decoration: InputDecoration(labelText: 'email'.tr())),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: 'password'.tr())),
              const SizedBox(height: 12),
              Text('role'.tr(), style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('employee'.tr()),
                      selected: role == 'employee',
                      onSelected: (_) => setLocal(() => role = 'employee'),
                      selectedColor: HrColors.forest,
                      labelStyle: TextStyle(color: role == 'employee' ? HrColors.cream : HrColors.ink),
                      showCheckmark: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('shopAdmin'.tr()),
                      selected: role == 'shop_admin',
                      onSelected: (_) => setLocal(() => role = 'shop_admin'),
                      selectedColor: HrColors.forest,
                      labelStyle: TextStyle(color: role == 'shop_admin' ? HrColors.cream : HrColors.ink),
                      showCheckmark: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text('save'.tr())),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(stockActionsProvider).createUser(
            username: username.text.trim(),
            email: email.text.trim(),
            password: password.text,
            role: role,
          );
      ref.invalidate(staffProvider);
      if (context.mounted) showHrToast(context, title: 'success'.tr(), success: true);
    } catch (e) {
      if (context.mounted) showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
    }
  }
}
