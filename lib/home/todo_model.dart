class TodoModel {
  String id;
  String title;
  String description;
  DateTime date;
  int priority;
  bool isDone;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    this.isDone = false,
  });
}
