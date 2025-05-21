import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'localization.dart';
import 'unit.dart';

/// Data class representing a production record
class Production {
  final String id;
  final double quantity;
  final DateTime timestamp;

  Production({
    required this.id,
    required this.quantity,
    required this.timestamp,
  });

  // Equality operator to compare Production objects by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Production && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // String representation for debugging
  @override
  String toString() => 'Production(id: $id, quantity: $quantity)';
}

/// Main screen showing the list of production records
class ProductionScreen extends StatefulWidget {
  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

 // Currently selected bee unit
class _ProductionScreenState extends State<ProductionScreen> {
  Unit? unit;

  /// Adds a new production record
  void _addNewProduction(Production production) async {
    try {
      final recordRef =
          FirebaseDatabase.instance.ref('production/${production.id}').push();
      // Save quantity and timestamp 
      await recordRef.set({
        'quantity': production.quantity,
        'timestamp': production.timestamp.toIso8601String(),
      });
       // Show success message if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Production record added successfully!')),
        );
      }
    } catch (error) {
       // Show error message if saving fails
      _showError(error);
    }
  }

  /// Shows error message using snackkbar
  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $error')));
  }

 /// Opens the form screen to add a production record
  void _openAddProductionForm(BuildContext context, Localization localization) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => AddProductionForm(
              unit: unit,
              onSave: _addNewProduction,
              localization: localization,
            ),
      ),
    );
  }

  /// Navigate back to Dashboard
  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Dashboard()),
      (route) => false,
    );
  }

  /// Builds the list of production records
  Widget _buildProductionList(
    List<Production> productions,
    Localization localization,
  ) {
    return ListView.builder(
      itemCount: productions.length,
      itemBuilder: (ctx, index) {
        final production = productions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE59C15),
              child: Text(
                (productions.length - index).toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              'Quantity: ${production.quantity}kg',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
               // Show formatted date/time of production record
              child: Text('📅 ${production.timestamp.toLocal()}'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser?.uid}')
              .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Show error if data load fails
        if (snapshot.hasError) {
          return const Center(child: Text(Localization.errorLoadingData));
        }
        // Show message if no user data found
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text(Localization.noUserDataAvailable));
        }
        // Extract user data
        final userData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

        // Set localization based on user language preference
        Localization localization = englishLocalization;
        if (userData?['language'] == 'Sinhala') {
          localization = sinhalaLocalization;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE59C15),
            centerTitle: true,
            title: Text(localization.production),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _navigateToDashboard,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder(
                  // StreamBuilder to load user's bee units
                  stream:
                      FirebaseDatabase.instance
                          .ref('units')
                          .orderByChild('owner')
                          .equalTo(FirebaseAuth.instance.currentUser?.uid)
                          .onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Parse units from Firebase data
                    final unitsData =
                        snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                    final List<Unit> units =
                        unitsData != null
                            ? unitsData.entries
                                .map(
                                  (entry) => Unit(
                                    id: entry.key,
                                    nickname: entry.value['nickname'],
                                    beeSpecies: entry.value['beeSpecies'],
                                    numFrames: entry.value['numFrames'],
                                    hiveSize: entry.value['hiveSize'],
                                    province: entry.value['province'],
                                    district: entry.value['district'],
                                  ),
                                )
                                .toList()
                            : [];
                    // Show message if no units found
                    if (units.isEmpty) {
                      return const Center(
                        child: Text(
                          'No units found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    // Dropdown to select one of the user's units
                    return DropdownButtonFormField<Unit>(
                      decoration: InputDecoration(
                        labelText: localization.selectTheUnit,
                      ),
                      value: unit,
                      items:
                          units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.nickname),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          unit = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Display production records if unit selected; else show message
                Expanded(
                  child:
                      unit == null
                          ? const Center(
                            child: Text(
                              'No unit selected',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : StreamBuilder(
                            stream:
                                FirebaseDatabase.instance
                                    .ref('production/${unit?.id}')
                                    .orderByChild('timestamp')
                                    .onValue,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }
                              if (snapshot.data?.snapshot.value == null) {
                                return Center(
                                  child: Text(
                                    localization.noDataAvailable,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }
                              final productionData =
                                  snapshot.data?.snapshot.value
                                      as Map<dynamic, dynamic>?;
                              final List<Production> productions =
                                  productionData != null
                                      ? productionData.entries
                                          .map(
                                            (entry) => Production(
                                              id: entry.key,
                                              quantity:
                                                  (entry.value['quantity']
                                                          as num)
                                                      .toDouble(),
                                              timestamp: DateTime.parse(
                                                entry.value['timestamp'],
                                              ),
                                            ),
                                          )
                                          .toList()
                                      : [];
                              // Build the list view of production records
                              return _buildProductionList(
                                productions,
                                localization,
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          // Floating button to add new production record
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: FloatingActionButton(
              onPressed: () => _openAddProductionForm(context, localization),
              backgroundColor: Color(0xFFE59C15),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

/// Form screen for adding a production record
class AddProductionForm extends StatefulWidget {
  final Unit? unit; // The unit for which production is added
  final Function(Production) onSave; // Callback to save the production record
  final Localization localization;

  AddProductionForm({
    required this.unit,
    required this.onSave,
    required this.localization,
  });

  @override
  State<AddProductionForm> createState() => _AddProductionFormState();
}

class _AddProductionFormState extends State<AddProductionForm> {
  final _quantityController = TextEditingController(text: '0.0');

/// Save the production record after validation
  void _saveForm() {
    final id = widget.unit?.id;
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;

    // Validate inputs
    if (id == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.localization.fillInTheFields)),
      );
      return;
    }

    // Create a new production record
    final newProduction = Production(
      id: id,
      quantity: quantity,
      timestamp: DateTime.now(),
    );

    widget.onSave(newProduction);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // If no unit is passed, close the form immediately
    if (widget.unit == null) {
      Navigator.pop(context);
    }
    Localization localization = widget.localization;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.addProduction),
        backgroundColor: Color(0xFFE59C15),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
            tooltip: localization.save,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Show unit nickname (read-only)
            TextField(
              controller: TextEditingController(text: widget.unit?.nickname),
              decoration: InputDecoration(labelText: localization.unitId),
              enabled: false,
            ),
            TextField(
              // Input field for production quantity
              controller: _quantityController,
              decoration: InputDecoration(labelText: localization.quantity),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
    );
  }
}
