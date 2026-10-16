import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout.dart';
import '../../core/password_policy.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  String _roleLabel(String? role) {
    switch (role) {
      case 'employee':
        return 'roleEmployee'.tr();
      case 'shop_admin':
        return 'roleShopAdmin'.tr();
      case 'super_admin':
        return 'roleSuperAdmin'.tr();
      default:
        return role ?? '';
    }
  }

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
            padding: HrLayout.pageHeaderPadding,
            child: Text('staff'.tr(), style: Theme.of(context).textTheme.headlineLarge),
          ),
          Expanded(
            child: staff.when(
              loading: () => const HrListSkeleton(count: 4),
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
                      final email = u['email']?.toString() ?? '';
                      final role = u['role']?.toString();
                      return Card(
                        margin: HrLayout.cardMargin,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u['username']?.toString() ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: HrColors.muted),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: HrColors.cream,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: HrColors.line),
                                          ),
                                          child: Text(
                                            _roleLabel(role),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: HrColors.forest,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          active ? 'active'.tr() : 'inactive'.tr(),
                                          style: TextStyle(
                                            color: active ? HrColors.ok : HrColors.muted,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: HrColors.forest),
              title: Text('editStaff'.tr()),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: HrColors.forest),
              title: Text('changePassword'.tr()),
              onTap: () => Navigator.pop(ctx, 'password'),
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
    if (action == 'password' && context.mounted) await _changePassword(context, ref, u);
    if (action == 'deactivate' && context.mounted) await _deactivate(context, ref, u);
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref, Map<String, dynamic> u) async {
    final password = TextEditingController();
    final repeat = TextEditingController();
    final ok = await showHrBottomSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final p = password.text;
          final canSave = isValidAdminPassword(p) && p == repeat.text;
          return HrSheetScaffold(
            title: 'changePassword'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  u['username']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  'passwordPolicyHint'.tr(),
                  style: const TextStyle(fontSize: 13, color: HrColors.muted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'newPassword'.tr()),
                  onChanged: (_) => setLocal(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: repeat,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'repeatNewPassword'.tr()),
                  onChanged: (_) => setLocal(() {}),
                ),
                if (repeat.text.isNotEmpty && p != repeat.text) ...[
                  const SizedBox(height: 12),
                  Text('passwordMismatch'.tr(), style: const TextStyle(color: HrColors.out, fontSize: 14)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: canSave ? () => Navigator.pop(ctx, true) : null,
                  child: Text('save'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(stockActionsProvider).setUserPassword(u['id'] as int, password.text);
      if (context.mounted) showHrToast(context, title: 'passwordUpdated'.tr(), success: true);
    } catch (e) {
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }

  Future<void> _editStaff(BuildContext context, WidgetRef ref, Map<String, dynamic> u) async {
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
              controller: TextEditingController(text: _roleLabel(u['role']?.toString())),
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
            Text(
              u['username']?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
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
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
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
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: 'password'.tr()),
              ),
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
    if (!isValidAdminPassword(password.text)) {
      if (context.mounted) {
        showHrToast(context, title: 'passwordPolicyHint'.tr(), success: false);
      }
      return;
    }
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
      if (context.mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    }
  }
}
