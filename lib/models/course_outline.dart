class Course {
  final String? id;
  final String title;
  final List<Week> weeks;

  Course({this.id = '', required this.title, required this.weeks});
}

class Week {
  final String title;
  final List<String> topics;

  Week({required this.title, required this.topics});
}
