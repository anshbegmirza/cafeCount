import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatters.dart';
import '../../core/json_num.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';
import '../catalog/catalog_api.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    this.onNeedsAttention,
    this.onOpenWithdraw,
    this.onOpenProducts,
    this.onOpenLowStock,
    this.onOpenOutOfStock,
  });

  final VoidCallback? onNeedsAttention;
  final VoidCallback? onOpenWithdraw;
  final VoidCallback? onOpenProducts;
  final VoidCallback? onOpenLowStock;
  final VoidCallback? onOpenOutOfStock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardProvider),
      child: dash.when(
        loading: () => HrHomeSkeleton(isAdmin: isAdmin),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          final totals = data['totals'] as Map<String, dynamic>;
          final low = (data['lowStock'] as List).cast<Map<String, dynamic>>();
          final recent = (data['recent'] as List).cast<Map<String, dynamic>>();
          final recentTop = recent.take(5).toList();
          final attention = asInt(totals['lowStock']) + asInt(totals['outOfStock']);

          return ListView(
            padding: HrLayout.pagePadding,
            children: [
              Text('dashboard'.tr(), style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              if (!isAdmin) ...[
                FilledButton.icon(
                  onPressed: onOpenWithdraw,
                  icon: const Icon(Icons.south_west),
                  label: Text('withdrawStock'.tr()),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'products'.tr(),
                      value: '${totals['products']}',
                      onTap: onOpenProducts,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'lowStock'.tr(),
                      value: '${totals['lowStock']}',
                      tone: _Tone.warn,
                      onTap: onOpenLowStock,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'outOfStock'.tr(),
                      value: '${totals['outOfStock']}',
                      tone: _Tone.danger,
                      onTap: onOpenOutOfStock,
                    ),
                  ),
                ],
              ),
              if (attention > 0) ...[
                const SizedBox(height: 16),
                Card(
                  color: HrColors.cream,
                  child: ListTile(
                    leading: const Icon(Icons.priority_high, color: HrColors.low),
                    title: Text(
                      'needsAttention'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    subtitle: Text('$attention'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: onNeedsAttention,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('lowStock'.tr(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (low.isEmpty)
                Text('noData'.tr(), style: const TextStyle(color: HrColors.muted))
              else
                ...low.map((p) {
                  final status = p['stockStatus']?.toString() ?? 'low';
                  final qty = asDouble(p['currentQty']);
                  final unit = p['unit']?.toString() ?? '';
                  return HrProductCard(
                    name: p['name']?.toString() ?? '',
                    subtitle: formatQtyUnit(qty, unit),
                    status: status,
                    onTap: onNeedsAttention,
                  );
                }),
              const SizedBox(height: 24),
              Text('recent'.tr(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (recentTop.isEmpty)
                Text('noData'.tr(), style: const TextStyle(color: HrColors.muted))
              else
                ...recentTop.map((t) {
                  final typeKey = txTypeKey(t['type']?.toString());
                  final typeLabel = typeKey.startsWith('tx') ? typeKey.tr() : typeKey;
                  final qty = asDouble(t['quantity']);
                  final unit = t['unit']?.toString() ?? '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        '${t['productName']}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      subtitle: Text(
                        '$typeLabel · ${t['userName']}\n${formatRelativeAbsolute(t['createdAt']?.toString())}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        formatQtyUnit(qty, unit),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

enum _Tone { normal, warn, danger }

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.tone = _Tone.normal,
    this.onTap,
  });
  final String label;
  final String value;
  final _Tone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _Tone.danger => HrColors.out,
      _Tone.warn => HrColors.low,
      _Tone.normal => HrColors.forest,
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
