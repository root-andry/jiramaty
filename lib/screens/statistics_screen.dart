import 'package:flutter/material.dart';
import '../models/consumption_data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  static List<ConsumptionData> consumptionHistory = [];
  static late SharedPreferences _prefs;

  // New initialization method
  static void initPrefs(SharedPreferences prefs) {
    _prefs = prefs;
    loadData();
  }

  // Modified load data method
  static Future<void> loadData() async {
    try {
      final String? jsonString = _prefs.getString('consumption_history');
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        consumptionHistory = jsonList
            .map((json) => ConsumptionData.fromJson(json))
            .toList();
        
        // Update lastNewKwatt from the most recent entry
        if (consumptionHistory.isNotEmpty) {
          ConsumptionData.lastNewKwatt = consumptionHistory.last.newKwatt;
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      consumptionHistory = [];
    }
  }

  // Modified save data method
  static Future<void> saveData() async {
    try {
      final String jsonString = json.encode(
        consumptionHistory.map((data) => data.toJson()).toList(),
      );
      await _prefs.setString('consumption_history', jsonString);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Remove the initialization here since it's handled in main.dart
    setState(() {
      // Refresh the UI with loaded data
    });
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nettoyer tout l\'historique'),
        content: const Text('Vous êtes sûr de vouloir supprimer toutes les données de consommation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                StatisticsScreen.consumptionHistory.clear();
              });
              await StatisticsScreen.saveData(); // Save empty state
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historique effacé'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(ConsumptionData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consommation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date', DateFormat('dd/MM/yyyy HH:mm').format(data.date)),
            const Divider(),
            _buildDetailRow('Usage', '${data.kwattUsage.toStringAsFixed(2)} kW'),
            const Divider(),
            _buildDetailRow('Prix', '${data.totalPrice.toStringAsFixed(2)} Ariary'),
            const Divider(),
            _buildDetailRow('Prix moyen/kW', 
              '${(data.totalPrice / data.kwattUsage).toStringAsFixed(2)} Ar/kW'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    const Expanded(
                    child: Text(
                      'Consommation Historique',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                  if (StatisticsScreen.consumptionHistory.isNotEmpty)
                    IconButton(
                      onPressed: _clearAllData,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'Effacer tout',
                    ),
                ],
              ),
            ),
            Expanded(
              child: StatisticsScreen.consumptionHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune donnée de consommation disponible.\nAjoutez des données dans l\'onglet Calculatrice.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: StatisticsScreen.consumptionHistory.length,
                      itemBuilder: (context, index) {
                        final data = StatisticsScreen.consumptionHistory[index];
                        return Dismissible(
                          key: Key('${data.date.millisecondsSinceEpoch}'),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            setState(() {
                              StatisticsScreen.consumptionHistory.removeAt(index);
                            });
                            await StatisticsScreen.saveData(); // Save after deletion
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enregistrement supprimé'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Enlever l\'enregistrement'),
                                content: const Text('Vous êtes sûr de vouloir supprimer cet enregistrement?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: InkWell( // Add this InkWell
                              onTap: () => _showDetailDialog(data),
                              child: ListTile(
                                title: Text(
                                  'Usage: ${data.kwattUsage.toStringAsFixed(2)} kWatt',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Prix: ${data.totalPrice.toStringAsFixed(2)} Ar\n'
                                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(data.date)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.info_outline, color: colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Icon(Icons.swipe_left, color: colorScheme.onSurface.withOpacity(0.5)),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
