import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../layout.dart';
import '../theme.dart';

/// App-bar / about mark — always the full app name.
class HrWordmark extends StatelessWidget {
  const HrWordmark({super.key, this.compact = true});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'appName'.tr(),
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: compact ? 18 : 22,
        fontWeight: FontWeight.w700,
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
        bg = HrColors.out.withValues(alpha: 0.18);
        fg = const Color(0xFF8B3A2E); // darker than out for contrast
        label = 'outOfStock'.tr();
      case 'low':
        bg = HrColors.low.withValues(alpha: 0.22);
        fg = const Color(0xFF6B5410); // darker than low for contrast
        label = 'lowStock'.tr();
      default:
        bg = HrColors.ok.withValues(alpha: 0.18);
        fg = const Color(0xFF1F4A36);
        label = 'ok'.tr();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: HrLayout.borderLg),
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
  // Ignored — always scroll-controlled so Cancel is not clipped at half-screen.
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: HrColors.paper,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      reverseDuration: Duration(milliseconds: 220),
      reverseCurve: Curves.easeInCubic,
    ),
    shape: RoundedRectangleBorder(borderRadius: HrLayout.borderSheet),
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      final keyboard = mq.viewInsets.bottom;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboard),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
          child: builder(ctx),
        ),
      );
    },
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
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: 12 + bottomSafe),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(2)),
            ),
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
          Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: child),
        ],
      ),
    );
  }
}

/// Root messenger on MaterialApp — toasts must use this (nested Scaffolds clip/hide them).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Floating toast just above the bottom nav (visible).
void showHrToast(BuildContext context, {required String title, String? detail, required bool success}) {
  final messenger = rootScaffoldMessengerKey.currentState ?? ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Sit above the 64px bottom nav + system inset — do NOT use full-screen margin.
      margin: EdgeInsets.fromLTRB(HrLayout.side, 0, HrLayout.side, 72 + bottomPad),
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.down,
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
    final edge = success ? const Color(0xFF5CBF8A) : const Color(0xFFE07A6A);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: Material(
        color: HrColors.forest,
        elevation: 8,
        shadowColor: Colors.black54,
        borderRadius: HrLayout.borderSm,
        child: Container(
          decoration: BoxDecoration(
            color: HrColors.forest,
            borderRadius: HrLayout.borderSm,
            border: Border(left: BorderSide(color: edge, width: 6)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: edge,
                child: Icon(success ? Icons.check : Icons.close, color: HrColors.forest, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: HrColors.cream),
                    ),
                    if (detail != null && detail!.isNotEmpty)
                      Text(
                        detail!,
                        style: TextStyle(fontSize: 14, color: HrColors.cream.withValues(alpha: 0.75)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _skelBox({double? width, double height = 14, double radius = 6}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(color: HrColors.line, borderRadius: BorderRadius.circular(radius)),
  );
}

/// Soft pulse list placeholders (no shimmer package).
class HrListSkeleton extends StatefulWidget {
  const HrListSkeleton({super.key, this.count = 6});
  final int count;

  @override
  State<HrListSkeleton> createState() => _HrListSkeletonState();
}

class _HrListSkeletonState extends State<HrListSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final opacity = 0.35 + (_c.value * 0.35);
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: widget.count,
          itemBuilder: (_, __) => Opacity(
            opacity: opacity,
            child: Card(
              margin: HrLayout.cardMargin,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skelBox(width: 160, height: 16),
                    const SizedBox(height: 10),
                    _skelBox(width: 220, height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Home loading shape: title, optional withdraw CTA, 3 stats, attention, low cards, recent.
class HrHomeSkeleton extends StatefulWidget {
  const HrHomeSkeleton({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<HrHomeSkeleton> createState() => _HrHomeSkeletonState();
}

class _HrHomeSkeletonState extends State<HrHomeSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final opacity = 0.35 + (_c.value * 0.35);
        return Opacity(
          opacity: opacity,
          child: ListView(
            padding: HrLayout.pagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _skelBox(width: 120, height: 28, radius: 8),
              const SizedBox(height: 16),
              if (!widget.isAdmin) ...[
                _skelBox(height: 52, radius: 14),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _skelBox(width: 56, height: 12),
                              const SizedBox(height: 12),
                              _skelBox(width: 36, height: 28, radius: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: HrColors.cream,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      _skelBox(width: 28, height: 28, radius: 14),
                      const SizedBox(width: 12),
                      Expanded(child: _skelBox(height: 16)),
                      const SizedBox(width: 12),
                      _skelBox(width: 20, height: 20, radius: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _skelBox(width: 64, height: 20, radius: 6),
              const SizedBox(height: 8),
              for (var i = 0; i < 3; i++)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _skelBox(width: 140, height: 16),
                              const SizedBox(height: 8),
                              _skelBox(width: 72, height: 12),
                            ],
                          ),
                        ),
                        _skelBox(width: 48, height: 24, radius: 12),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _skelBox(width: 140, height: 20, radius: 6),
              const SizedBox(height: 8),
              for (var i = 0; i < 2; i++)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _skelBox(width: 120, height: 15),
                              const SizedBox(height: 8),
                              _skelBox(width: 180, height: 12),
                              const SizedBox(height: 6),
                              _skelBox(width: 150, height: 11),
                            ],
                          ),
                        ),
                        _skelBox(width: 52, height: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class HrQtyStepper extends StatefulWidget {
  const HrQtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.unit = '',
    this.min = 0,
    this.max,
    this.step = 1,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String unit;
  final double min;
  final double? max;
  final double step;

  @override
  State<HrQtyStepper> createState() => _HrQtyStepperState();
}

class _HrQtyStepperState extends State<HrQtyStepper> {
  late final TextEditingController _ctrl;

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  double _clamp(double v) {
    var next = v;
    if (next < widget.min) next = widget.min;
    if (widget.max != null && next > widget.max!) next = widget.max!;
    return next;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(covariant HrQtyStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final t = _fmt(widget.value);
      if (_ctrl.text != t) _ctrl.text = t;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commitText() {
    final parsed = double.tryParse(_ctrl.text.trim().replaceAll(',', '.'));
    if (parsed == null) {
      _ctrl.text = _fmt(widget.value);
      return;
    }
    final next = _clamp(parsed);
    _ctrl.text = _fmt(next);
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final canDec = widget.value - widget.step >= widget.min - 1e-9;
    final canInc = widget.max == null || widget.value + widget.step <= widget.max! + 1e-9;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roundBtn(
              Icons.remove,
              canDec
                  ? () => widget.onChanged(_clamp(widget.value - widget.step))
                  : null,
              filled: false,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 120,
                child: TextField(
                  controller: _ctrl,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: HrColors.ink),
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: widget.unit.isEmpty ? null : widget.unit,
                    border: const UnderlineInputBorder(),
                  ),
                  onSubmitted: (_) => _commitText(),
                  onEditingComplete: _commitText,
                ),
              ),
            ),
            _roundBtn(
              Icons.add,
              canInc
                  ? () => widget.onChanged(_clamp(widget.value + widget.step))
                  : null,
              filled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback? onTap, {required bool filled}) {
    final enabled = onTap != null;
    return Material(
      color: filled
          ? (enabled ? HrColors.forest : HrColors.forest.withValues(alpha: 0.35))
          : HrColors.paper,
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
      margin: HrLayout.cardMargin,
      child: InkWell(
        borderRadius: HrLayout.borderMd,
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
