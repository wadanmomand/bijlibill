import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(
        title: const Text('BIJLI BILL CALCULATOR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sources & Disclaimer',
            onPressed: () => showSourcesDialog(context),
          ),
        ],
      ),
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

/// Sources & Disclaimer dialog (Play Misleading Claims policy fix,
/// 2026-10-23). Opened from the AppBar info button on every screen.
/// States plainly that this is NOT a government app and names the
/// official source of the tariff tables.
Future<void> showSourcesDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sources & Disclaimer'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This app is NOT a government app. It is not affiliated '
              'with, endorsed by, or representing NEPRA, the Government '
              'of Pakistan, the Ministry of Energy (Power Division), or '
              'any electricity distribution company (DISCO).',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tariff source: the slab tables in this app are based on '
              "NEPRA's published consumer-end tariff for calendar year "
              '2026 (determined 7 January 2026) and the Federal '
              "Government's uniform tariff motion decided by NEPRA on "
              '12 January 2026 and notified on 13 January 2026, '
              'effective 1 January 2026.',
            ),
            const SizedBox(height: 12),
            const Text('Official source:'),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('https://www.nepra.org.pk/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: const Text(
                'NEPRA — www.nepra.org.pk\n'
                '(tariff determinations & notifications)',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Amounts are estimates based on the bundled tariff tables. '
              "Your DISCO's bill is the final authority and may include "
              'additional government duties and surcharges.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
