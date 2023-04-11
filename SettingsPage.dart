import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:fyp_calendar_2/controllers/SettingsController.dart';
import 'package:get/get.dart';

import '../main.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}



class _SettingsPageState extends State<SettingsPage> {
  final SettingsController settingsController = Get.find();
  TimeOfDay? _lunchStartTime;
  TimeOfDay? _lunchEndTime;
  TimeOfDay? _dinnerStartTime;
  TimeOfDay? _dinnerEndTime;


  void _saveSettings() {
    final storage = GetStorage();
    storage.write("lunchStartTime", _stringFromTime(_lunchStartTime!));
    storage.write("lunchEndTime", _stringFromTime(_lunchEndTime!));
    storage.write("dinnerStartTime", _stringFromTime(_dinnerStartTime!));
    storage.write("dinnerEndTime", _stringFromTime(_dinnerEndTime!));

    // Update the values in SettingsController as well
    settingsController.updateLunchStartTime(_lunchStartTime!);
    settingsController.updateLunchEndTime(_lunchEndTime!);
    settingsController.updateDinnerStartTime(_dinnerStartTime!);
    settingsController.updateDinnerEndTime(_dinnerEndTime!);

    // Debug print statements
    print(storage.read("lunchStartTime"));
    print(storage.read("lunchEndTime"));
    print(storage.read("dinnerStartTime"));
    print(storage.read("dinnerEndTime"));

  }

  void main() async {
    await GetStorage.init();
    runApp(MyApp());
  }
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _lunchStartTime = settingsController.lunchStartTime.value;
    _lunchEndTime = settingsController.lunchEndTime.value;
    _dinnerStartTime = settingsController.dinnerStartTime.value;
    _dinnerEndTime = settingsController.dinnerEndTime.value;

  }

  TimeOfDay _timeFromString(String time) {
    final parsedTime = TimeOfDay.fromDateTime(DateFormat("h:mm a").parse(time));
    return parsedTime;
  }

  String _stringFromTime(TimeOfDay time) {
    final parsedString = DateFormat("h:mm a").format(DateTime(0, 0, 0, time.hour, time.minute));
    return parsedString;
  }


  Future<void> _selectTime(BuildContext context, String title, TimeOfDay initialTime, Function(TimeOfDay) onSelected) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != initialTime) {
      onSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lunch"),
            ListTile(
              title: Text("Start Time: ${_stringFromTime(_lunchStartTime!)}"),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context, "Select Lunch Start Time", _lunchStartTime!, (TimeOfDay pickedTime) {
                setState(() {
                  _lunchStartTime = pickedTime;
                  _saveSettings();
                });
              }),
            ),
            ListTile(
              title: Text("End Time: ${_stringFromTime(_lunchEndTime!)}"),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context, "Select Lunch End Time", _lunchEndTime!, (TimeOfDay pickedTime) {
                setState(() {
                  _lunchEndTime =pickedTime;
                  _saveSettings();
                });
              }),
            ),
            SizedBox(height: 16.0),
            Text("Dinner"),
            ListTile(
              title: Text("Start Time: ${_stringFromTime(_dinnerStartTime!)}"),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context, "Select Dinner Start Time", _dinnerStartTime!, (TimeOfDay pickedTime) {
                setState(() {
                  _dinnerStartTime = pickedTime;
                  _saveSettings();
                });
              }),
            ),
            ListTile(
              title: Text("End Time: ${_stringFromTime(_dinnerEndTime!)}"),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context, "Select Dinner End Time", _dinnerEndTime!, (TimeOfDay pickedTime) {
                setState(() {
                  _dinnerEndTime = pickedTime;
                  _saveSettings();
                });
              }),
            ),
          ],
        ),
      ),
    );
  }
}