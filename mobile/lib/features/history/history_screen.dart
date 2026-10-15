import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../catalog/catalog_api.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.onGoWithdraw});
  final VoidCallback? onGoWithdraw;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _type; // null = all
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('history'.tr(), style: Theme.of(context).textTheme.headlineLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 2),
                      lastDate: now,
                      initialDateRange: _range,
                    );
                    if (picked != null) setState(() => _range = picked);
                  },
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text(
                    _range == null
                        ? '${'from'.tr()} / ${'to'.tr()}'
                        : '${_fmt(_range!.start)} → ${_fmt(_range!.end)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              if (_range != null)
                IconButton(
                  onPressed: () => setState(() => _range = null),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final t in [null, 'add', 'withdraw', 'adjust'])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(t ?? 'all'.tr()),
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
            onRefresh: () async => ref.invalidate(historyProvider),
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator(color: HrColors.forest)),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (rows) {
                var filtered = rows;
                if (_type != null) {
                  filtered = filtered.where((t) => t['type']?.toString() == _type).toList();
                }
                if (_range != null) {
                  filtered = filtered.where((t) {
                    final raw = t['createdAt']?.toString();
                    if (raw == null) return false;
                    final dt = DateTime.tryParse(raw);
                    if (dt == null) return false;
                    final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
                    final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59);
                    return !dt.isBefore(start) && !dt.isAfter(end);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(child: Text('historyEmpty'.tr(), style: const TextStyle(fontSize: 17, color: HrColors.muted))),
                      const SizedBox(height: 16),
                      if (widget.onGoWithdraw != null)
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
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                              '${t['type']} · ${t['quantity']}',
                              style: const TextStyle(fontSize: 15, color: HrColors.muted),
                            ),
                            Text(
                              '${'stockBefore'.tr()}: ${t['stockBefore']} → ${'stockAfter'.tr()}: ${t['stockAfter']}',
                              style: const TextStyle(fontSize: 14, color: HrColors.muted),
                            ),
                            Text(
                              '${t['userName']} · ${t['createdAt']}',
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

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
