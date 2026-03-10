import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'database_helper.dart';
import 'logger_utils.dart';

import '../classes/Preference.dart';
import '../classes/TOLCType.dart';
import '../classes/University.dart';
import '../classes/Result.dart';

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