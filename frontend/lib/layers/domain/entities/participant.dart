class Participant {

  Participant({
    required this.id,
    required this.display,
    this.publisher = false,
    this.talking = false,});

  int id;
  String display;
  bool publisher;
  bool talking;

}