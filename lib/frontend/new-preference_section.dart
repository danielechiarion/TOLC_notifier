import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../classes/University.dart';
import '../classes/Preference.dart';
import '../classes/TOLCType.dart';
import 'single_elements/DynamicInputManager.dart';
import 'single_elements/Toast.dart';

/// Class to manage the addition
/// of a new preference controlling the required data
/// and returning the result to the page
class NewPreferenceSection extends StatelessWidget{
  /* define attributes of the class */
  final Set<University> _universitySuggestions;

  /// Constructor of the class extending the 
  /// stateless widget
  const NewPreferenceSection({super.key, required Set<University> universities}):
  _universitySuggestions = universities;

  @override
  Widget build(BuildContext context){
    /* define initial value of the variables
    for the form to fill */
    final formKey = GlobalKey<FormBuilderState>();

    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: AppBar(title: const Text("Aggiungi preferenza")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: formKey,
            child: Column(
              children: [
                /* dropdown for the selection of the TOLC type */
                FormBuilderDropdown(
                  name: 'tolc_type', 
                  decoration: const InputDecoration(
                    labelText: 'Seleziona un TOLC',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  initialValue: TOLCType.engineering,
                  items: TOLCType.values.map((singleTolc) => 
                          DropdownMenuItem(value:singleTolc, 
                                            child: Text(singleTolc.name, style: const TextStyle(color: Colors.black)))
                        ).toList()
                ),
                const SizedBox(height: 10),
                /* switch to select which mode of TOLC
                to enable on the preference research */
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FormBuilderSwitch(
                        name: 'tolcUni_enabled', 
                        title: const Text("TOLC@uni", style: TextStyle(color: Colors.black)),
                        initialValue: true,
                        // Avvicina lo switch al testo
                        controlAffinity: ListTileControlAffinity.leading,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    ),
                    Expanded(
                      child: FormBuilderSwitch(
                        name: 'tolcCasa_enabled', 
                        title: const Text("TOLC@casa", style: TextStyle(color: Colors.black)),
                        initialValue: false,
                        // Avvicina lo switch al testo
                        controlAffinity: ListTileControlAffinity.leading,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    )
                  ],
                ),
                /* dynamic input of universities */
                DynamicInputManager(fieldPrefix: 'dynamic_input_', universitySuggestions: _universitySuggestions,),
                const Divider(height: 32.0,),
                /* buttons for the actions of the section */
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () => _sendForm(context, formKey), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Aggiungi nuova preferenza"),
                      ),
                      const SizedBox(height: 12.0,), //space between buttons
                      ElevatedButton(
                        onPressed: () => _cancelForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Annulla preferenza"),
                      ),
                    ]
                  )
                )
              ],
            )
          ),
        ),
      ),
    );
  }

  /* function to manage the control and the sent of
  the data of the form */
  void _sendForm(BuildContext context, GlobalKey<FormBuilderState> formKey){
    /* save the state of the form and control if it's accessible */
    formKey.currentState?.save();
    if(!(formKey.currentState?.validate() ?? false)){
      AppToast.show(context, "Non è stato possibile validare il form", ToastType.fatal);
      return;
    }
    Map<String, dynamic> form = formKey.currentState!.value;

    /* first control if all the values are correct */
    /* the first control wants to control whether
    one of the two modes of TOLC test (TOLC@uni or TOLC@casa)
    have been selected. Otherwise it won't make sense. */
    if(!form['tolcUni_enabled'] && !form['tolcCasa_enabled']){
      AppToast.show(context, "Scegli almeno una modalità di TOLC da attivare", ToastType.error);
      return;
    }
    /* the second one is to control if the list of univerisities
    has one element at least, otherwise it's not possible to
    make researches in the future */
    final universityList = form.entries
        .where((entry) => entry.key.startsWith('dynamic_input_'))
        .map((entry) => University(entry.value.toString()))
        .where((value) => value.name.trim().isNotEmpty)
        .toList();
    if(universityList.isEmpty){
      AppToast.show(context, "Seleziona almeno un'univeristà in cui effettuare la ricerca", ToastType.error);
      return;
    }

    /* create the preference and add it to the navigator 
    to come back */
    Preference preference = Preference(form['tolc_type'], 
      form['tolcCasa_enabled'], form['tolcUni_enabled'], 
      universities: Set.from(universityList));
    Navigator.pop(context, preference);
  }

  /* function to cancel the preference 
  and come back to the previous page */
  void _cancelForm(BuildContext context){
    /* the only thing to do in this function so far
    is send back a null value as the page understands
    there is no value returned from the form */
    Navigator.pop(context, null);
  }
}