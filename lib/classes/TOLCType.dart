/// Enumerator that defines the different types of TOLC tests, 
/// with the link to be reached in order to check possible dates
enum TOLCType {
  /* define the list of TOLCTypes */
  engineering("TOLC-I", "https://testcisia.it/calendario.php?tolc=ingegneria"),
  economics("TOLC-E", "https://testcisia.it/calendario.php?tolc=economia"),
  science("TOLC-S", "https://testcisia.it/calendario.php?tolc=scienze"),
  pharmaceutical("TOLC-F", "https://testcisia.it/calendario.php?tolc=farmacia"),
  humanistics("TOLC-U", "https://testcisia.it/calendario.php?tolc=umanistica"),
  biology("TOLC-B", "https://testcisia.it/calendario.php?tolc=biologia"),
  agricolture("TOLC-AV", "https://testcisia.it/calendario.php?tolc=agraria"),
  psychology("TOLC-PSI", "https://testcisia.it/calendario.php?tolc=psicologia"),
  political_science("TOLC-PSP", "https://testcisia.it/calendario.php?tolc=scienze_politiche"),
  professionalising("TOLC-LP", "https://testcisia.it/calendario.php?tolc=lauree_professionalizzanti"),
  information_engineering("CEnT-S", "https://testcisia.it/calendario.php?tolc=cents&lingua=inglese");

  /* define attributes of the enumerator */
  final String name;
  final String link;

  /* define constructor of the TOLC Type
  enumerator */
  const TOLCType(this.name, this.link);
}