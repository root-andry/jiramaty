import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'home_screen.dart';
import 'calculator_screen.dart';
import 'statistics_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || 
            DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appuyez à nouveau pour quitter'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // PageView for swipe navigation
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  HomeScreen(),
                  CalculatorScreen(),
                  StatisticsScreen(),
                ],
              ),
            ),
            // Navigation bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                children: [
                  Blur(
                    blur: 10,
                    blurColor: isDark ? Colors.black : Colors.white,
                    child: Container(
                      height: 80 + MediaQuery.of(context).padding.bottom,
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                    ),
                  ),
                  SizedBox(
                    height: 80 + MediaQuery.of(context).padding.bottom,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                      ),
                      child: BottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: _onItemTapped,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedItemColor: Theme.of(context).colorScheme.primary,
                        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        selectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                        ),
                        type: BottomNavigationBarType.fixed,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Icon(Icons.home),
                            ),
                            label: 'Accueil',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Icon(Icons.calculate),
                            ),
                            label: 'Calculatrice',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Icon(Icons.bar_chart),
                            ),
                            label: 'Statistiques',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
