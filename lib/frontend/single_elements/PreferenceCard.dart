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

  /// Constructor for the PreferenceCard.
  /// Note: Variables that change (state) are moved to the _State class.
  const PreferenceCard({super.key, required this.deleteFunction, 
  required Preference preference, required Set<University> universities}) 
      : _preference = preference, _universityList = universities;

  @override
  State<PreferenceCard> createState() => _PreferenceCardState();
}

/// State class for PreferenceCard to handle the internal logic
/// and UI updates when the user interacts with the card.
class _PreferenceCardState extends State<PreferenceCard> {
  /* variable to express a possible change in the UI mode */
  bool _isEditing = false; // variable to display if edit mode is enabled
  bool _changesHappened = false; // variable to display if any changes in edit mode have been made
  Set<University> _universitySuggestions = {};

  @override
  void initState(){
    super.initState();
    _universitySuggestions = widget._universityList;
  }

  /// Function to return the single element of the card
  /// with both the visual and editable part
  @override
  Widget build(BuildContext context){
    /* We use the 'create' logic directly inside the build method 
       as it is the standard practice for Flutter Widgets */
    return Card(
      /* light background color took from the theme */
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // more rounded angles for personal look
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
                /* distinctive icon for preference */
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.star, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                
                /* title of the preference - Wrapped in Expanded to prevent overflow */
                Expanded(
                  child: Text(
                    "${widget._preference.ID} - ${widget._preference.tolcType.name}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                
                /* section of the buttons for editing and confirming changes */
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    /* if changes have reported 
                    save the preference into the database */
                    if(_changesHappened){
                      await _updatePreference(widget._preference);
                    }
                    
                    /* Notifies the framework that the internal state has changed */
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
                
                /* optional delete button that appears only during editing */
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () async {
                      await widget.deleteFunction(widget._preference);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                /* selected universities */
                /* if it's in view mode visualize only the
                first  */
                if(!_isEditing)
                  ListTile(
                    leading: Icon(Icons.school),
                    title: Text("Università selezionate..."),
                    subtitle: Text(
                      /* Logic to create a bulleted list string:
                        1. Take only the first 3 elements to keep the UI clean.
                        2. Join them with a bullet separator.
                        3. If there are more than 3 items, append '...' manually.
                      */
                      "${widget._preference.universities.take(3).map((e) => "• $e").join(" ")}${widget._preference.universities.length > 3 ? "  ..." : ""}",
                      
                      /* Standard Material handling for long text:
                        - maxLines: 1 ensures the card height remains consistent.
                        - ellipsis: adds '...' if a single item name is too long for the screen.
                      */
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                /* add the list of inputs for of the universities */
                else
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Università selezionate",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0, // Gap between adjacent chips
                            runSpacing: 4.0, // Gap between lines
                            children: [
                              // 1. Map existing universities to Editable InputChips
                              ...widget._preference.universities.toList().asMap().entries.map((entry) {
                                /* define the value and the index */
                                int index = entry.key;
                                University uni = entry.value;

                                return InputChip(
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                  label: IntrinsicWidth(
                                    child: TextField(
                                      // 'uni.name' if it's an object, just 'uni' if it's a string
                                      controller: TextEditingController(text: uni.name)..selection = TextSelection.fromPosition(TextPosition(offset: uni.name.length)),
                                      autofocus: false,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        border: InputBorder.none,
                                        hintText: "Nome università",
                                      ),
                                      onSubmitted: (newValue) {
                                        setState(() {
                                          /* if the value is empty you
                                          need to remove the university from the preference */
                                          if(newValue.trim().isEmpty){
                                            widget._preference.removeUniversitbyIndex(index);
                                          }else{
                                            uni.name = newValue.trim();
                                            _universitySuggestions.add(University(newValue.trim()));
                                          }
                                          _changesHappened = true;
                                        });
                                      },
                                    ),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      widget._preference.universities.remove(uni);
                                      _changesHappened = true;
                                    });
                                  },
                                  deleteIcon: const Icon(Icons.cancel, size: 18),
                                );
                              }),

                              // 2. The "Add" button
                              ActionChip(
                                avatar: const Icon(Icons.add, size: 18),
                                label: const Text("Add university"),
                                onPressed: () => _showAddUniversityDialog(context),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                ,
                /* section to specify whether 
                TOLC@uni and TOLC@casa have been enabled  */
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: widget._preference.TOLCuni ? 
                        Icon(Icons.check, color: Colors.green,) :
                        Icon(Icons.close, color: Colors.red),
                      title: Text("TOLC@uni")
                    ),
                    ListTile(
                      leading: widget._preference.TOLCcasa ? 
                        Icon(Icons.check, color: Colors.green,) :
                        Icon(Icons.close, color: Colors.red),
                      title: Text("TOLC@casa")
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Function to add continuosly an input dialog
  /// to add every single time a new univesity
  /// in the editing mode
  void _showAddUniversityDialog(BuildContext context) {
    String newUni = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add University"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter university name",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            newUni = value;
            _changesHappened = true;
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                widget._preference.universities.add(University(value.trim()));
                
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newUni.trim().isNotEmpty) {
                setState(() {
                  widget._preference.universities.add(University(newUni.trim()));
                  _universitySuggestions.add(University(newUni.trim()));
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  /// Function to update an existing preference 
  /// during the editing mode 
  /// using the connection with the database
  Future<void> _updatePreference(Preference preference) async{
    /* create connection with the database */
    DatabaseService database = DatabaseService.instance;
    
    try{
      await database.initialize();
      await database.updatePreference(preference); // update the preference
    }catch(e){
      logger.e("Error while updating the preference: $e");
    }finally{
      await database.close(); // close the database
    }

    _changesHappened = false; // update the boolean at the end of the change
  }
}