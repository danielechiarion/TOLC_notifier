import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../classes/Result.dart';

class ResultCard {
  /* attributes definition */
  bool _new;
  Result _result;

  /// Constructor the Result card
  /// If the boolean is not specified, it means that card
  /// doesn't have to be displayed as a new one
  ResultCard(this._result, {bool ?newResult}) 
  : _new = newResult ?? false;

  /* function to get the starting content of the
  result which could be modified later using badges,
  or other widgets available */
  Widget create(BuildContext context){
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(15))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* title of the card */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                        "${_result.tolcType.name} - ${_result.university.name}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,),
                        softWrap: true,
                        overflow: TextOverflow.visible 
                  ),
                ),
                if(_new)
                  const Badge(label: Text("Nuovo"))
              ]
            ),
            const Divider(), // separator
            ListTile(
              leading: Icon(Icons.place),
              title: Text(
                "Luogo e data",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("${_result.site} - ${DateFormat("dd/MM/yyyy").format(_result.assessmentDate)}")
            ),
            /* number of places available */
            ListTile(
              leading: Icon(Icons.people),
              title: Text(
                "Posti disponibili",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("${_result.availablePlaces}")
            ),
            /* end term for subscription */
            ListTile(
              leading: Icon(Icons.calendar_month_outlined),
              title: Text(
                "Scadenza iscrizione",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(DateFormat("dd/MM/yyyy").format(_result.endSubscription))
            )
          ],
        )
      )
    );
  }
}