import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  Future _deleteNote(BuildContext inContext, Note inNote) {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text("Apagar nota"),
          content: Text("Realmente desaja excluir ${inNote.title}?", style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: const Text("Apagar"),
              onPressed: () async {
                await NotesDBWorker.db.delete(inNote.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inAlertContext).pop();
                
                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Nota excluida!")
                  )
                );

                notesModel.loadData("notes", NotesDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget? inChild, NotesModel inModel) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black54,
              title: const Text("Notas", style: TextStyle(color: Colors.white))
            ),

            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                notesModel.setColor("");
                notesModel.setStackIndex(1);
              }
            ),

            body: ListView.builder(
              itemCount: notesModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Note note = notesModel.entityList[inIndex];
                Color color = Colors.white;
                switch(note.color) {
                  case "red": color = Colors.red; break;
                  case "green": color = Colors.green; break;
                  case "blue": color = Colors.blue; break;
                  case "yellow": color = Colors.yellow; break;
                  case "grey": color = Colors.grey; break;
                  case "purple": color = Colors.purple; break;
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteNote(inContext, note),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: "Apagar"
                        )
                      ]
                    ),
                    
                    child: Card(
                      elevation: 8,
                      color: color,
                      child: ListTile(
                        title: Text("${note.title}", style: const TextStyle(color: Colors.white, fontSize: 20)),
                        subtitle: Text("${note.content}", style: const TextStyle(color: Colors.white, fontSize: 18)),
                        onTap: () async {
                          notesModel.entityBeingEdited = await NotesDBWorker.db.get(note.id!);
                          notesModel.setColor(notesModel.entityBeingEdited.color);
                          notesModel.setStackIndex(1);
                        }
                      )
                    )
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