import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiramaty/screens/statistics_screen.dart';
import '../models/consumption_data.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldKwattController = TextEditingController();
  final _newKwattController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _totalKwattController = TextEditingController();
  double _result = 0.0;
  double _kwattUsage = 0.0;

  @override
  void initState() {
    super.initState();
    // Auto-fill old kWatt with last new kWatt reading if available
    if (ConsumptionData.lastNewKwatt != null) {
      _oldKwattController.text = ConsumptionData.lastNewKwatt!.toString();
    }
  }

  void _calculateConsumption() {
    if (_formKey.currentState!.validate()) {
      double oldKwatt = double.parse(_oldKwattController.text);
      double newKwatt = double.parse(_newKwattController.text);
      double totalPrice = double.parse(_totalPriceController.text);
      double totalKwatt = double.parse(_totalKwattController.text);

      setState(() {
        _kwattUsage = newKwatt - oldKwatt;
        _result = (_kwattUsage * totalPrice / totalKwatt);
      });
    }
  }

  void _saveData() async {
    if (_result > 0) {
      final double oldKwatt = double.parse(_oldKwattController.text);
      final double newKwatt = double.parse(_newKwattController.text);
      
      // Store the new kWatt reading for next time
      ConsumptionData.lastNewKwatt = newKwatt;
      
      final data = ConsumptionData(
        kwattUsage: _kwattUsage,
        totalPrice: _result,
        date: DateTime.now(),
        oldKwatt: oldKwatt,
        newKwatt: newKwatt,
      );
      
      // Add to global statistics data
      StatisticsScreen.consumptionHistory.add(data);
      await StatisticsScreen.saveData();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données sauvegardées'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Set old kWatt to last new kWatt before clearing
      _oldKwattController.text = newKwatt.toString();
      _newKwattController.clear();
      _totalPriceController.clear();
      _totalKwattController.clear();
      setState(() {
        _result = 0.0;
        _kwattUsage = 0.0;
      });
    }
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Entrez une valeur';
    }
    if (double.tryParse(value) == null) {
      return 'Entrez un nombre valide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false, // Don't pad bottom as Dashboard handles this
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'kWatt Calculateur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Counter 2 Input Fields
                Card(
                  elevation: 4,
                  color: colorScheme.surfaceVariant,
                  child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text(
                      'Compteur divisionnaire',
                      style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _oldKwattController,
                      decoration: const InputDecoration(
                      labelText: 'Ancien index kWatt',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.power),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                      inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newKwattController,
                      decoration: const InputDecoration(
                      labelText: 'Nouveau index kWatt',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.power),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                      inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    ],
                  ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Counter 1 Input Fields
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Compteur principal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _totalPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Prix total',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateNumber,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _totalKwattController,
                          decoration: const InputDecoration(
                            labelText: 'Total consommation kWatt',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.electric_bolt),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateNumber,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Calculate Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _calculateConsumption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Calculer',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Result Card
                Card(
                  elevation: 4,
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          'Prix estimé',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_result.toStringAsFixed(2)} Ariary',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        if (_result > 0) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Total consommation: ${_kwattUsage.toStringAsFixed(2)} kWatt',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: _saveData,
                              icon: const Icon(Icons.save),
                              label: const Text('Sauvegarder'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Add extra padding at bottom for navigation bar
                SizedBox(height: MediaQuery.of(context).padding.bottom + 96),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldKwattController.dispose();
    _newKwattController.dispose();
    _totalPriceController.dispose();
    _totalKwattController.dispose();
    super.dispose();
  }
}
