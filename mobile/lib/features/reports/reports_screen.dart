import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';

enum _ExportKind { pdf, excel }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _ExportKind? _busy;
  String _period = 'week';

  Future<void> _download(_ExportKind kind, String path, String filename) async {
    if (_busy != null) return;
    setState(() => _busy = kind);

    // Full-screen blocker so the wait is obvious while the blob builds.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: HrColors.paper,
            borderRadius: BorderRadius.circular(16),
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
        Navigator.of(context, rootNavigator: true).pop(); // close loader
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
    final anyBusy = _busy != null;

    return ListView(
      padding: HrLayout.pagePadding,
      children: [
        Text('reports'.tr(), style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text('reportsSubtitle'.tr(), style: const TextStyle(color: HrColors.muted, fontSize: 16)),
        const SizedBox(height: 20),
        Text('period'.tr(), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final e in [('today', 'today'), ('week', 'thisWeek'), ('month', 'thisMonth')])
              HrFilterChip(
                label: e.$2.tr(),
                selected: _period == e.$1,
                onTap: anyBusy ? () {} : () => setState(() => _period = e.$1),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: const CircleAvatar(
              backgroundColor: HrColors.forest,
              child: Text('PDF', style: TextStyle(color: HrColors.cream, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            title: Text('exportPdf'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            subtitle: Text('exportPdfHint'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: anyBusy
                ? null
                : () => _download(_ExportKind.pdf, '/reports/inventory.pdf', 'hidden-room-inventory.pdf'),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: const CircleAvatar(
              backgroundColor: HrColors.forestLift,
              child: Text('XLS', style: TextStyle(color: HrColors.cream, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            title: Text('exportExcel'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            subtitle: Text('exportExcelHint'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: anyBusy
                ? null
                : () => _download(_ExportKind.excel, '/reports/inventory.xlsx', 'hidden-room-inventory.xlsx'),
          ),
        ),
        const SizedBox(height: 20),
        Text('adminsOnlyExport'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: HrColors.muted)),
      ],
    );
  }
}
