import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatters.dart';
import '../../core/json_num.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../catalog/catalog_api.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.onGoWithdraw});
  final VoidCallback? onGoWithdraw;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _type; // null = all
  DateTime? _from;
  DateTime? _to;

  String _chipLabel(String? t) {
    if (t == null) return 'all'.tr();
    return txTypeKey(t).tr();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  HistoryQuery get _query {
    final fromIso = _from == null
        ? null
        : DateTime(_from!.year, _from!.month, _from!.day).toUtc().toIso8601String();
    final toIso = _to == null
        ? null
        : DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59, 999).toUtc().toIso8601String();
    return (from: fromIso, to: toIso);
  }

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _from ?? _to ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: _to ?? now,
      helpText: 'pickFromDate'.tr(),
    );
    if (picked == null) return;
    setState(() {
      _from = DateTime(picked.year, picked.month, picked.day);
      if (_to != null && _to!.isBefore(_from!)) _to = _from;
    });
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _to ?? _from ?? now,
      firstDate: _from ?? DateTime(now.year - 2),
      lastDate: now,
      helpText: 'pickToDate'.tr(),
    );
    if (picked == null) return;
    setState(() {
      _to = DateTime(picked.year, picked.month, picked.day);
      if (_from != null && _from!.isAfter(_to!)) _from = _to;
    });
  }

  void _clearFilters() {
    setState(() {
      _from = null;
      _to = null;
      _type = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider(_query));
    final hasDates = _from != null || _to != null;
    final hasFilters = hasDates || _type != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: HrLayout.pageHeaderPadding,
          child: Text('history'.tr(), style: Theme.of(context).textTheme.headlineLarge),
        ),
        Padding(
          padding: HrLayout.chipRowPadding,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFrom,
                  icon: const Icon(Icons.event, size: 18),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  label: Text(
                    _from == null ? 'from'.tr() : _fmt(_from!),
                    style: TextStyle(
                      fontSize: 14,
                      color: _from == null ? HrColors.muted : HrColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTo,
                  icon: const Icon(Icons.event_available, size: 18),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  label: Text(
                    _to == null ? 'to'.tr() : _fmt(_to!),
                    style: TextStyle(
                      fontSize: 14,
                      color: _to == null ? HrColors.muted : HrColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (hasDates) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'clearDates'.tr(),
                  onPressed: () => setState(() {
                    _from = null;
                    _to = null;
                  }),
                  icon: const Icon(Icons.clear),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: HrLayout.chipRowPadding,
          child: Row(
            children: [
              for (final t in [null, 'add', 'withdraw', 'adjust'])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(_chipLabel(t)),
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                    selectedColor: HrColors.forest,
                    labelStyle: TextStyle(
                      color: _type == t ? HrColors.cream : HrColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: HrColors.paper,
                    side: BorderSide(color: _type == t ? HrColors.forest : HrColors.line),
                    showCheckmark: false,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(historyProvider(_query)),
            child: history.when(
              skipLoadingOnReload: true,
              loading: () => const HrListSkeleton(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (rows) {
                var filtered = rows;
                if (_type != null) {
                  filtered = filtered.where((t) => t['type']?.toString() == _type).toList();
                }

                if (filtered.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          hasFilters ? 'historyNoMatches'.tr() : 'historyEmpty'.tr(),
                          style: const TextStyle(fontSize: 17, color: HrColors.muted),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (hasFilters)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            child: Text('clearFilters'.tr()),
                          ),
                        )
                      else if (widget.onGoWithdraw != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: FilledButton(
                            onPressed: widget.onGoWithdraw,
                            child: Text('goToWithdraw'.tr()),
                          ),
                        ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final t = filtered[i];
                    final typeKey = txTypeKey(t['type']?.toString());
                    final typeLabel = typeKey.startsWith('tx') ? typeKey.tr() : typeKey;
                    final unit = t['unit']?.toString() ?? '';
                    final qty = asDouble(t['quantity']);
                    final before = asDouble(t['stockBefore']);
                    final after = asDouble(t['stockAfter']);
                    return Card(
                      margin: HrLayout.cardMargin,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t['productName']?.toString() ?? '—',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$typeLabel · ${formatQtyUnit(qty, unit)}',
                              style: const TextStyle(fontSize: 15, color: HrColors.muted),
                            ),
                            Text(
                              '${'stockBefore'.tr()}: ${formatQtyUnit(before, unit)} → ${'stockAfter'.tr()}: ${formatQtyUnit(after, unit)}',
                              style: const TextStyle(fontSize: 14, color: HrColors.muted),
                            ),
                            Text(
                              '${t['userName']} · ${formatRelativeAbsolute(t['createdAt']?.toString())}',
                              style: const TextStyle(fontSize: 13, color: HrColors.muted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
