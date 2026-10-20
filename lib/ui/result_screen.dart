/// Itemized bill breakdown screen.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bill/bill_calculator.dart';
import '../bill/history_store.dart';
import '../bill/saved_bill.dart';
import 'calculator_screen.dart' show GoldButton;

class ResultScreen extends StatelessWidget {
  final BillResult result;

  const ResultScreen({super.key, required this.result});

  Future<void> _save(BuildContext context) async {
    await HistoryStore.add(SavedBill(
      date: DateTime.now(),
      type: result.type,
      units: result.totalUnits,
      fpa: result.fpa,
      includeGst: result.gst > 0,
      total: result.total,
    ));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill saved to history')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0.00', 'en_PK');
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Breakdown')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFF1A237E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${result.totalUnits} units • ${result.type.label}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${money.format(result.total)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Estimated total',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Energy charges by slab',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...result.lines.map(
            (line) => Card(
              child: ListTile(
                title: Text(line.label),
                subtitle: Text('${line.units} units'),
                trailing: Text(
                  'Rs ${money.format(line.amount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Energy charges'),
                  trailing: Text('Rs ${money.format(result.energyCharges)}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (result.fpa > 0)
                  ListTile(
                    title: const Text('Fuel price adjustment'),
                    trailing: Text('Rs ${money.format(result.fpa)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
                if (result.gst > 0)
                  ListTile(
                    title: const Text('GST (18%)'),
                    trailing: Text('Rs ${money.format(result.gst)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Estimates only — actual bill may differ. Taxes, FPA and surcharges change monthly.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GoldButton(
            label: 'Save to History',
            onPressed: () => _save(context),
          ),
        ],
      ),
    );
  }
}
