/// Calculator input screen: units or meter readings, consumer type,
// optional FPA, GST toggle.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bill/bill_calculator.dart';
import '../bill/tariffs.dart';
import 'result_screen.dart';

/// Glossy 3D-style gold button, matching the approved concept art.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const GoldButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFE69A00)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: const Color(0xFFC67F00), width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top gloss highlight.
            Positioned(
              top: 3,
              left: 24,
              right: 24,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0D1330),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Consumer-type selector styled like the concept: gold 3D chip when selected.
class _TypeSelector extends StatelessWidget {
  final ConsumerType selected;
  final ValueChanged<ConsumerType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ConsumerType.values.map((t) {
        final isSel = t == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSel
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFD54F),
                            Color(0xFFFFB300),
                            Color(0xFFE69A00)
                          ],
                        )
                      : null,
                  color: isSel ? null : Colors.white,
                  border: Border.all(
                    color: isSel
                        ? const Color(0xFFC67F00)
                        : const Color(0xFFD9DCE8),
                    width: isSel ? 1.5 : 1,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFB300)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  t.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel
                        ? const Color(0xFF0D1330)
                        : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _unitsCtrl = TextEditingController();
  final _prevCtrl = TextEditingController();
  final _currCtrl = TextEditingController();
  final _fpaCtrl = TextEditingController();
  ConsumerType _type = ConsumerType.nonProtected;
  bool _byReading = false;
  bool _includeGst = false;
  String? _error;

  @override
  void dispose() {
    _unitsCtrl.dispose();
    _prevCtrl.dispose();
    _currCtrl.dispose();
    _fpaCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _error = null);
    try {
      final int units;
      if (_byReading) {
        final prev = int.parse(_prevCtrl.text.trim());
        final curr = int.parse(_currCtrl.text.trim());
        units = BillCalculator.unitsFromReadings(prev, curr);
      } else {
        units = int.parse(_unitsCtrl.text.trim());
      }
      final fpa = _fpaCtrl.text.trim().isEmpty
          ? 0.0
          : double.parse(_fpaCtrl.text.trim());
      final result = BillCalculator.calculate(
        units: units,
        type: _type,
        fpa: fpa,
        includeGst: _includeGst,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } on FormatException {
      setState(() => _error = 'Please enter valid numbers.');
    } on ArgumentError catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Units')),
            ButtonSegment(value: true, label: Text('Meter Reading')),
          ],
          selected: {_byReading},
          onSelectionChanged: (s) =>
              setState(() => _byReading = s.first),
        ),
        const SizedBox(height: 16),
        if (_byReading) ...[
          TextField(
            controller: _prevCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(
              labelText: 'Previous reading',
              hintText: 'e.g. 12500',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(
              labelText: 'Current reading',
              hintText: 'e.g. 12850',
            ),
          ),
        ] else
          TextField(
            controller: _unitsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(
              labelText: 'Units consumed',
              hintText: 'e.g. 250',
            ),
          ),
        const SizedBox(height: 16),
        const Text('Consumer type',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _TypeSelector(
          selected: _type,
          onChanged: (t) => setState(() => _type = t),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _fpaCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Fuel price adjustment (Rs, optional)',
            hintText: 'e.g. 350',
          ),
        ),
        SwitchListTile(
          title: const Text('Add GST (18%)'),
          value: _includeGst,
          onChanged: (v) => setState(() => _includeGst = v),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 12),
        GoldButton(label: 'Calculate Bill', onPressed: _calculate),
        const SizedBox(height: 12),
        const Text(
          'Tariffs: NEPRA uniform residential rates (Jan 2026). Estimates only.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
