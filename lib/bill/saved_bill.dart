/// Saved calculation record (history).
library;

import 'dart:convert';

import 'package:bijli_bill/bill/tariffs.dart';

class SavedBill {
  final DateTime date;
  final ConsumerType type;
  final int units;
  final double fpa;
  final bool includeGst;
  final double total;

  const SavedBill({
    required this.date,
    required this.type,
    required this.units,
    required this.fpa,
    required this.includeGst,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type.name,
        'units': units,
        'fpa': fpa,
        'includeGst': includeGst,
        'total': total,
      };

  factory SavedBill.fromJson(Map<String, dynamic> json) => SavedBill(
        date: DateTime.parse(json['date'] as String),
        type: ConsumerType.values
            .firstWhere((t) => t.name == json['type']),
        units: (json['units'] as num).toInt(),
        fpa: (json['fpa'] as num).toDouble(),
        includeGst: json['includeGst'] as bool,
        total: (json['total'] as num).toDouble(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory SavedBill.fromJsonString(String s) =>
      SavedBill.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
