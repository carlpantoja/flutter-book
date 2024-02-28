import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image_picker/image_picker.dart';
import '../utils.dart' as utils;
import 'contacts_db_worker.dart';
import 'contacts_model.dart' show ContactsModel, contactsModel;

class ContactsEntry extends StatelessWidget {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry({super.key}) {
    _nameEditingController.addListener(() {contactsModel.entityBeingEdited.name = _nameEditingController.text;});
    _phoneEditingController.addListener(() {contactsModel.entityBeingEdited.phone = _phoneEditingController.text;});
    _emailEditingController.addListener(() {contactsModel.entityBeingEdited.email = _emailEditingController.text;});
  }

  void _save(BuildContext inContext, ContactsModel inModel) async {
    dynamic id;
    
    if(!_formKey.currentState!.validate()) return;

    if(inModel.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    File avatarFile = File("${utils.docsDir!.path}/avatar");

    if(avatarFile.existsSync()) avatarFile.renameSync("${utils.docsDir!.path}/${id.toString()}");

    contactsModel.loadData("contacts", ContactsDBWorker.db);

    inModel.setStackIndex(0);

    if(!inContext.mounted) return;
    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Contato salvo")
      )
    );
  }

  Future _selectAvatar(BuildContext inContext) {
    return showDialog(
      context: inContext,
      builder: (BuildContext inDialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text("Tirar foto", style: TextStyle(fontSize: 18)),
                  onTap: () async {
                    ImagePicker picker = ImagePicker();
                    XFile? xCameraImage = await picker.pickImage(source: ImageSource.camera);

                    if(xCameraImage != null) {
                      File cameraImage = File(xCameraImage.path);
                      cameraImage.copySync("${utils.docsDir!.path}avatar");

                      contactsModel.triggerRebuild();
                    }

                    if(!inDialogContext.mounted) return;
                    Navigator.of(inDialogContext).pop();
                  }
                ),

                const Padding(padding: EdgeInsets.all(10)),
                
                GestureDetector(
                  child: const Text("Imagem da galeria", style: TextStyle(fontSize: 18)),
                  onTap: () async {
                    ImagePicker picker = ImagePicker();
                    XFile? xGalleryImage = await picker.pickImage(source: ImageSource.gallery);

                    if(xGalleryImage != null) {
                      File galleryImage = File(xGalleryImage.path);
                      galleryImage.copySync("${utils.docsDir!.path}/avatar");

                      contactsModel.triggerRebuild();
                    }

                    if(!inDialogContext.mounted) return;
                    Navigator.of(inDialogContext).pop();
                  }
                )
              ]
            )
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if(contactsModel.entityBeingEdited != null){
      if(contactsModel.entityBeingEdited.name != null) _nameEditingController.text = contactsModel.entityBeingEdited.name;
      if(contactsModel.entityBeingEdited.phone != null) _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
      if(contactsModel.entityBeingEdited.email != null) _emailEditingController.text = contactsModel.entityBeingEdited.email;
    }

    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          File avatarFile = File("${utils.docsDir!.path}/avatar");
          if(avatarFile.existsSync() == false) {
            if(inModel.entityBeingEdited != null && inModel.entityBeingEdited.id != null) avatarFile = File("${utils.docsDir!.path}/${inModel.entityBeingEdited.id.toString()}");
          }

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () {
                      File avatarFile = File("${utils.docsDir!.path}/avatar");
                      if(avatarFile.existsSync()) avatarFile.deleteSync();

                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    }
                  ),

                  const Spacer(),

                  TextButton(
                    child: const Text("Salvar"),
                    onPressed: () {_save(inContext, contactsModel);}
                  )
                ]
              )
            ),

            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: Center(
                      child: CircleAvatar(
                        backgroundImage: avatarFile.existsSync() ? FileImage(avatarFile) : null,
                        radius: 100,
                        child: avatarFile.existsSync() ? Opacity(
                          opacity: 0,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ElevatedButton(
                              child: const Text(""),
                              onPressed: () => _selectAvatar(inContext)
                            )
                          )
                        ) : IconButton(icon: const Icon(Icons.person, size: 150), color: Colors.black26, onPressed: () => _selectAvatar(inContext))
                      )
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: "Nome"),
                      controller: _nameEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Coloque um nome";

                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: "Telefone"),
                      controller: _phoneEditingController,
                      keyboardType: TextInputType.phone,
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.email),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: "Email"),
                      controller: _emailEditingController,
                      keyboardType: TextInputType.emailAddress
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text("Aniversário"),
                    subtitle: Text(contactsModel.chosenDate == null ? "" : contactsModel.chosenDate!),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(inContext, contactsModel, contactsModel.entityBeingEdited.birthday);
                        if(chosenDate != null) contactsModel.entityBeingEdited.birthday = chosenDate;
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