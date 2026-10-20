import 'package:bijli_bill/bill/bill_calculator.dart';
import 'package:bijli_bill/bill/tariffs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BillCalculator', () {
    test('non-protected 50 units = 50 x 22.44', () {
      final r = BillCalculator.calculate(
          units: 50, type: ConsumerType.nonProtected);
      expect(r.energyCharges, closeTo(50 * 22.44, 0.001));
      expect(r.lines.length, 1);
      expect(r.gst, 0);
      expect(r.total, closeTo(r.energyCharges, 0.001));
    });

    test('non-protected 150 units spans two slabs', () {
      final r = BillCalculator.calculate(
          units: 150, type: ConsumerType.nonProtected);
      expect(r.lines.length, 2);
      expect(r.energyCharges, closeTo(100 * 22.44 + 50 * 28.91, 0.001));
    });

    test('non-protected 750 units hits the top slab', () {
      final r = BillCalculator.calculate(
          units: 750, type: ConsumerType.nonProtected);
      expect(r.lines.last.ratePerUnit, 47.69);
      final expected = 100 * 22.44 +
          100 * 28.91 +
          100 * 33.10 +
          100 * 37.99 +
          100 * 40.22 +
          100 * 41.62 +
          100 * 42.76 +
          50 * 47.69;
      expect(r.energyCharges, closeTo(expected, 0.001));
    });

    test('protected 200 units = 100x10.54 + 100x13.01', () {
      final r =
          BillCalculator.calculate(units: 200, type: ConsumerType.protected);
      expect(r.energyCharges, closeTo(100 * 10.54 + 100 * 13.01, 0.001));
    });

    test('protected rejects 201 units (out of range)', () {
      expect(
          () => BillCalculator.calculate(
              units: 201, type: ConsumerType.protected),
          throwsArgumentError);
    });

    test('lifeline 50 units at 3.95; 100 units spans both lifeline slabs', () {
      final r50 =
          BillCalculator.calculate(units: 50, type: ConsumerType.lifeline);
      expect(r50.energyCharges, closeTo(50 * 3.95, 0.001));
      final r100 =
          BillCalculator.calculate(units: 100, type: ConsumerType.lifeline);
      expect(r100.energyCharges, closeTo(50 * 3.95 + 50 * 7.74, 0.001));
    });

    test('GST 18% applies on energy + FPA', () {
      final r = BillCalculator.calculate(
        units: 100,
        type: ConsumerType.nonProtected,
        fpa: 200,
        includeGst: true,
      );
      final energy = 100 * 22.44;
      expect(r.gst, closeTo((energy + 200) * 0.18, 0.001));
      expect(r.total, closeTo(energy + 200 + r.gst, 0.001));
    });

    test('no GST when toggle off, FPA still added', () {
      final r = BillCalculator.calculate(
        units: 100,
        type: ConsumerType.nonProtected,
        fpa: 150,
        includeGst: false,
      );
      expect(r.gst, 0);
      expect(r.total, closeTo(100 * 22.44 + 150, 0.001));
    });

    test('zero/negative units throw', () {
      expect(
          () => BillCalculator.calculate(
              units: 0, type: ConsumerType.nonProtected),
          throwsArgumentError);
      expect(
          () => BillCalculator.calculate(
              units: -5, type: ConsumerType.nonProtected),
          throwsArgumentError);
    });

    test('negative FPA throws', () {
      expect(
          () => BillCalculator.calculate(
              units: 100, type: ConsumerType.nonProtected, fpa: -10),
          throwsArgumentError);
    });

    test('unitsFromReadings: 1200 - 1000 = 200', () {
      expect(BillCalculator.unitsFromReadings(1000, 1200), 200);
    });

    test('unitsFromReadings: current < previous throws', () {
      expect(() => BillCalculator.unitsFromReadings(1200, 1000),
          throwsArgumentError);
    });

    test('unitsFromReadings: equal readings throw', () {
      expect(() => BillCalculator.unitsFromReadings(1000, 1000),
          throwsArgumentError);
    });
  });
}
