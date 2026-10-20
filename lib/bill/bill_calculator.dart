/// Bill calculation engine: slab-wise energy charges + FPA + GST.
library;

import 'tariffs.dart';

/// One row of the itemized breakdown.
class BillLine {
  final String label; // e.g. "1–100 units × Rs 22.44"
  final int units;
  final double ratePerUnit;
  final double amount;

  const BillLine(this.label, this.units, this.ratePerUnit, this.amount);
}

/// Full calculation result.
class BillResult {
  final ConsumerType type;
  final int totalUnits;
  final List<BillLine> lines;
  final double energyCharges;
  final double fpa;
  final double gst;
  final double total;

  const BillResult({
    required this.type,
    required this.totalUnits,
    required this.lines,
    required this.energyCharges,
    required this.fpa,
    required this.gst,
    required this.total,
  });
}

class BillCalculator {
  /// Calculates the bill for [units] under [type].
  ///
  /// [fpa] is an optional user-entered fuel-price-adjustment amount (Rs).
  /// [includeGst] applies 18% GST on (energy + FPA).
  /// Throws [ArgumentError] for invalid units or units beyond the
  /// consumer type's covered range.
  static BillResult calculate({
    required int units,
    required ConsumerType type,
    double fpa = 0,
    bool includeGst = false,
  }) {
    if (units <= 0) {
      throw ArgumentError('Units must be positive, got $units.');
    }
    if (fpa < 0) {
      throw ArgumentError('FPA cannot be negative, got $fpa.');
    }
    final table = Tariffs.slabs[type]!;
    final maxCovered = table.last.toUnit;
    if (units > maxCovered) {
      throw ArgumentError(
          'Units ($units) exceed the ${type.label} table range (max $maxCovered).');
    }

    final lines = <BillLine>[];
    var remaining = units;
    for (final slab in table) {
      if (remaining <= 0) break;
      final slabSize = slab.toUnit - slab.fromUnit + 1;
      final used = remaining < slabSize ? remaining : slabSize;
      final amount = used * slab.ratePerUnit;
      lines.add(BillLine(
        '${slab.fromUnit}–${slab.toUnit} × Rs ${slab.ratePerUnit.toStringAsFixed(2)}',
        used,
        slab.ratePerUnit,
        amount,
      ));
      remaining -= used;
    }

    final energy =
        lines.fold<double>(0, (sum, line) => sum + line.amount);
    final gst = includeGst ? (energy + fpa) * Tariffs.gstRate : 0.0;
    return BillResult(
      type: type,
      totalUnits: units,
      lines: lines,
      energyCharges: energy,
      fpa: fpa,
      gst: gst,
      total: energy + fpa + gst,
    );
  }

  /// Units consumed between two meter readings.
  static int unitsFromReadings(int previous, int current) {
    if (current < previous) {
      throw ArgumentError(
          'Current reading ($current) is less than previous ($previous).');
    }
    final units = current - previous;
    if (units <= 0) {
      throw ArgumentError('Readings must differ to consume units.');
    }
    return units;
  }
}
