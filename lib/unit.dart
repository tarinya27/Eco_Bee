import 'package:flutter/material.dart';

import 'dashboard.dart'; // Using your existing Dashboard UI

/// Data class representing a honey unit
class Units {
  final String id;
  final String name;
  final double quantity;

  Units({required this.id, required this.name, required this.quantity});
}

/// Main screen showing the list of honey units
class HoneyUnitListScreen extends StatefulWidget {
  @override
  State<HoneyUnitListScreen> createState() => _HoneyUnitListScreenState();
}

class _HoneyUnitListScreenState extends State<HoneyUnitListScreen> {
  List<Units> units = [];

  /// Adds a new unit
  void _addNewUnit(Units unit) {
    setState(() {
      units.add(unit);
    });
  }

  /// Opens form to add unit
  void _openAddUnitForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddUnitForm(onSave: _addNewUnit)));
  }

  // Navigate back to Dashboard
  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Dashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE59C15),
        centerTitle: true,
        title: Text('Honey Units'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateToDashboard,
        ),
      ),
      body:
          units.isEmpty
              ? Center(child: Text('No units yet. Click + to add.'))
              : ListView.builder(
                itemCount: units.length,
                itemBuilder: (ctx, index) {
                  final unit = units[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(unit.id)),
                    title: Text(unit.name),
                    subtitle: Text('Honey: ${unit.quantity} ml'),
                  );
                },
              ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: FloatingActionButton(
          onPressed: () => _openAddUnitForm(context),
          backgroundColor: Color(0xFFE59C15),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Form screen for adding a unit
class AddUnitForm extends StatefulWidget {
  final Function(Units) onSave;

  AddUnitForm({required this.onSave});

  @override
  State<AddUnitForm> createState() => _AddUnitFormState();
}

class _AddUnitFormState extends State<AddUnitForm> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  void _saveForm() {
    final id = _idController.text;
    final name = _nameController.text;
    final quantity = double.tryParse(_quantityController.text) ?? 0;

    if (id.isEmpty || name.isEmpty || quantity <= 0) return;

    final newUnit = Units(id: id, name: name, quantity: quantity);
    widget.onSave(newUnit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Honey Unit'),
        backgroundColor: Color(0xFFE59C15),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
            tooltip: 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Unit ID'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Unit Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Honey Quantity (ml)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
