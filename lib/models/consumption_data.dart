class ConsumptionData {
  static double? lastNewKwatt;
  final double kwattUsage;
  final double totalPrice;
  final DateTime date;
  final double oldKwatt;
  final double newKwatt;

  ConsumptionData({
    required this.kwattUsage,
    required this.totalPrice,
    required this.date,
    required this.oldKwatt,
    required this.newKwatt,
  });

  Map<String, dynamic> toJson() => {
        'kwattUsage': kwattUsage,
        'totalPrice': totalPrice,
        'date': date.toIso8601String(),
        'oldKwatt': oldKwatt,
        'newKwatt': newKwatt,
        'lastNewKwatt': newKwatt,
      };

  factory ConsumptionData.fromJson(Map<String, dynamic> json) {
    lastNewKwatt = json['lastNewKwatt']?.toDouble();
    return ConsumptionData(
      kwattUsage: json['kwattUsage']?.toDouble() ?? 0.0,
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      oldKwatt: json['oldKwatt']?.toDouble() ?? 0.0,
      newKwatt: json['newKwatt']?.toDouble() ?? 0.0,
    );
  }
}
