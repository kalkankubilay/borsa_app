import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/portfolio_provider.dart';
import 'theme/spotify_theme.dart';
import 'screens/home_screen.dart';
import 'screens/portfolio_screen.dart';

import 'screens/ipo_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: SpotifyTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BorsaApp());
}

class BorsaApp extends StatelessWidget {
  const BorsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portföyüm',
      debugShowCheckedModeBanner: false,
      theme: SpotifyTheme.themeData,
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
  int _navIndex = 0;
  int _portfolioInitialTab = 0;
  final PortfolioProvider _provider = PortfolioProvider();

  @override
  void initState() {
    super.initState();
    _provider.addListener(() {
      setState(() {});
    });
  }

  void _navigateToPortfolioSegment(int targetTab) {
    setState(() {
      _portfolioInitialTab = targetTab;
      _navIndex = 1; // Portföy sekmesine geç
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpotifyTheme.background,
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            HomeScreen(
              provider: _provider,
              onNavigateToSegment: _navigateToPortfolioSegment,
            ),
            PortfolioScreen(
              key: ValueKey(_portfolioInitialTab),
              provider: _provider,
              initialTabIndex: _portfolioInitialTab,
            ),
            const IpoScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: SpotifyTheme.surface,
          border: Border(
            top: BorderSide(color: SpotifyTheme.border, width: 0.8),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
          height: 65,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: SpotifyTheme.green.withOpacity(0.2),
          onDestinationSelected: (idx) {
            setState(() {
              if (idx == 1) {
                _portfolioInitialTab = 0; // Doğrudan menüden tıklanırsa 'Tümü' ile aç
              }
              _navIndex = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: SpotifyTheme.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: SpotifyTheme.green),
              label: 'Genel Bakış',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded, color: SpotifyTheme.textSecondary),
              selectedIcon: Icon(Icons.pie_chart_rounded, color: SpotifyTheme.green),
              label: 'Portföyüm',
            ),
            NavigationDestination(
              icon: Icon(Icons.rocket_launch_outlined, color: SpotifyTheme.textSecondary),
              selectedIcon: Icon(Icons.rocket_launch_rounded, color: SpotifyTheme.green),
              label: 'Halka Arz',
            ),
          ],
        ),
      ),
    );
  }
}
