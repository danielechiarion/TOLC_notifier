import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../classes/University.dart';

/// @class DynamicInputManager
/// @description Manages a dynamic list of FormBuilder fields. 
/// Supports initial data injection and real-time add/remove operations.
class DynamicInputManager extends StatefulWidget {
  final String fieldPrefix;
  final Set<University>? initialValues; // New: List of existing data

  const DynamicInputManager({
    super.key, 
    this.fieldPrefix = 'custom_field_',
    this.initialValues
  });

  @override
  State<DynamicInputManager> createState() => _DynamicInputManagerState();
}

class _DynamicInputManagerState extends State<DynamicInputManager> {
  // Map to store unique IDs and their corresponding initial values
  final List<MapEntry<int, String>> _fields = [];
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// @method _loadInitialData
  /// @description populates the internal state with provided initial values or a default empty field.
  void _loadInitialData() {
    if (widget.initialValues != null && widget.initialValues!.isNotEmpty) {
      for (var value in widget.initialValues!) {
        _fields.add(MapEntry(_nextId, value.name));
        _nextId++;
      }
    } else {
      // Start with one empty field if no data is provided
      _addField();
    }
  }

  void _addField() {
    setState(() {
      _fields.add(MapEntry(_nextId, ""));
      _nextId++;
    });
  }

  void _removeField(int id) {
    setState(() {
      _fields.removeWhere((entry) => entry.key == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _fields.length,
          itemBuilder: (context, index) {
            final entry = _fields[index];
            final currentId = entry.key;
            final initialVal = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: '${widget.fieldPrefix}$currentId',
                      initialValue: initialVal, // Sets the existing value
                      decoration: InputDecoration(
                        labelText: 'Field #${index + 1}',
                        border: const OutlineInputBorder(),
                        // Adds a clear button for better UX
                        suffixIcon: initialVal.isNotEmpty 
                          ? const Icon(Icons.edit, size: 16) 
                          : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Delete Button
                  IconButton(
                    onPressed: () => _removeField(currentId),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // The "+" Add Button
        OutlinedButton.icon(
          onPressed: _addField,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ],
    );
  }
}