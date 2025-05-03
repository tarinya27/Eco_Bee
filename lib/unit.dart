import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'localization.dart';

/// Data class representing a honey unit
class Unit {
  final String id;
  final String nickname;
  final String beeSpecies;
  final int numFrames;
  final String hiveSize;
  final String province;
  final String district;

  Unit({
    required this.id,
    required this.nickname,
    required this.beeSpecies,
    required this.numFrames,
    required this.hiveSize,
    required this.province,
    required this.district,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Unit(id: $id, nickname: $nickname)';
}

/// Main screen showing the list of honey units
class HoneyUnitListScreen extends StatefulWidget {
  @override
  State<HoneyUnitListScreen> createState() => _HoneyUnitListScreenState();
}

class _HoneyUnitListScreenState extends State<HoneyUnitListScreen> {
  /// Adds a new unit
  void _addNewUnit(Unit unit) async {
    try {
      final unitRef = FirebaseDatabase.instance.ref('units/${unit.id}');
      final existingUnit = await unitRef.once();
      if (existingUnit.snapshot.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unit already have an owner!')),
          );
        }
        return;
      }
      await unitRef.set({
        'nickname': unit.nickname,
        'beeSpecies': unit.beeSpecies,
        'numFrames': unit.numFrames,
        'hiveSize': unit.hiveSize,
        'province': unit.province,
        'district': unit.district,
        'owner': FirebaseAuth.instance.currentUser?.uid,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unit ${unit.nickname} added successfully!')),
        );
      }
    } catch (error) {
      _showError(error);
    }
  }

  /// Delete an unit
  void _deleteUnit(Unit unit) async {
    final unitRef = FirebaseDatabase.instance.ref('units/${unit.id}');
    await unitRef.remove();
  }

  /// Shows error message
  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $error')));
  }

  /// Opens form to add unit
  void _openAddUnitForm(BuildContext context, Localization localization) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => AddUnitForm(onSave: _addNewUnit, localization: localization),
      ),
    );
  }

  // Navigate back to Dashboard
  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Dashboard()),
      (route) => false,
    );
  }

  /// Builds the list of units
  Widget _buildUnitList(List<Unit> units, Localization localization) {
    return ListView.builder(
      itemCount: units.length,
      itemBuilder: (ctx, index) {
        final unit = units[index];
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
              backgroundColor: Colors.amber.shade700,
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              unit.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🐝 ${localization.species}: ${unit.beeSpecies}'),
                  Text('🪵 ${localization.frames}: ${unit.numFrames}'),
                  Text('🏠 ${localization.hiveSize}: ${unit.hiveSize}'),
                  Text(
                    '📍 ${localization.location}: ${unit.province}, ${unit.district}',
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                _deleteUnit(unit);
              },
              icon: Icon(Icons.delete),
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
        if (snapshot.hasError) {
          return const Center(child: Text(Localization.errorLoadingData));
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text(Localization.noUserDataAvailable));
        }
        final userData =
            snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;

        Localization localization = englishLocalization;
        if (userData?['language'] == 'Sinhala') {
          localization = sinhalaLocalization;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFE59C15),
            centerTitle: true,
            title: Text(localization.units),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _navigateToDashboard,
            ),
          ),
          body: StreamBuilder(
            stream:
                FirebaseDatabase.instance
                    .ref('units')
                    .orderByChild('owner')
                    .equalTo(FirebaseAuth.instance.currentUser?.uid)
                    .onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
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

              return _buildUnitList(units, localization);
            },
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: FloatingActionButton(
              onPressed: () => _openAddUnitForm(context, localization),
              backgroundColor: Color(0xFFE59C15),
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}

/// Form screen for adding a unit
class AddUnitForm extends StatefulWidget {
  final Function(Unit) onSave;
  final Localization localization;

  AddUnitForm({required this.onSave, required this.localization});

  @override
  State<AddUnitForm> createState() => _AddUnitFormState();
}

class _AddUnitFormState extends State<AddUnitForm> {
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _beeSpeciesController = TextEditingController();
  final _numFramesController = TextEditingController();
  final _hiveSizeController = TextEditingController();
  String? _province;
  String? _district;

  final Map<String, List<String>> locations = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'North-western': ['Kurunegala', 'Puttalam', 'Negombo'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
    'Central': ['Kandy', 'Nuwara Eliya', 'Matale'],
    'UVA': ['Badulla', 'Moneragala'],
    'North-central': ['Anuradhapura', 'Polonnaruwa'],
    'Northern': ['Jaffna', 'Mannar', 'Kilinochchi'],
  };

  void _saveForm() {
    final id = _idController.text;
    final nickname = _nicknameController.text;
    final beeSpecies = _beeSpeciesController.text;
    final numFrames = int.tryParse(_numFramesController.text) ?? 0;
    final hiveSize = _hiveSizeController.text;
    final province = _province ?? '';
    final district = _district ?? '';

    if (id.isEmpty ||
        nickname.isEmpty ||
        beeSpecies.isEmpty ||
        numFrames <= 0 ||
        hiveSize.isEmpty ||
        province.isEmpty ||
        district.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.localization.fillInTheFields)),
      );
      return;
    }

    final newUnit = Unit(
      id: id,
      nickname: nickname,
      beeSpecies: beeSpecies,
      numFrames: numFrames,
      hiveSize: hiveSize,
      province: province,
      district: district,
    );

    widget.onSave(newUnit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Localization localization = widget.localization;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.addUnit),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: localization.unitId),
              ),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: localization.nickname),
              ),
              DropdownButtonFormField(
                items: [
                  DropdownMenuItem(
                    value: 'apis mellifera',
                    child: Text('Apis Mellifera'),
                  ),
                  DropdownMenuItem(
                    value: 'apis cerana',
                    child: Text('Apis Cerana'),
                  ),
                  // Add more species as needed
                ],
                onChanged: (value) {
                  _beeSpeciesController.text = value.toString();
                },
                decoration: InputDecoration(labelText: localization.species),
              ),
              TextField(
                controller: _numFramesController,
                decoration: InputDecoration(labelText: localization.frames),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                items:
                    locations.keys
                        .map(
                          (province) => DropdownMenuItem(
                            value: province,
                            child: Text(province),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _province = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: localization.selectApiaryProvince,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items:
                    locations[_province]
                        ?.map(
                          (location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _district = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: localization.selectApiaryDistrict,
                ),
              ),
              DropdownButtonFormField(
                items: [
                  DropdownMenuItem(value: 'small', child: Text('Small')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'large', child: Text('Large')),
                ],
                onChanged: (value) {
                  _hiveSizeController.text = value.toString();
                },
                decoration: InputDecoration(labelText: localization.hiveSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
