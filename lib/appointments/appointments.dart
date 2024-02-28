import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_list.dart';
import 'appointments_entry.dart';
import 'appointments_db_worker.dart';
import 'appointments_model.dart' show AppointmentsModel, appointmentsModel;

class Appointments extends StatelessWidget {
  Appointments({super.key}) {appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);}

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [const AppointmentsList(), AppointmentsEntry()],
          );
        }
      )
    );
  }
}