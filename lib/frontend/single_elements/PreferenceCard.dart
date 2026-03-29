import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../classes/Preference.dart';
import '../../classes/University.dart';

import '../../services/database_helper.dart';
import '../../services/logger_utils.dart';

import 'DynamicInputManager.dart';
import 'Toast.dart';

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

  /* local copy of universities — this is what drives the UI rebuild */
  late Set<University> _localUniversities;

  /* define the form builder 
  key for the editing mode */
  final formKey = GlobalKey<FormBuilderState>();

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
                    if(_isEditing){
                      bool hasChanged = false;

                      /* get the list of values from the form and compare them
                      with the list already present in the preference */
                      /* save the state of the form and control if it's accessible */
                      formKey.currentState?.save();
                      if(!(formKey.currentState?.validate() ?? false)){
                        AppToast.show(context, "Non è stato possibile validare il form", ToastType.fatal);
                        return;
                      }
                      Map<String, dynamic> form = formKey.currentState!.value;
                      /* then ge the list of universities and control if it's 
                      empty. In that case launch a toast */
                      final universityList = form.entries
                          .where((entry) => entry.key.startsWith('dynamic_input_'))
                          .map((entry) => University(entry.value.toString()))
                          .where((value) => value.name.trim().isNotEmpty)
                          .toSet();
                      if(universityList.isEmpty){
                        AppToast.show(context, "Seleziona almeno un'univeristà in cui effettuare la ricerca", ToastType.error);
                        return;
                      }

                      /* then establishing is changes have been made
                      on the preference, so as to save them in the database */
                      hasChanged = universityList.length != widget._preference.universities.length ||
                        !widget._preference.universities.containsAll(universityList);
                      
                      if(hasChanged){
                        widget._preference.updateUniversities(universityList);
                        widget.onUpdate(); // Notify parent page to refresh data

                        _updatePreference(widget._preference);

                        /* set the new local list of 
                        universities to display them in the card */
                        setState(() {
                          _localUniversities = Set.from(universityList);
                        });
                      }
                    }

                    /* reset some variables */
                    setState(() {
                      _isEditing = !_isEditing; 
                    });
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
                              FormBuilder(
                                key: formKey,
                                child: DynamicInputManager(
                                  fieldPrefix: 'dynamic_input_',
                                  initialValues: widget._preference.universities, 
                                  universitySuggestions: widget._universityList,
                                )
                              )
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

  /// Function to update an existing preference 
  /// during the editing mode 
  /// using the connection with the database
  Future<void> _updatePreference(Preference preference) async {
    /* create connection with the database */
    DatabaseService database = DatabaseService.instance;
    
    try {
      await database.initialize();
      await database.updatePreference(preference); // update the preference
    } catch (e) {
      logger.e("Error while updating the preference: $e");
    } finally {
      await database.close(); // close the database
    }
  }
}