import 'package:flutter/material.dart';

import 'ui/calculator_screen.dart';
import 'ui/history_screen.dart';
import 'ui/theme.dart';

void main() {
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
      body: IndexedStack(
        index: _index,
        children: const [
          CalculatorScreen(),
          HistoryScreen(),
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
