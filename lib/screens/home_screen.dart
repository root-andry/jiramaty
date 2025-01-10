import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'statistics_screen.dart';
import '../models/consumption_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  double get totalConsumption {
    return StatisticsScreen.consumptionHistory.fold(
      0.0,
      (sum, item) => sum + item.kwattUsage,
    );
  }

  double get totalPrice {
    return StatisticsScreen.consumptionHistory.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  double get averageConsumption {
    if (StatisticsScreen.consumptionHistory.isEmpty) return 0;
    return totalConsumption / StatisticsScreen.consumptionHistory.length;
  }

  List<FlSpot> get consumptionSpots {
    final history = StatisticsScreen.consumptionHistory;
    if (history.isEmpty) return [];

    return List.generate(history.length, (index) {
      return FlSpot(index.toDouble(), history[index].kwattUsage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Center(
                child: Text(
                  'Récapitulatif de la consommation',
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                ),
                const SizedBox(height: 24),
              // Statistics Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Consommation totale',
                    '${totalConsumption.toStringAsFixed(2)} kW',
                    Icons.electric_bolt,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Prix total',
                    '${totalPrice.toStringAsFixed(2)} Ar',
                    Icons.money,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Moyenne',
                    '${averageConsumption.toStringAsFixed(2)} kW',
                    Icons.analytics,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Historique',
                    '${StatisticsScreen.consumptionHistory.length}',
                    Icons.history,
                    Colors.purple,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Consumption Chart
              if (StatisticsScreen.consumptionHistory.isNotEmpty) ...[
                const Text(
                  'Consommation récente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: consumptionSpots,
                          isCurved: true,
                          color: colorScheme.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recent Records
                const Text(
                  'Historique récent',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildRecentRecords(),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Aucun enregistrement trouvé.\nVeuillez ajouter un enregistrement pour commencer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentRecords() {
    final records = StatisticsScreen.consumptionHistory;
    if (records.isEmpty) return [];

    return records.reversed
        .take(3)
        .map((record) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.electric_bolt, color: Colors.blue),
                title: Text(
                  '${record.kwattUsage.toStringAsFixed(2)} kW',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${record.totalPrice.toStringAsFixed(2)} Ar\n'
                  '${DateFormat('dd/MM/yyyy').format(record.date)}',
                ),
                isThreeLine: true,
              ),
            ))
        .toList();
  }
}
