import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../classes/University.dart';

/// @class DynamicInputManager
/// @description Manages a dynamic list of FormBuilder fields. 
/// Supports initial data injection and real-time add/remove operations.
class DynamicInputManager extends StatefulWidget {
  final String fieldPrefix;
  final Set<University>? initialValues; // New: List of existing data
  final Set<University>? universitySuggestions; // suggestions for university

  DynamicInputManager({
    super.key, 
    this.fieldPrefix = 'custom_field_',
    this.initialValues,
    this.universitySuggestions
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
                    child: FormBuilderField<String>(
                      name: '${widget.fieldPrefix}$currentId',
                      initialValue: initialVal,
                      builder: (FormFieldState<String?> field){
                        return Autocomplete<University>(
                          /* Sets the default text in the field using the existing data.
                            TextEditingValue is required to initialize the internal controller.
                          */
                          initialValue: TextEditingValue(text: initialVal),
                          /* set parameter to see the univerisity name for
                          each university */
                          displayStringForOption: (University university) => university.name,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            /* Logic to filter suggestions. 
                              Returns an empty list if the input is empty.
                            */
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<University>.empty();
                            }
                            /* if the list of the university suggestions
                            is null or empty return an empty list */
                            if(widget.universitySuggestions == null || widget.universitySuggestions!.isEmpty){
                              return const Iterable<University>.empty();
                            }

                            return widget.universitySuggestions!.where((University singleUniversity) {
                              return singleUniversity.name.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  );
                            });
                          },

                          onSelected: (University selection) {
                            /* update the FormFielBuilder state
                            directly to make the change appear */
                            field.didChange(selection.name);

                            /* Updates the local state when a suggestion is clicked.
                              Ensures the _fields list is kept in sync with the UI.
                            */
                            setState(() {
                              int idx = _fields.indexWhere((e) => e.key == currentId);
                              if (idx != -1) {
                                _fields[idx] = MapEntry(currentId, selection.name);
                              }
                            });
                          },

                          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                            /* Customizes the appearance of the input field.
                              The textController and focusNode are provided by the Autocomplete widget.
                            */
                            return TextField(
                              controller: textController,
                              focusNode: focusNode,
                              onSubmitted: (value) => onFieldSubmitted(),
                              decoration: InputDecoration(
                                labelText: 'University #${index + 1}',
                                border: const OutlineInputBorder(),
                                suffixIcon: const Icon(Icons.school_outlined, size: 20),
                              ),
                            );
                          },
                        );
                      }
                    )
                  ),
                  const SizedBox(width: 10),
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
          label: const Text('Aggiungi univerisità'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ],
    );
  }
}