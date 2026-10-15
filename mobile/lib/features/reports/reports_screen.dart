import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _busy = false;
  String _period = 'week';

  Future<void> _download(String path, String filename, {required bool pdf}) async {
    setState(() => _busy = true);
    try {
      final api = ref.read(apiClientProvider);
      final bytes = await api.getBytes(path);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      if (mounted) {
        showHrToast(
          context,
          title: pdf ? 'pdfReady'.tr() : 'excelReady'.tr(),
          detail: 'fileSaved'.tr(),
          success: true,
        );
      }
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        showHrToast(context, title: 'errorGeneric'.tr(), detail: e.toString(), success: false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                onTap: () => setState(() => _period = e.$1),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (_busy) const Padding(padding: EdgeInsets.only(bottom: 16), child: Center(child: CircularProgressIndicator(color: HrColors.forest))),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: HrColors.forest,
              child: const Text('PDF', style: TextStyle(color: HrColors.cream, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            title: Text('exportPdf'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            subtitle: Text('exportPdfHint'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: _busy ? null : () => _download('/reports/inventory.pdf', 'hidden-room-inventory.pdf', pdf: true),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: HrColors.forestLift,
              child: const Text('XLS', style: TextStyle(color: HrColors.cream, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            title: Text('exportExcel'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            subtitle: Text('exportExcelHint'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: _busy ? null : () => _download('/reports/inventory.xlsx', 'hidden-room-inventory.xlsx', pdf: false),
          ),
        ),
        const SizedBox(height: 20),
        Text('adminsOnlyExport'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: HrColors.muted)),
      ],
    );
  }
}
