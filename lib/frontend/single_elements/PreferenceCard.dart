import 'package:flutter/material.dart';
import '../../classes/Preference.dart';

/// Class to display the preference configured
/// which could be changed during the configuration.
/// 
/// This widget is a StatefulWidget to manage the editing state
/// of the specific preference card.
class PreferenceCard extends StatefulWidget {
  /* define attributes for preference card */
  final Preference _preference;

  /// Constructor for the PreferenceCard.
  /// Note: Variables that change (state) are moved to the _State class.
  const PreferenceCard({super.key, required Preference preference}) 
      : _preference = preference;

  @override
  State<PreferenceCard> createState() => _PreferenceCardState();
}

/// State class for PreferenceCard to handle the internal logic
/// and UI updates when the user interacts with the card.
class _PreferenceCardState extends State<PreferenceCard> {
  /* variable to express a possible change in the UI mode */
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(_isEditing ? Icons.check : Icons.edit_note),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
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
                    onPressed: () {
                      // Logic to delete the preference could be placed here
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
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
                ),
                
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
}