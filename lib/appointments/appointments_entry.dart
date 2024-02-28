import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils.dart' as utils;
import 'appointments_db_worker.dart';
import 'appointments_model.dart' show AppointmentsModel, appointmentsModel;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry({super.key}) {
    _titleEditingController.addListener(() {appointmentsModel.entityBeingEdited.title = _titleEditingController.text;});
    _descriptionEditingController.addListener(() {appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;});
  }

  void _save(BuildContext inContext, AppointmentsModel inModel) async {
    if(!_formKey.currentState!.validate()) return;

    if(inModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);

    inModel.setStackIndex(0);

    if(!inContext.mounted) return;
    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Compromisso salvo")
      )
    );
  }

  Future _selectTime(BuildContext inContext) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if(appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");

      initialTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    TimeOfDay? picker = await showTimePicker(context: inContext, initialTime: initialTime);

    if(!inContext.mounted) return;

    if(picker != null) {
      appointmentsModel.entityBeingEdited.apptTime = "${picker.hour},${picker.minute}";
      appointmentsModel.setApptTime(picker.format(inContext));
    }
  }

  @override
  Widget build(BuildContext context) {
    if(appointmentsModel.entityBeingEdited != null){
      if(appointmentsModel.entityBeingEdited.title != null) _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
      if(appointmentsModel.entityBeingEdited.description != null) _descriptionEditingController.text = appointmentsModel.entityBeingEdited.description;
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
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
                    onPressed: () {_save(inContext, appointmentsModel);}
                  )
                ]
              )
            ),

            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.subject),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: "Título"),
                      controller: _titleEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Insira um título";

                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.description),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: "Descrição"),
                      controller: _descriptionEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text("Data"),
                    subtitle: Text(appointmentsModel.chosenDate == null ? "" : appointmentsModel.chosenDate!),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(inContext, appointmentsModel, appointmentsModel.entityBeingEdited.apptDate);
                        if(chosenDate != null) appointmentsModel.entityBeingEdited.apptDate = chosenDate;
                      }
                    )
                  ),

                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text("Hora"),
                    subtitle: Text(appointmentsModel.apptTime == null ? "" : appointmentsModel.apptTime!),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectTime(inContext)
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