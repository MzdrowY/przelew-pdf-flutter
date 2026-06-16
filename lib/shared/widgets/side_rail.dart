import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
    return Container(
      width: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        border: Border(right: BorderSide(color: AppColors.border, width: .5)),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C75FF), Color(0xFF5A54CC)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance, size: 20, color: Colors.white),
            ),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 12, endIndent: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: items.asMap().entries.map((e) => _item(e.key, e.value)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, NavItem item) {
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
            color: selected ? AppColors.primary.withValues(alpha: .15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              selected ? (item.activeIcon ?? item.icon) : item.icon,
              size: selected ? 22 : 20,
              color: selected ? AppColors.primarySoft : AppColors.textTertiary,
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
