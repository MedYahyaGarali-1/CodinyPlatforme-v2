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

    return Scaffold(
      appBar: AppBar(
        title: Text(tab.label),
        actions: [
          if (widget.showThemeToggle)
            IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(
                context.watch<ThemeController>().isDark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<ThemeController>().toggle();
              },
            ),
          if (widget.showLogout)
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await session.logout();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: tab.body,
      ),
      bottomNavigationBar: widget.tabs.length <= 1
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: widget.tabs
                  .map((t) => BottomNavigationBarItem(
                        icon: Icon(t.icon),
                        label: t.label,
                      ))
                  .toList(),
            ),
    );
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



