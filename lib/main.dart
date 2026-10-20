import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads/ad_banner.dart';
import 'ui/calculator_screen.dart';
import 'ui/history_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ads are best-effort only: a failure here must never block the app.
  try {
    await MobileAds.instance.initialize();
  } catch (_) {
    // Ignore — the banner simply stays hidden.
  }
  runApp(const BijliBillApp());
}

class BijliBillApp extends StatelessWidget {
  const BijliBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bijli Bill Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BIJLI BILL CALCULATOR')),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                CalculatorScreen(),
                HistoryScreen(),
              ],
            ),
          ),
          // Persistent AdMob banner (TEST ads until production IDs land).
          const AdBanner(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
