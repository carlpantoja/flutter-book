import '../base_model.dart';

class Task {
  int? id;
  String? description;
  String? dueDate;
  String completed = "false";

  @override
  String toString() {return "id=$id, description=$description, dueDate=$dueDate, completed=$completed";}
}

class TasksModel extends BaseModel {}

TasksModel tasksModel = TasksModel();