import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'logger_utils.dart';
import 'notification_helper.dart';

import '../classes/Preference.dart';
import '../classes/University.dart';
import '../classes/Result.dart';

/// Function to scrape the html of the page and get the elements
/// containing the TOLC information
Future<List<dom.Element>> scrapeHtml(Preference preference) async{
  final url = Uri.parse(preference.tolcType.link); // establish the link
  /* try three times to get the elements */
  for(int i=0;i<3;i++){
    try{
      final response = await http.get(url);
      if(response.statusCode == 200){
        /* analize html and get the document */
        var document = html_parser.parse(response.body);
        return document.querySelectorAll('.tablesorter tbody');
      }else{
        /* if the response is not OK 
        continue with the cycle to try it again */
        logger.w('Failed to load the page ${preference.tolcType.link} with status code ${response.statusCode}');
        continue;
      }
    }catch(e){
      logger.e('Error occurred while scraping HTML for ${preference.tolcType.link}: $e');
      continue;
    }
  }

  return []; // return null if nothing has been found in the website
}

/// Function to transform the html elements 
/// into a list of results to be evaluated later
List<Result> generateResults(Preference preference, List<dom.Element> elements){
  List<Result> results = []; // define the list of variables
  const String DATEFORMAT = "dd/MM/yyyy"; // define format of the date to be parsed

  for(dom.Element row in elements){
    List<dom.Element> columns = row.querySelectorAll("td"); // get every single TD from the table
    /* convert the string in the columns to a result
    to be evaluated later */
    results.add(Result(preference.tolcType, University(columns[1].text), columns[3].text, int.parse(columns[5].text), 
                DateFormat(DATEFORMAT).parse(columns[4].text), DateFormat(DATEFORMAT).parse(columns[7].text), columns[0].text));
  }

  return results;
}

/// Function to filter the result based on the preference
/// so as to return the results wanted. 
/// The function also tries to avoid duplicates with the previous results
List<Result> filterResults(Preference preference, List<Result> totalResults, List<Result> previousResults){
  /* define variables for the starting execution */
  bool check; // to control if the result is valid till the end

  /* start the cycle to control the different attributes */
  for(int i=0;i<totalResults.length; i++){
    check = true; // initialize every single result as valid

    /* first control if the result found from the page is not present 
    among the previous results gathered */
    if(previousResults.contains(totalResults[i]))
      check = false;
    /* then control if the mode of the tolc is the one selected */
    if((totalResults[i].mode == "TOLC@UNI" && !preference.TOLCuni) || (totalResults[i].mode == "TOLC@CASA" && !preference.TOLCcasa))
      check = false;
    /* then check if the date of the inscription is after the current one,
    so as to avoid past TOLCs */
    else if(totalResults[i].endSubscription.compareTo(DateTime.now()) < 0)
      check = false;
    /* then control if the available places are more than 0,
    so as to avoid save TOLC when there is no room for another one */
    else if(totalResults[i].availablePlaces <= 0)
      check = false;
    /* then control if the name or part of it is contained 
    into the full name of the university */
    else if(!preference.isThereUniverisity(totalResults[i].university))
      check = false;

    /* if the control is false the item
    has to be removed */
    if(!check)
      totalResults.removeAt(i);
  }

  return totalResults;
}

/// Main function of the service, which is called
/// to execute following a certain frequency. 
/// It returns a boolean to indicate if the execution has been successful or not
Future<bool> TOLC_finder_main() async {
  /* variable and lists initialization to
  avoid possible null errors due to exceptions */
  List<Preference> preferences = [];
  List<Result> previousResults = [];
  
  /* first get the database and get the preferences */
  DatabaseService database = DatabaseService.instance;
  try{
    preferences = await database.getPreferences();
  }catch(e){
    logger.e("Error occured while searching preferences: ${e}");
    database.close();
    return false;
  }

  /* get the results from the database */
  try{
    previousResults = await database.getResults();
  }catch(e){
    logger.e("Error occured while searching previous results: ${e}");
    database.close();
    return false;
  }

  /* instantiate notification object */
  NotificationsService notification = NotificationsService();
  notification.init(); // initialize the notification service
  
  /* start a cycle to see all the preferences
  and find possible matches */
  for(Preference currentPreference in preferences){
    List<Result> currentResults = generateResults(currentPreference, await scrapeHtml(currentPreference));
    if(currentResults.isEmpty)
      continue; // if no result has been found continue with the next
    
    List<Result> finalResults = filterResults(currentPreference, currentResults, previousResults);

    /* if the final result has produced some results
    put a notification for every message */
    for(Result singleResult in finalResults){
      /* show the notification for the new result found */
      await notification.showNotification(
        title: "Nuovo ${singleResult.tolcType.name} disponibile!",
        body: "${singleResult.university.name} il ${DateFormat('dd/MM/yyyy').format(singleResult.assessmentDate)}"
      );

      /* try to save the result found for a maximum 
      of 3 times */
      for(int i=0;i<3;i++){
        try{
          database.saveResult(singleResult);
          break;
        }catch(e){
          /* send a warning if the result has not been saved */
          logger.w("Error occured while saving the result ${singleResult.toString()}\nFollowing error reported: ${e}");
        }
      }
    }
  }

  database.close(); // close the database connection
  return true;
}
