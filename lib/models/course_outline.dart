class Course {
  final String title;
  final List<Week> weeks;

  Course({required this.title, required this.weeks});
}

class Week {
  final String title;
  final List<String> topics;

  Week({required this.title, required this.topics});
}
