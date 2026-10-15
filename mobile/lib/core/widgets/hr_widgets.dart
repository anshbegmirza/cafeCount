import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Small serif "Hidden Room" wordmark for the app bar.
class HrWordmark extends StatelessWidget {
  const HrWordmark({super.key, this.compact = true});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'appName'.tr(),
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: compact ? 16 : 22,
        fontWeight: FontWeight.w600,
        color: HrColors.ink,
        height: 1.1,
        letterSpacing: 0.2,
      ),
    );
  }
}

class HrStatusChip extends StatelessWidget {
  const HrStatusChip(this.status, {super.key});
  final String status; // ok | low | out

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    switch (status) {
      case 'out':
        bg = HrColors.out.withValues(alpha: 0.15);
        fg = HrColors.out;
        label = 'outOfStock'.tr();
      case 'low':
        bg = HrColors.low.withValues(alpha: 0.18);
        fg = HrColors.low;
        label = 'lowStock'.tr();
      default:
        bg = HrColors.ok.withValues(alpha: 0.15);
        fg = HrColors.ok;
        label = 'ok'.tr();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class HrFilterChip extends StatelessWidget {
  const HrFilterChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: HrColors.forest,
        labelStyle: TextStyle(
          color: selected ? HrColors.cream : HrColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        side: BorderSide(color: selected ? HrColors.forest : HrColors.line),
        backgroundColor: HrColors.paper,
        showCheckmark: false,
      ),
    );
  }
}

Future<T?> showHrBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: HrColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: builder(ctx),
    ),
  );
}

class HrSheetScaffold extends StatelessWidget {
  const HrSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.showClose = true,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
                if (showClose)
                  IconButton(
                    onPressed: onClose ?? () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: HrColors.line),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.close, size: 20),
                  ),
              ],
            ),
          ),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: child)),
        ],
      ),
    );
  }
}

void showHrToast(BuildContext context, {required String title, String? detail, required bool success}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      content: _HrToastCard(title: title, detail: detail, success: success),
    ),
  );
}

class _HrToastCard extends StatelessWidget {
  const _HrToastCard({required this.title, this.detail, required this.success});
  final String title;
  final String? detail;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final edge = success ? HrColors.ok : HrColors.out;
    return Material(
      color: HrColors.paper,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: edge, width: 6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: edge,
              child: Icon(success ? Icons.check : Icons.close, color: HrColors.cream, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: HrColors.ink)),
                  if (detail != null && detail!.isNotEmpty)
                    Text(detail!, style: const TextStyle(fontSize: 14, color: HrColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HrQtyStepper extends StatelessWidget {
  const HrQtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.unit = '',
    this.min = 0,
    this.step = 1,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String unit;
  final double min;
  final double step;

  @override
  Widget build(BuildContext context) {
    final label = value == value.roundToDouble() ? value.toInt().toString() : value.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roundBtn(Icons.remove, () {
          final next = value - step;
          if (next >= min) onChanged(next);
        }, filled: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            unit.isEmpty ? label : '$label $unit',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: HrColors.ink),
          ),
        ),
        _roundBtn(Icons.add, () => onChanged(value + step), filled: true),
      ],
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap, {required bool filled}) {
    return Material(
      color: filled ? HrColors.forest : HrColors.paper,
      shape: const CircleBorder(side: BorderSide(color: HrColors.forest)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: filled ? HrColors.cream : HrColors.forest),
        ),
      ),
    );
  }
}

class HrProductCard extends StatelessWidget {
  const HrProductCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.status,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: HrColors.ink)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 15, color: HrColors.muted)),
                  ],
                ),
              ),
              trailing ?? HrStatusChip(status),
            ],
          ),
        ),
      ),
    );
  }
}
