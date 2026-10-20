/// Pakistan residential electricity tariffs (bundled).
///
/// Source: NEPRA uniform consumer-end tariff, effective 2026-01-01
/// (thenews.pk, minutemirror.com.pk, gharhub.com).
/// Rates change over time — the app shows an "estimates only" disclaimer.
library;

/// One slab: [fromUnit, toUnit] inclusive, at [ratePerUnit] Rs/unit.
class TariffSlab {
  final int fromUnit;
  final int toUnit; // inclusive; use a very large number for the top slab.
  final double ratePerUnit;

  const TariffSlab(this.fromUnit, this.toUnit, this.ratePerUnit);
}

enum ConsumerType {
  lifeline,
  protected,
  nonProtected;

  String get label {
    switch (this) {
      case ConsumerType.lifeline:
        return 'Lifeline';
      case ConsumerType.protected:
        return 'Protected';
      case ConsumerType.nonProtected:
        return 'Non-Protected';
    }
  }
}

/// Bundled tariff table. All amounts in PKR.
class Tariffs {
  static const double gstRate = 0.18;

  static const Map<ConsumerType, List<TariffSlab>> slabs = {
    ConsumerType.lifeline: [
      TariffSlab(1, 50, 3.95),
      TariffSlab(51, 100, 7.74),
    ],
    ConsumerType.protected: [
      TariffSlab(1, 100, 10.54),
      TariffSlab(101, 200, 13.01),
    ],
    ConsumerType.nonProtected: [
      TariffSlab(1, 100, 22.44),
      TariffSlab(101, 200, 28.91),
      TariffSlab(201, 300, 33.10),
      TariffSlab(301, 400, 37.99),
      TariffSlab(401, 500, 40.22),
      TariffSlab(501, 600, 41.62),
      TariffSlab(601, 700, 42.76),
      TariffSlab(701, 1000000, 47.69),
    ],
  };

  /// Maximum units this consumer type's table covers.
  static int maxUnits(ConsumerType type) =>
      slabs[type]!.last.toUnit == 1000000 ? -1 : slabs[type]!.last.toUnit;
}
