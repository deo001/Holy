import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/bible/presentation/bible_screen.dart';
import 'features/rosary/presentation/rosary_screen.dart';
import 'features/journal/presentation/journal_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/onboarding/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service on boot
  final notificationService = NotificationService.instance;
  await notificationService.init();

  runApp(
    const ProviderScope(
      child: LetsPrayApp(),
    ),
  );
}

class LetsPrayApp extends StatelessWidget {
  const LetsPrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let's Pray",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onNavigate: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const BibleScreen(),
      const RosaryScreen(),
      const JournalScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppStrings.of(ref, 'tab_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: AppStrings.of(ref, 'tab_bible'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.circle_outlined),
            activeIcon: const Icon(Icons.circle),
            label: AppStrings.of(ref, 'tab_rosary'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: AppStrings.of(ref, 'tab_journal'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_outlined),
            activeIcon: const Icon(Icons.account_circle),
            label: AppStrings.of(ref, 'tab_space'),
          ),
        ],
      ),
    );
  }
}
