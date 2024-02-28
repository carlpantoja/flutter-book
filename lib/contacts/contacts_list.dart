import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import '../utils.dart' as utils;
import 'contacts_db_worker.dart';
import 'contacts_model.dart' show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  Future _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text("Apagar contato"),
          content: Text("Realmente deseja excluir ${inContact.name}?", style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: const Text("Apagar"),
              onPressed: () async {
                File avatarFile = File("${utils.docsDir!.path}/${inContact.id.toString()}");

                if(avatarFile.existsSync()) avatarFile.deleteSync();

                await ContactsDBWorker.db.delete(inContact.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Contato excluido")
                  )
                );

                contactsModel.loadData("contacts", ContactsDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black54,
              title: const Text("Contatos", style: TextStyle(color: Colors.white))
            ),
            
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                File avatarFile = File("${utils.docsDir!.path}/avatar");

                if(avatarFile.existsSync()) avatarFile.deleteSync();

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate("");
                contactsModel.setStackIndex(1);
              }
            ),
            
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Contact contact = contactsModel.entityList[inIndex];
                File avatarFile = File("${utils.docsDir!.path}/${contact.id.toString()}");
                bool avatarFileExists = avatarFile.existsSync();

                return Column(
                  children: [
                    
                    Slidable(
                      startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteContact(inContext, contact),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: "Apagar"
                        )
                      ]
                    ),

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                        child: avatarFileExists ? null : Text(contact.name!.substring(0, 1).toUpperCase())
                      ),
                      
                      title: Text("${contact.name}"),
                      subtitle: contact.phone == null ? null : Text("${contact.phone}"),
                      onTap: () async {
                        File avatarFile = File("${utils.docsDir!.path}/avatar");

                        if(avatarFile.existsSync()) avatarFile.deleteSync();

                        contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id!);

                        if(contactsModel.entityBeingEdited.birthday == null) {
                          contactsModel.setChosenDate("");
                        } else {
                          List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                          DateTime birthday = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                          contactsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(birthday.toLocal()));
                        }

                        contactsModel.setStackIndex(1);
                      }
                    )
                    )
                  ],
                );
              }
            )
          );
        }
      )
    );
  }
}