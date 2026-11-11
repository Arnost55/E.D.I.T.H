import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/dashboard_page.dart';
import '../assistant/assistant_page.dart';
import '../vision/vision_page.dart';
import '../protection/protection_page.dart';
import '../settings/settings_page.dart';
import '../../core/theme/edith_theme.dart';

/// Main E.D.I.T.H. App widget with Riverpod and go_router
class EdithApp extends ConsumerWidget {
  const EdithApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _buildRouter(ref);

    return MaterialApp.router(
      title: 'E.D.I.T.H.',
      debugShowCheckedModeBanner: false,
      theme: createEdithThemeData(),
      routerConfig: router,
    );
  }

  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const EdithHomePage(),
        ),
        GoRoute(
          path: '/assistant',
          builder: (context, state) => const AssistantPage(),
        ),
        GoRoute(
          path: '/vision',
          builder: (context, state) => const VisionPage(),
        ),
        GoRoute(
          path: '/protection',
          builder: (context, state) => const ProtectionPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }
}

/// Home page with bottom navigation
class EdithHomePage extends ConsumerStatefulWidget {
  const EdithHomePage({super.key});

  @override
  ConsumerState<EdithHomePage> createState() => _EdithHomePageState();
}

class _EdithHomePageState extends ConsumerState<EdithHomePage> {
  int _selectedIndex = 0;

  static const List<String> _routes = [
    '/dashboard',
    '/assistant',
    '/vision',
    '/protection',
    '/settings',
  ];

  static const List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.auto_awesome_outlined,
    Icons.visibility_outlined,
    Icons.shield_outlined,
    Icons.settings_outlined,
  ];

  static const List<String> _labels = [
    'Dashboard',
    'Assistant',
    'Vision',
    'Protection',
    'Settings',
  ];

  void _onDestinationSelected(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            DashboardPage(),
            AssistantPage(),
            VisionPage(),
            ProtectionPage(),
            SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: EdithColors.panel,
        indicatorColor: EdithColors.accent.withValues(alpha: 0.15),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(_labels.length, (index) {
          final isSelected = index == _selectedIndex;
          return NavigationDestination(
            icon: Icon(
              _icons[index],
              color: isSelected ? EdithColors.accentStrong : EdithColors.textMuted,
            ),
            selectedIcon: Icon(
              _icons[index],
              color: EdithColors.accentStrong,
            ),
            label: _labels[index],
            tooltip: _labels[index],
          );
        }),
      ),
    );
  }
}