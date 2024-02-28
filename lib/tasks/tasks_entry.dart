import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart' as utils;
import 'tasks_db_worker.dart';
import 'tasks_model.dart' show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();
  final TextEditingController _dueDateEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({super.key}) {
    _descriptionEditingController.addListener(() {tasksModel.entityBeingEdited.description = _descriptionEditingController.text;});
    _dueDateEditingController.addListener(() {tasksModel.entityBeingEdited.dueDate = _dueDateEditingController.text;});
  }

  void _save(BuildContext inContext, TasksModel inModel) async {
    if(!_formKey.currentState!.validate()) return;

    if(inModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("tasks", TasksDBWorker.db);

    inModel.setStackIndex(0);

    if(!inContext.mounted) return;
    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Tarefa salva"),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(tasksModel.entityBeingEdited != null) {
      if(tasksModel.entityBeingEdited.description != null) _descriptionEditingController.text = tasksModel.entityBeingEdited.description;
      if(tasksModel.entityBeingEdited.dueDate != null) _dueDateEditingController.text = tasksModel.entityBeingEdited.dueDate;
    }

    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    }
                  ),

                  const Spacer(),

                  TextButton(
                    child: const Text("Salvar"),
                    onPressed: () {_save(inContext, tasksModel);}
                  )
                ]
              )
            ),

            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: "Conteúdo"),
                      controller: _descriptionEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Insira um conteúdo";

                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text("Definir Data"),
                    subtitle: Text(tasksModel.chosenDate == null ? "" : tasksModel.chosenDate!),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(inContext, tasksModel, tasksModel.entityBeingEdited.dueDate);
                        if(chosenDate != null) tasksModel.entityBeingEdited.dueDate = chosenDate;
                      }
                    )
                  )
                ]
              )
            )
          );
        }
      )
    );
  }
}