import 'package:flutter/material.dart';
import '../../core/theme/app_theme_colors.dart';

class SideRail extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final void Function(int index, String route)? onDestinationSelected;

  const SideRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border, width: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primaryGlow],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance, size: 20, color: Colors.white),
            ),
          ),
          Divider(height: 1, color: colors.border, indent: 12, endIndent: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: items.asMap().entries.map((e) => _item(e.key, e.value, colors)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, NavItem item, AppThemeColors colors) {
    final selected = index == selectedIndex;
    return Tooltip(
      message: item.label,
      preferBelow: false,
      child: GestureDetector(
        onTap: () => onDestinationSelected?.call(index, item.route),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? colors.primary.withValues(alpha: .15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              selected ? (item.activeIcon ?? item.icon) : item.icon,
              size: selected ? 22 : 20,
              color: selected ? colors.primarySoft : colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  const NavItem(this.icon, this.label, this.route, {this.activeIcon});
}
