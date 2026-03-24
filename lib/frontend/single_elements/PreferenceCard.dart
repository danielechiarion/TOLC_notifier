import 'package:flutter/material.dart';

import '../../classes/Preference.dart';
import '../../classes/University.dart';

import '../../services/database_helper.dart';
import '../../services/logger_utils.dart';

/// Class to display the preference configured
/// which could be changed during the configuration.
/// 
/// This widget is a StatefulWidget to manage the editing state
/// of the specific preference card.
class PreferenceCard extends StatefulWidget {
  /* define attributes for preference card */
  final Preference _preference;
  final Set<University> _universityList;
  final Future<void> Function(Preference preference) deleteFunction;
  final VoidCallback onUpdate;

  /// Constructor for the PreferenceCard.
  /// Note: Variables that change (state) are moved to the _State class.
  const PreferenceCard({
    super.key, 
    required this.deleteFunction, 
    required this.onUpdate,
    required Preference preference, 
    required Set<University> universities
  }) : _preference = preference, _universityList = universities;

  @override
  State<PreferenceCard> createState() => _PreferenceCardState();
}

/// State class for PreferenceCard to handle the internal logic
/// and UI updates when the user interacts with the card.
class _PreferenceCardState extends State<PreferenceCard> {
  /* variable to express a possible change in the UI mode */
  bool _isEditing = false; // variable to display if edit mode is enabled
  bool _changesHappened = false; // variable to display if any changes in edit mode have been made

  /* local copy of universities — this is what drives the UI rebuild */
  late Set<University> _localUniversities;

  @override
  void initState() {
    super.initState();
    _localUniversities = Set.from(widget._preference.universities);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.star, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${widget._preference.ID} - ${widget._preference.tolcType.name}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    /* If editing is finished and changes happened, save to DB */
                    if (_isEditing && _changesHappened) {
                      await _updatePreference(widget._preference);
                      widget.onUpdate(); // Notify parent page to refresh data
                    }
                    setState(() { _isEditing = !_isEditing; });
                  },
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () async {
                      await widget.deleteFunction(widget._preference);
                      widget.onUpdate(); // Refresh list after deletion
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: !_isEditing
                    ? ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.school),
                        title: const Text("Università selezionate"),
                        subtitle: Text(
                          _localUniversities.isEmpty 
                            ? "Nessuna università"
                            : _localUniversities.map((e) => "• ${e.name}").join(" "),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Università", style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: [
                              /* Display existing universities as removable chips */
                              ..._localUniversities.map((uni) {
                                return InputChip(
                                  label: Text(uni.name),
                                  onDeleted: () {
                                    setState(() {
                                      _localUniversities.remove(uni);
                                      widget._preference.universities.remove(uni);
                                      _changesHappened = true;
                                    });
                                  },
                                );
                              }).toList(),
                              /* Button to trigger the add university dialog */
                              ActionChip(
                                avatar: const Icon(Icons.add, size: 18),
                                label: const Text("Aggiungi"),
                                onPressed: () => _showAddUniversityDialog(context),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                ),
                /* TOLC Type Indicators */
                IntrinsicWidth(
                  child: Column(
                    children: [
                      _buildTolcIndicator("TOLC@uni", widget._preference.TOLCuni),
                      _buildTolcIndicator("TOLC@casa", widget._preference.TOLCcasa),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Helper widget to build the TOLC mode indicators
  Widget _buildTolcIndicator(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? Icons.check_circle : Icons.cancel, 
               color: active ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// Function to show a dialog for adding a new university name
  void _showAddUniversityDialog(BuildContext context) {
    String newUniName = "";

    void addUniversity(String value, NavigatorState navigator) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        navigator.pop(); // Close dialog first
        final newUni = University(trimmed);
        /* Update both the local state (triggers rebuild) and the preference object (for DB save) */
        setState(() {
          _localUniversities.add(newUni);
          widget._preference.universities.add(newUni);
          _changesHappened = true;
        });
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        return AlertDialog(
          title: const Text("Aggiungi Università"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Nome università"),
            onChanged: (value) => newUniName = value,
            // Handle "Enter" key on keyboard
            onSubmitted: (value) => addUniversity(value, navigator),
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () => addUniversity(newUniName, navigator),
              child: const Text("Aggiungi"),
            ),
          ],
        );
      },
    );
  }

  /// Function to update an existing preference 
  /// during the editing mode 
  /// using the connection with the database
  Future<void> _updatePreference(Preference preference) async {
    /* create connection with the database */
    DatabaseService database = DatabaseService.instance;
    
    try {
      await database.initialize();
      await database.updatePreference(preference); // update the preference
      _changesHappened = false; // reset the change tracker after successful save
    } catch (e) {
      logger.e("Error while updating the preference: $e");
    } finally {
      await database.close(); // close the database
    }
  }
}