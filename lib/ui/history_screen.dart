/// Saved calculations history.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bill/history_store.dart';
import '../bill/saved_bill.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedBill> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await HistoryStore.load();
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0.00', 'en_PK');
    final dateFmt = DateFormat('dd MMM yyyy, hh:mm a');
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () async {
                await HistoryStore.clear();
                _reload();
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('No saved bills yet.',
                      style: TextStyle(color: Colors.black54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final b = _items[i];
                    return Dismissible(
                      key: ValueKey('${b.date.toIso8601String()}-$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.shade100,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.red),
                      ),
                      onDismissed: (_) async {
                        await HistoryStore.removeAt(i);
                        _reload();
                      },
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.receipt_long_outlined,
                              color: Color(0xFF1A237E)),
                          title: Text(
                              '${b.units} units • ${b.type.label}'),
                          subtitle: Text(dateFmt.format(b.date)),
                          trailing: Text(
                            'Rs ${money.format(b.total)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
