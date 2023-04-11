import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class AutoSchedule {

  List<Task> tasks;
  //event type and period
  static const Map<String, List<String>> activityTypes = {
    'exercise': ['15:00', '21:00'],
    'breakfast': ['06:00', '09:00'],
    'lunch': ['11:00', '14:00'],
    'dinner': ['18:00', '21:00'],
  };
  // check period
  bool isTimeSlotAvailable(DateTime start, DateTime end) {
    for (Task task in tasks) {
      if (task.startTime == null || task.endTime == null) {
        continue;
      }

      DateTime taskStart = DateTime.parse(task.startTime!);
      DateTime taskEnd = DateTime.parse(task.endTime!);

      if ((start.isAfter(taskStart) && start.isBefore(taskEnd)) ||
          (end.isAfter(taskStart) && end.isBefore(taskEnd)) ||
          (start.isBefore(taskStart) && end.isAfter(taskEnd))) {
        return false;
      }
    }
    return true;
  }

  //logic of autoschedule
  void scheduleEvents() {
    for (Task task in tasks) {
      String? eventType = task.type;
      int? duration = task.duration;

      if (duration == null || !activityTypes.containsKey(eventType)) {
        continue;
      }

      List<String> timeRange = activityTypes[eventType]!;
      TimeOfDay startTime = TimeOfDay.fromDateTime(
          DateFormat('HH:mm').parse(timeRange[0]));
      TimeOfDay endTime =
      TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(timeRange[1]));

      DateTime currentDate = DateTime.now();
      DateTime startDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          startTime.hour,
          startTime.minute);
      DateTime endDateTime = DateTime(currentDate.year, currentDate.month,
          currentDate.day, endTime.hour, endTime.minute);

      while (startDateTime.isBefore(endDateTime)) {
        DateTime possibleEndTime =
        startDateTime.add(Duration(minutes: duration));

        if (isTimeSlotAvailable(startDateTime, possibleEndTime)) {
          //set the start time
          task.startTime = startDateTime.toIso8601String();
          task.endTime = possibleEndTime.toIso8601String();
          break;
        }

        //try next period
        startDateTime = startDateTime.add(Duration(minutes: 30));
      }
    }
  }


  AutoSchedule(this.tasks);





}
