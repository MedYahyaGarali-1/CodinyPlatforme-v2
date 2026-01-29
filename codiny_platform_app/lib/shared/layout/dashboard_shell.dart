import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session/session_controller.dart';
import '../../state/theme/theme_controller.dart';

class DashboardShell extends StatefulWidget {
  final List<DashboardTab> tabs;
  final int initialIndex;
  final bool showLogout;
  final bool showThemeToggle;

  const DashboardShell({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.showLogout = false,
    this.showThemeToggle = false,
  });

  @override
  State<DashboardShell> createState() => DashboardShellState();
  
  // Static method to access the state from anywhere in the widget tree
  static DashboardShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<DashboardShellState>();
  }
}

class DashboardShellState extends State<DashboardShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  
  // Public method to change tab from outside
  void changeTab(int index) {
    if (index >= 0 && index < widget.tabs.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tabs[_currentIndex];
    final session = context.watch<SessionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1D1E33) : Colors.white,
        elevation: 0,
        title: Text(
          tab.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1E33),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (widget.showThemeToggle)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: 'Toggle theme',
                icon: Icon(
                  context.watch<ThemeController>().isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1D1E33),
                ),
                onPressed: () {
                  context.read<ThemeController>().toggle();
                },
              ),
            ),
          if (widget.showLogout)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: 'Logout',
                icon: Icon(
                  Icons.logout_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1D1E33),
                ),
                onPressed: () async {
                  await session.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ),
        ],
      ),
      body: tab.body,
      bottomNavigationBar: widget.tabs.length <= 1
          ? null
          : Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D1E33) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(widget.tabs.length, (index) {
                      final isSelected = _currentIndex == index;
                      final tabItem = widget.tabs[index];
                      return _buildNavItem(
                        icon: tabItem.icon,
                        label: tabItem.label,
                        isSelected: isSelected,
                        isDark: isDark,
                        onTap: () => setState(() => _currentIndex = index),
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF6C63FF) : const Color(0xFF3B82F6))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icon : _getOutlinedIcon(icon),
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.grey),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getOutlinedIcon(IconData icon) {
    // Map filled icons to their outlined versions
    final iconMap = {
      Icons.home: Icons.home_outlined,
      Icons.home_rounded: Icons.home_outlined,
      Icons.calendar_month: Icons.calendar_month_outlined,
      Icons.calendar_today: Icons.calendar_today_outlined,
      Icons.menu_book: Icons.menu_book_outlined,
      Icons.book: Icons.book_outlined,
      Icons.assignment: Icons.assignment_outlined,
      Icons.quiz: Icons.quiz_outlined,
      Icons.school: Icons.school_outlined,
      Icons.person: Icons.person_outlined,
      Icons.settings: Icons.settings_outlined,
    };
    return iconMap[icon] ?? icon;
  }
}

class DashboardTab {
  final String label;
  final IconData icon;
  final Widget body;

  const DashboardTab({
    required this.label,
    required this.icon,
    required this.body,
  });
}



