import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../history/history_screen.dart';
import '../products/products_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../staff/staff_screen.dart';
import '../stock/withdraw_screen.dart';
import '../units/units_screen.dart';

enum ShellDest { home, products, settings, withdraw, history, staff, reports, units }

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  ShellDest _dest = ShellDest.home;
  String? _productFilter; // null | low | out

  int? get _tabIndex {
    switch (_dest) {
      case ShellDest.home:
        return 0;
      case ShellDest.products:
        return 1;
      case ShellDest.settings:
        return 2;
      default:
        return null;
    }
  }

  void _go(ShellDest d, {String? productFilter}) {
    setState(() {
      _dest = d;
      if (d == ShellDest.products) {
        _productFilter = productFilter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            tooltip: 'menu'.tr(),
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const HrWordmark(),
      ),
      drawer: _HrDrawer(
        isAdmin: isAdmin,
        current: _dest,
        onSelect: (d) {
          Navigator.pop(context);
          _go(d);
        },
      ),
      body: _body(isAdmin),
      bottomNavigationBar: _HrBottomNav(
        selectedIndex: _tabIndex,
        onSelect: (i) {
          _go([ShellDest.home, ShellDest.products, ShellDest.settings][i]);
        },
      ),
    );
  }

  Widget _body(bool isAdmin) {
    switch (_dest) {
      case ShellDest.home:
        return DashboardScreen(
          onNeedsAttention: () => _go(ShellDest.products, productFilter: 'low'),
          onOpenWithdraw: () => _go(ShellDest.withdraw),
          onOpenProducts: () => _go(ShellDest.products),
          onOpenLowStock: () => _go(ShellDest.products, productFilter: 'low'),
          onOpenOutOfStock: () => _go(ShellDest.products, productFilter: 'out'),
        );
      case ShellDest.products:
        return ProductsScreen(
          key: ValueKey(_productFilter),
          initialStatusFilter: _productFilter,
        );
      case ShellDest.settings:
        return const SettingsScreen();
      case ShellDest.withdraw:
        return const WithdrawScreen();
      case ShellDest.history:
        return HistoryScreen(onGoWithdraw: () => _go(ShellDest.withdraw));
      case ShellDest.staff:
        return isAdmin ? const StaffScreen() : const SizedBox.shrink();
      case ShellDest.reports:
        return isAdmin ? const ReportsScreen() : const SizedBox.shrink();
      case ShellDest.units:
        return isAdmin ? const UnitsScreen() : const SizedBox.shrink();
    }
  }
}

class _HrBottomNav extends StatelessWidget {
  const _HrBottomNav({required this.selectedIndex, required this.onSelect});
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home, 'home'.tr()),
      (Icons.view_list_outlined, Icons.view_list, 'products'.tr()),
      (Icons.settings_outlined, Icons.settings, 'settings'.tr()),
    ];
    return Material(
      color: HrColors.paper,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelect(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: selectedIndex == i ? HrColors.cream : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selectedIndex == i ? items[i].$2 : items[i].$1,
                            color: selectedIndex == i ? HrColors.forest : HrColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selectedIndex == i ? FontWeight.w700 : FontWeight.w500,
                            color: selectedIndex == i ? HrColors.forest : HrColors.muted,
                          ),
                          child: Text(items[i].$3),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HrDrawer extends StatelessWidget {
  const _HrDrawer({required this.isAdmin, required this.current, required this.onSelect});
  final bool isAdmin;
  final ShellDest current;
  final ValueChanged<ShellDest> onSelect;

  @override
  Widget build(BuildContext context) {
    final entries = <(ShellDest, IconData, String)>[
      (ShellDest.withdraw, Icons.south_west, 'withdrawStock'.tr()),
      (ShellDest.products, Icons.view_list, 'products'.tr()),
      (ShellDest.history, Icons.history, 'history'.tr()),
      if (isAdmin) (ShellDest.staff, Icons.group_outlined, 'staff'.tr()),
      if (isAdmin) (ShellDest.units, Icons.straighten, 'units'.tr()),
      if (isAdmin) (ShellDest.reports, Icons.bar_chart, 'reports'.tr()),
    ];

    return Drawer(
      backgroundColor: HrColors.paper,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: HrColors.forest),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png', width: 56, height: 56, fit: BoxFit.cover),
                  const SizedBox(height: 12),
                  Text(
                    'appName'.tr(),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: HrColors.cream,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            for (final e in entries)
              ListTile(
                leading: Icon(e.$2, color: current == e.$1 ? HrColors.forest : HrColors.muted),
                title: Text(
                  e.$3,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: current == e.$1 ? FontWeight.w700 : FontWeight.w500,
                    color: HrColors.ink,
                  ),
                ),
                selected: current == e.$1,
                selectedTileColor: HrColors.cream,
                onTap: () => onSelect(e.$1),
              ),
          ],
        ),
      ),
    );
  }
}
