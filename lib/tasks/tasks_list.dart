import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'tasks_db_worker.dart';
import 'tasks_model.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  Future _deleteTask(BuildContext inContext, Task inTask) {
    return showDialog(
      context: inContext,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text("Apagar Tarefa"),
          content: Text("Realmente deseja excluir ${inTask.description}?", style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: const Text("Apagar"),
              onPressed: () async {
                await TasksDBWorker.db.delete(inTask.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inAlertContext).pop();


                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Tarefa excluida!")
                  )
                );

                tasksModel.loadData("tasks", TasksDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black54,
              title: const Text("Tarefas", style: TextStyle(color: Colors.white))
            ),

            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setChosenDate("");
                tasksModel.setStackIndex(1);
              }
            ),

            body: ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Task task = tasksModel.entityList[inIndex];
                String sDueDate = "";

                if(task.dueDate != null) {
                  List dateParts = task.dueDate!.split(",");
                  DateTime dueDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                  sDueDate = DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                }

                return Slidable(
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _deleteTask(inContext, task),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: "Apagar"
                      )
                    ]
                  ),

                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == "true" ? true : false,
                      onChanged: (inValue) async {
                        task.completed = inValue.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData("tasks", TasksDBWorker.db);
                      }
                    ),
                    
                    title: Text("${task.description}", style: task.completed == "true" ? TextStyle(color: Theme.of(inContext).disabledColor, decoration: TextDecoration.lineThrough, fontSize: 18) : const TextStyle(color: Colors.black, fontSize: 22)),
                    subtitle: task.dueDate == null ? null : Text(sDueDate, style: task.completed == "true" ? TextStyle(color: Theme.of(inContext).disabledColor, decoration: TextDecoration.lineThrough, fontSize: 18) : const TextStyle(color: Colors.black, fontSize: 22)),
                    onTap: () async {
                      if(task.completed == "true") return;

                      tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id!);

                      if(tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate("");
                      } else {
                        tasksModel.setChosenDate(sDueDate);
                      }

                      tasksModel.setStackIndex(1);
                    }
                  )
                );
              }
            )
          );
        }
      )
    );
  }
}