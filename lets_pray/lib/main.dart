import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/bible/presentation/bible_screen.dart';
import 'features/rosary/presentation/rosary_screen.dart';
import 'features/journal/presentation/journal_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service on boot
  final notificationService = NotificationService.instance;
  await notificationService.init();
  await notificationService.requestPermissions();

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
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Bible',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_outlined),
            activeIcon: Icon(Icons.circle),
            label: 'Rosary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Space',
          ),
        ],
      ),
    );
  }
}
