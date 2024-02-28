import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_list.dart';
import 'contacts_entry.dart';
import 'contacts_db_worker.dart';
import 'contacts_model.dart' show ContactsModel, contactsModel;

class Contacts extends StatelessWidget{
  Contacts({super.key}) {contactsModel.loadData("contacts", ContactsDBWorker.db);}

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [const ContactsList(), ContactsEntry()]
          );
        }
      )
    );
  }
}