/// Class which represents the university searched
/// by the user, with the full name or even part of it
class University{
  /* define attributes */
  String name;

  /// Constructor method for the University
  University(this.name);

  /// Converter to map object for sql requests
  Map<String, dynamic> toMap() => {'name':name};

  /// Converter from Map Object to University object
  factory University.fromMap(Map<String, dynamic> map) => University(map['name']);

  /// Override of equal method for the same name
  @override
  bool operator ==(Object other){
    return other is University && other.name.toLowerCase() == name.toLowerCase();
  }

  /// Override of hash method
  @override
  int get hashCode => name.hashCode;
}