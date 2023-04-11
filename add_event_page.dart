import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_calendar_2/controllers/task_controller.dart';
import 'package:fyp_calendar_2/main.dart';
import 'package:fyp_calendar_2/ui/home_page.dart';
import 'package:fyp_calendar_2/ui/theme.dart';
import 'package:fyp_calendar_2/ui/widgets/button.dart';
import 'package:fyp_calendar_2/ui/widgets/input_field.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../db/db_helper.dart';
import '../models/task.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}


class _AddEventState extends State<AddEvent> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  //final CalendarScreenState _homePageController = new CalendarScreenState();
  DateTime _selectedDate = DateTime.now();
  String _endTime = "10:00 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = <int>[5, 10, 15, 20];
  String _selectedRepeated = "None";
  List<String> repeatList = <String>["None", "Daily", "Weekly", "Monthly"];
  int _selectedColor = 0;
  int _selectedDuration =30;
  String _selectedType = "None";
  List<String> _typeOptions = <String>["lunch", "dinner"];
  List<int> _durationOptions = <int>[30, 60, 90];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Schedule",
                  style: headingStyle,
                ),
                MyInputField(title: "Title", hint: "Enter your title", controller: _titleController,),
                MyInputField(title: "Note", hint: "Enter your note", controller: _noteController,),
                MyInputField(
                  title: "Type",
                  hint: "$_selectedType",
                  controller: _typeController,
                  widget: DropdownButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: hintClr,
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: hintStyle,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                        _typeController.text = _selectedType;
                      });
                    },
                    items:
                    _typeOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),

                  ),
                ),
                MyInputField(
                  title: "Duration",
                  hint: "$_selectedDuration ",
                  controller: _durationController,
                  widget: DropdownButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: hintClr,
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: hintStyle,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDuration = int.parse(newValue!);
                        _durationController.text = _selectedDuration.toString();
                      });
                    },
                    items:
                    _durationOptions.map<DropdownMenuItem<String>>((int value) {
                      return DropdownMenuItem<String>(
                        value: value.toString(),
                        child: Text(value.toString()),
                      );
                    }).toList(),

                  ),
                ),
                MyInputField(
                  title: "Date",
                  hint: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  widget: IconButton(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: hintClr,
                    ),
                    onPressed: () {
                      print(
                          "user press the calendar icon on add schedule page");
                      _getDateFromUser();
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: MyInputField(
                          title: "Start Time",
                          hint: _startTime,
                          widget: IconButton(
                            onPressed: () {
                              _getTimeFromUser(isStartTime: true);
                            },
                            icon: Icon(
                              Icons.access_time_rounded,
                              color: hintClr,
                            ),
                          ),
                        )),
                    SizedBox(
                      width: 22,
                    ),
                    Expanded(
                        child: MyInputField(
                          title: "End Time",
                          hint: _endTime,
                          widget: IconButton(
                            onPressed: () {
                              _getTimeFromUser(isStartTime: false);
                            },
                            icon: Icon(
                              Icons.access_time_rounded,
                              color: hintClr,
                            ),
                          ),
                        )),
                  ],
                ),
                MyInputField(
                  title: "Remind",
                  hint: "$_selectedRemind minutes early",
                  widget: DropdownButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: hintClr,
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: hintStyle,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRemind = int.parse(newValue!);
                      });
                    },
                    items:
                    remindList.map<DropdownMenuItem<String>>((int value) {
                      return DropdownMenuItem<String>(
                        value: value.toString(),
                        child: Text(value.toString()),
                      );
                    }).toList(),

                  ),
                ),
                MyInputField(
                  title: "Repeat",
                  hint: "$_selectedRepeated",
                  widget: DropdownButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: hintClr,
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: hintStyle,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRepeated = newValue!;
                      });
                    },
                    items:
                    repeatList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),

                  ),
                ),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _colorPalete(),
                    MyButton(label: "Create", onTap: () => _validateData()),
                    MyButton(label: "Auto Schedule", onTap: () => _autoSchedule(),),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  _validateData() {
    if(_titleController.text.isNotEmpty && _noteController.text.isNotEmpty){
      _addTaskToDB();
      print("$_titleController and $_noteController");

      Get.back();
    } else if(_titleController.text.isEmpty && _noteController.text.isEmpty) {
      Get.snackbar("Required", "All fields Are required !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.pink[300],
          icon: Icon(Icons.warning_amber_rounded, color: Colors.pink[300],)
      );
      print("Data validation fail : ALL");
    }else if(_titleController.text.isNotEmpty && _noteController.text.isEmpty) {
      Get.snackbar("Required", "Note field is required !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.pink[300],
          icon: Icon(Icons.warning_amber_rounded, color: Colors.pink[300],)
      );
      print("Data validation fail : Note Field");
    }else if(_titleController.text.isEmpty && _noteController.text.isNotEmpty) {
      Get.snackbar("Required", "Title field is required !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.pink[300],
          icon: Icon(Icons.warning_amber_rounded, color: Colors.pink[300],)
      );
      print("Data validation fail : Title Field");
    }
  }

  _addTaskToDB() async {
    int value = await _taskController.addTask(
        task: Task(
          title: _titleController.text,
          note: _noteController.text,
          type: _selectedType,
          duration: _selectedDuration,
          date: DateFormat("yyyy/M/d").format(_selectedDate),
          startTime: _startTime,
          endTime: _endTime,
          remind: _selectedRemind,
          repeat: _selectedRepeated,
          color: _selectedColor,
          isCompleted: 0,
        )
    );
    print("My id is " + "$value");
    //_homePageController.addTaskToList();
    print("addTaskToList function called");
  }
  Future<void> _autoSchedule() async {
    List<Task> tasks = await DBHelper.getTasks();
// Validate input
    if (_titleController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _durationController.text.isEmpty) {
      Get.snackbar("Error", "Please enter event details.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.pink[300],
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Colors.pink[300],
          ));
      return;
    }

    // 根據 type 設定起始時間和結束時間
    DateTime startTime;
    DateTime endTime;
    if (_selectedType == "lunch") {
      startTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 12);
      endTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 15);
    } else if (_selectedType == "dinner") {
      startTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 18);
      endTime = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 20);
    } else {
      // type 不是 "lunch" 或 "dinner"，顯示錯誤信息
      Get.snackbar("Error", "Type should be either lunch or dinner.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.pink[300],
          icon: Icon(Icons.warning_amber_rounded, color: Colors.pink[300],)
      );
      return;
    }
    //date: DateFormat.yMd().format(_selectedDate),
    // 找到起始時間後的第一個空閒時間段
    DateTime current = startTime;
    while (current.isBefore(endTime)) {
      bool isAvailable = true;
      for (int i = 0; i < tasks.length; i++) {
        Task task = tasks[i];
        DateFormat dateTimeFormat = DateFormat("yyyy/M/d h:mm a");
        DateTime taskStartTime = dateTimeFormat.parse("${task.date} ${task.startTime!}");
        DateTime taskEndTime = dateTimeFormat.parse("${task.date} ${task.endTime!}");

        if (current.isBefore(taskEndTime) &&
            current.add(Duration(minutes: _selectedDuration!)).isAfter(taskStartTime)) {
          // 時間段不可用
          isAvailable = false;
          break;

        }
      }
      if (isAvailable) {
        // 時間段可用，新增活動
        setState(() {
          _startTime = DateFormat("hh:mm a").format(current).toString();
          _endTime = DateFormat("hh:mm a").format(
              current.add(Duration(minutes: _selectedDuration!))).toString();
          _addTaskToDB();
        });
        Get.back();
        return;
      } else {
        // 時間段不可用，往後推移 30 分鐘
        current = current.add(Duration(minutes: 30));
      }
    }

    // 找不到空閒時間段，顯示錯誤信息
    Get.snackbar("Error", "No available time slots.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black54,
        colorText: Colors.pink[300],
        icon: Icon(Icons.warning_amber_rounded, color: Colors.pink[300],)
    );
  }

  _colorPalete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color",
          style: titleStyle,
        ),
        SizedBox(height: 8.0,),
        Wrap(
          children: List<Widget>.generate(
              3,
                  (int index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = index;
                      print(_selectedColor);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: index == 0 ? Colors.blue[700] : index == 1 ? Colors.pink : Colors.orange,
                      child: _selectedColor == index ? Icon(Icons.done,
                          color: Colors.white,
                          size: 16
                      ) : Container(),
                    ),
                  ),
                );
              }
          ),
        )
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2999));
    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
        print(_selectedDate);
      });
    } else {
      print("it is null value of date");
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var _pickedTime = await _showTimePicker();
    String _formatedTime = _pickedTime.format(context);
    if (_pickedTime == null) {
      print("Time canceled");
    } else if (isStartTime == true) {
      setState(() {
        _startTime = _formatedTime;
      });
    } else if (isStartTime == false) {
      setState(() {
        _endTime = _formatedTime;
      });
    }
  }

  _showTimePicker() {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
        ));
  }
}
