import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/config.dart';
import '../../core/formatters.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';
import '../catalog/catalog_api.dart';

enum _ExportKind { pdf, excel }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _ExportKind? _busy;

  String get _fileSlug {
    final raw = AppConfig.appName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final slug = raw.replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'stock-room' : slug;
  }

  Future<void> _download(_ExportKind kind, String path, String filename) async {
    if (_busy != null) return;
    setState(() => _busy = kind);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: HrColors.paper,
            borderRadius: HrLayout.borderMd,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 3, color: HrColors.forest),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    kind == _ExportKind.pdf ? 'generatingPdf'.tr() : 'generatingExcel'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: HrColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'generatingHint'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: HrColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final api = ref.read(apiClientProvider);
      final bytes = await api.getBytes(path);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showHrToast(
          context,
          title: kind == _ExportKind.pdf ? 'pdfReady'.tr() : 'excelReady'.tr(),
          detail: 'fileSaved'.tr(),
          success: true,
        );
      }
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(null));
    final anyBusy = _busy != null;

    return productsAsync.when(
      loading: () => const HrListSkeleton(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (products) {
        final ok = products.where((p) => p.stockStatus == 'ok').length;
        final low = products.where((p) => p.stockStatus == 'low').length;
        final out = products.where((p) => p.stockStatus == 'out').length;

        final byCat = <String, int>{};
        for (final p in products) {
          final key = (p.categoryName == null || p.categoryName!.trim().isEmpty)
              ? 'uncategorized'.tr()
              : p.categoryName!;
          byCat[key] = (byCat[key] ?? 0) + 1;
        }
        final catEntries = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(productsProvider),
          child: ListView(
            padding: HrLayout.pagePadding,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('reports'.tr(), style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 6),
                        Text(
                          'reportsSubtitle'.tr(),
                          style: const TextStyle(color: HrColors.muted, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_ExportKind>(
                    enabled: !anyBusy,
                    tooltip: 'export'.tr(),
                    onSelected: (kind) {
                      if (kind == _ExportKind.pdf) {
                        _download(kind, '/reports/inventory.pdf', '$_fileSlug-inventory.pdf');
                      } else {
                        _download(kind, '/reports/inventory.xlsx', '$_fileSlug-inventory.xlsx');
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _ExportKind.pdf,
                        child: Text('exportPdf'.tr()),
                      ),
                      PopupMenuItem(
                        value: _ExportKind.excel,
                        child: Text('exportExcel'.tr()),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: HrColors.forest,
                        borderRadius: HrLayout.borderSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (anyBusy)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: HrColors.cream),
                            )
                          else
                            const Icon(Icons.download_outlined, size: 18, color: HrColors.cream),
                          const SizedBox(width: 8),
                          Text(
                            'export'.tr(),
                            style: const TextStyle(
                              color: HrColors.cream,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: HrColors.cream),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('stockByStatus'.tr(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  child: products.isEmpty
                      ? SizedBox(height: 160, child: Center(child: Text('noData'.tr())))
                      : Column(
                          children: [
                            SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 36,
                                  sections: [
                                    if (ok > 0)
                                      PieChartSectionData(
                                        value: ok.toDouble(),
                                        color: HrColors.ok,
                                        title: '$ok',
                                        radius: 48,
                                        titleStyle: const TextStyle(
                                          color: HrColors.cream,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (low > 0)
                                      PieChartSectionData(
                                        value: low.toDouble(),
                                        color: HrColors.low,
                                        title: '$low',
                                        radius: 48,
                                        titleStyle: const TextStyle(
                                          color: HrColors.ink,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (out > 0)
                                      PieChartSectionData(
                                        value: out.toDouble(),
                                        color: HrColors.out,
                                        title: '$out',
                                        radius: 48,
                                        titleStyle: const TextStyle(
                                          color: HrColors.cream,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                _LegendDot(color: HrColors.ok, label: '${'ok'.tr()} ($ok)'),
                                _LegendDot(color: HrColors.low, label: '${'lowStock'.tr()} ($low)'),
                                _LegendDot(color: HrColors.out, label: '${'outOfStock'.tr()} ($out)'),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text('productsByCategory'.tr(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  child: catEntries.isEmpty
                      ? SizedBox(height: 160, child: Center(child: Text('noData'.tr())))
                      : Column(
                          children: [
                            SizedBox(
                              height: 240,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8, top: 8),
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (catEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1)
                                        .toDouble(),
                                    groupsSpace: catEntries.length > 5 ? 10 : 16,
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (_) => HrColors.forest,
                                        getTooltipItem: (group, _, rod, __) {
                                          final label = catEntries[group.x.toInt()].key;
                                          return BarTooltipItem(
                                            '$label\n${rod.toY.toInt()}',
                                            const TextStyle(
                                              color: HrColors.cream,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          interval: 1,
                                          getTitlesWidget: (v, _) {
                                            if (v != v.roundToDouble()) return const SizedBox.shrink();
                                            return Text(
                                              v.toInt().toString(),
                                              style: const TextStyle(fontSize: 11, color: HrColors.muted),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 56,
                                          getTitlesWidget: (v, meta) {
                                            final i = v.toInt();
                                            if (i < 0 || i >= catEntries.length) {
                                              return const SizedBox.shrink();
                                            }
                                            final label = catEntries[i].key;
                                            final short =
                                                label.length > 10 ? '${label.substring(0, 9)}…' : label;
                                            return SideTitleWidget(
                                              meta: meta,
                                              space: 8,
                                              child: Transform.rotate(
                                                angle: catEntries.length > 3 ? -0.6 : 0,
                                                child: Text(
                                                  short,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: HrColors.muted,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 1,
                                      getDrawingHorizontalLine: (_) =>
                                          const FlLine(color: HrColors.line, strokeWidth: 1),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: [
                                      for (var i = 0; i < catEntries.length; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: catEntries[i].value.toDouble(),
                                              color: HrColors.forest,
                                              width: catEntries.length > 6 ? 12 : 18,
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text('inventoryTable'.tr(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: products.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text('noData'.tr())),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(HrColors.cream),
                          columns: [
                            DataColumn(label: Text('name'.tr(), style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('category'.tr(), style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('unit'.tr(), style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('stockQty'.tr(), style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('minStock'.tr(), style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('status'.tr(), style: const TextStyle(fontWeight: FontWeight.w700))),
                          ],
                          rows: [
                            for (final p in products)
                              DataRow(
                                cells: [
                                  DataCell(Text(p.name)),
                                  DataCell(Text(p.categoryName ?? '—')),
                                  DataCell(Text(p.unit)),
                                  DataCell(Text(formatQtyUnit(p.currentQty, p.unit))),
                                  DataCell(Text(formatQtyUnit(p.minStock, p.unit))),
                                  DataCell(HrStatusChip(p.stockStatus)),
                                ],
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: HrLayout.borderSm),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: HrColors.ink)),
      ],
    );
  }
}
