import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:test_appdp/widgets/calender_screen.dart';
import 'package:test_appdp/login_screen.dart';
import 'package:test_appdp/models/todo_model.dart';
import 'package:test_appdp/services/auth_service.dart';
import 'package:test_appdp/services/database_services.dart';
import 'package:test_appdp/widgets/completed_widget.dart';
import 'package:test_appdp/widgets/pending_widget.dart';
import 'package:test_appdp/widgets/task_statistics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _buttonIndex = 0;

  // Screens for the Bottom Navigation

  final _widgets = [
    const PendingWidget(),
    const CompletedWidget(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 251, 251),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2a9b6),
        foregroundColor: Colors.white,
        title: const Text(
          'Daily Planner',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Jaldi',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff1d2630),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color:  Color(0xfff2a9b6),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Công việc',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Handle navigation to Home if needed
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text('Lịch', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalenderScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Cài đặt', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TaskStatisticsScreen()),
                );
              },
            ),
            // Add more ListTile for other menu options if needed
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(
                      () {
                        _buttonIndex = 0;
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 0
                          ? Colors.indigo
                          : const Color.fromARGB(255, 232, 137, 137),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'thực hiện',
                        style: TextStyle(
                            fontSize: _buttonIndex == 0 ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: _buttonIndex == 0
                                ? Colors.white
                                : Colors.black38),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(
                      () {
                        _buttonIndex = 1;
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2.2,
                    decoration: BoxDecoration(
                      color: _buttonIndex == 1
                          ? Colors.indigo
                          : const Color.fromARGB(255, 232, 137, 137),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'thành công',
                        style: TextStyle(
                            fontSize: _buttonIndex == 1 ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: _buttonIndex == 1
                                ? Colors.white
                                : Colors.black38),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    thickness: 1,
                    endIndent: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            _widgets[_buttonIndex],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          _showTabDialog(context);
        },
      ),
    );
  }

  void _showTabDialog(BuildContext context, {Todo? todo}) {
    final TextEditingController _titleController =
        TextEditingController(text: todo?.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: todo?.description);
    final TextEditingController _locationController =
        TextEditingController(text: todo?.location);
    final TextEditingController _hostController =
        TextEditingController(text: todo?.host);
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final TextEditingController _atTimeController = TextEditingController(
      text: todo != null ? dateFormat.format(todo.atTime) : '',
    );

    DateTime? _selectedDateTime;
    final DatabaseServices _databaseService = DatabaseServices();

    Future<void> _pickDateTime() async {
      DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            _selectedDateTime = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
            _atTimeController.text =
                DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!);
          });
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            todo == null ? "Thêm kế hoạch" : "Thay đổi kế hoạch",
            style: const TextStyle(
                fontFamily: 'Jaldi', fontWeight: FontWeight.w400),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Tên công việc',
                      labelStyle: const TextStyle(
                          fontFamily: 'Jaldi',
                          fontSize: 20,
                          color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Chi tiết công việc',
                      labelStyle: const TextStyle(
                          fontFamily: 'Jaldi',
                          fontSize: 20,
                          color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Địa điểm',
                      labelStyle: const TextStyle(
                          fontFamily: 'Jaldi',
                          fontSize: 20,
                          color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _hostController,
                    decoration: InputDecoration(
                      labelText: 'Chủ trì',
                      labelStyle: const TextStyle(
                          fontFamily: 'Jaldi',
                          fontSize: 20,
                          color: Colors.black),
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _atTimeController,
                    readOnly: true, // To prevent keyboard from opening
                    decoration: InputDecoration(
                      labelText: 'Thời gian tổ chức',
                      labelStyle: const TextStyle(
                        fontFamily: 'Jaldi',
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: todo?.atTime ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              todo?.atTime ?? DateTime.now()),
                        );
                        if (pickedTime != null) {
                          final DateTime fullDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          _atTimeController.text =
                              dateFormat.format(fullDateTime);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Hủy',
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  DateTime selectedDateTime =
                      dateFormat.parse(_atTimeController.text);
                  if (todo == null) {
                    await _databaseService.addTodoTask(
                      _titleController.text,
                      _descriptionController.text,
                      _locationController.text,
                      _hostController.text,
                      selectedDateTime,
                    );
                  } else {
                    await _databaseService.updateTodo(
                      todo.id,
                      _titleController.text,
                      _descriptionController.text,
                      _locationController.text,
                      _hostController.text,
                      selectedDateTime,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  todo == null ? 'Thêm công việc' : 'Thay đổi công việc',
                  style: const TextStyle(color: Colors.white),
                ))
          ],
        );
      },
    );
  }
}
