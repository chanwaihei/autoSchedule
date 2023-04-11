import 'package:flutter/material.dart';
import 'package:fyp_calendar_2/ui/theme.dart';
import 'package:get/get.dart';
import 'package:fyp_calendar_2/controllers/SettingsController.dart';
import 'package:fyp_calendar_2/controllers/task_controller.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../db/db_helper.dart';
import '../models/task.dart';
import '../ui/widgets/button.dart';
import '../ui/widgets/input_field.dart';
import 'SettingsPage.dart';




class AutoSchedulePage extends StatefulWidget {
  final List<Task> tasks;

  AutoSchedulePage({required this.tasks});

  @override
  AutoSchedulePageState createState() => AutoSchedulePageState();
}

class AutoSchedulePageState extends State<AutoSchedulePage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final SettingsController _settingsController = Get.find<SettingsController>();
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
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyButton(label: "Auto Schedule", onTap: () => _autoSchedule(),),
                    MyButton(label: "Settings", onTap: () => _goToSettings(),), // 新增的设置按钮
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
 /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Schedule Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title'),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter your title',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Type'),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: 'Enter your type',
              ),
            ),
            SizedBox(height: 16.0),
            Text('Duration (in minutes)'),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter the duration',
              ),
            ),
            SizedBox(height: 16.0),
            MyButton(
              label: 'Auto Schedule',
              onTap: () => _autoSchedule(),
            ),
          ],
        ),
      ),
    );
  }*/

  void _goToSettings() {
    Get.to(() => SettingsPage());
  }
  _addTaskToDB() async {
    int value = await _taskController.addTask(
        task: Task(
          title: _titleController.text,
          note: _noteController.text,
          type: _selectedType,
          duration: _selectedDuration,
          date: DateFormat.yMd().format(_selectedDate),
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
    SettingsController settingsController = Get.find();
    List<Task> tasks = await DBHelper.getTasks();
    DateTime today = DateTime.now();
    DateTime weekLater = today.add(Duration(days: 7));

    final lunchStartTimeDuration = _durationFromTimeOfDay(_settingsController.lunchStartTime.value);
    final lunchEndTimeDuration = _durationFromTimeOfDay(_settingsController.lunchEndTime.value);
    final dinnerStartTimeDuration = _durationFromTimeOfDay(_settingsController.dinnerStartTime.value);
    final dinnerEndTimeDuration = _durationFromTimeOfDay(_settingsController.dinnerEndTime.value);
    List<DateTime> daysToCheck = List.generate(
        7, (index) => today.add(Duration(days: index)));

    bool foundAvailableSlot = false;

    for (DateTime date in daysToCheck) {
      List<DateTime> availableTimeSlots = [];

      // 根据 type 设置起始时间和结束时间
      DateTime startTime;
      DateTime endTime;
      if (_selectedType == "lunch") {
        startTime = DateTime(date.year, date.month, date.day).add(lunchStartTimeDuration);
        endTime = DateTime(date.year, date.month, date.day).add(lunchEndTimeDuration);
        //startTime = DateTime(date.year, date.month, date.day).add(_durationFromTimeOfDay(settingsController.lunchStartTime.value)); // 使用新的设置值
       //endTime = DateTime(date.year, date.month, date.day).add(_durationFromTimeOfDay(settingsController.lunchEndTime.value)); // 使用新的设置值
      } else if (_selectedType == "dinner") {
        startTime = DateTime(date.year, date.month, date.day).add(dinnerStartTimeDuration);
        endTime = DateTime(date.year, date.month, date.day).add(dinnerEndTimeDuration);
      } else {
        continue;
      }

      // 找到起始时间后的第一个空闲时间段
      DateTime current = startTime;
      while (current.isBefore(endTime)) {
        bool isAvailable = true;
        for (int i = 0; i < tasks.length; i++) {
          Task task = tasks[i];
          DateFormat dateTimeFormat = DateFormat.yMd().add_jm();
          DateTime taskStartTime =
          dateTimeFormat.parse("${task.date} ${task.startTime!}");
          DateTime taskEndTime =
          dateTimeFormat.parse("${task.date} ${task.endTime!}");

          if (current.isBefore(taskEndTime) &&
              current
                  .add(Duration(minutes: _selectedDuration!))
                  .isAfter(taskStartTime)) {
            // 时间段不可用
            isAvailable = false;
            break;
          }
        }
        if (isAvailable) {
          // 时间段可用，新增活动
          setState(() {
            _selectedDate = date;
            _startTime = DateFormat("hh:mm a").format(current).toString();
            _endTime = DateFormat("hh:mm a")
                .format(current.add(Duration(minutes: _selectedDuration!)))
                .toString();
            _addTaskToDB();
          });
          Get.back();
          foundAvailableSlot = true;
          break;
        }
        // 时间段不可用，往后推移 30 分钟
        current = current.add(Duration(minutes: 30));
      }

      // 如果找到可用时间段，停止搜寻
      if (foundAvailableSlot) {
        break;
      }
    }

    // 如果找不到可用时间段，显示错误信息
    if (!foundAvailableSlot) {
      Get.snackbar(
        "Error",
        "No available time slots in the next 7 days.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black54,
        colorText: Colors.pink[300],
        icon: Icon(Icons.warning_amber_rounded, color: Colors.pink[300]),
      );
    }
  }

  TimeOfDay _timeFromString(String timeString) {
    final format = DateFormat.jm(); // Use the correct format for your time string
    final dateTime = format.parse(timeString);
    return TimeOfDay.fromDateTime(dateTime);
  }

  Duration _durationFromTimeOfDay(TimeOfDay time) {
    return Duration(hours: time.hour, minutes: time.minute);
  }



  Widget _buildTypeInputField() {
    return MyInputField(
      title: "Type",
      hint: "$_selectedType",
      controller: _typeController,
      widget: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              if (_selectedType == "lunch") {
                setState(() {
                  _startTime = "12:00 PM";
                  _endTime = "3:00 PM";
                });
              } else if (_selectedType == "dinner") {
                setState(() {
                  _startTime = "6:00 PM";
                  _endTime = "8:00 PM";
                });
              }
            },
            child: Text("Set Time"),
          ),
          SizedBox(width: 16),
          DropdownButton(
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
            items: _typeOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


}
