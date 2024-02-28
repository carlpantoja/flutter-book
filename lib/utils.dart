import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_model.dart';

Directory? docsDir;

Future selectDate(BuildContext inContext, BaseModel inModel, String? inDateString) async {
  DateTime initialDate = DateTime.now();

  if(inDateString != null) {
    List dateParts = inDateString.split(",");

    initialDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
  }

  DateTime? picker = await showDatePicker(
    context: inContext,
    initialDate: initialDate,
    firstDate: DateTime.now(),
    lastDate: DateTime(2077)
  );

  if(picker != null) {
    inModel.setChosenDate(DateFormat.yMMMMd("en_US").format(picker.toLocal()));

    return "${picker.year},${picker.month},${picker.day}";
  }
}

