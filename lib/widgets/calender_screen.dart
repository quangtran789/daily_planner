import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test_appdp/home_screen.dart';
import 'package:test_appdp/models/todo_model.dart';
import 'package:test_appdp/services/database_services.dart';
import 'package:test_appdp/widgets/task_statistics.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  final DatabaseServices _databaseService = DatabaseServices();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Thêm biến để theo dõi định dạng lịch

  Map<DateTime, List<Todo>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTodos();
  }

  void _loadTodos() {
    _databaseService.todos.listen((todoList) {
      setState(() {
        _events.clear(); // Reset lại dữ liệu
        for (var todo in todoList) {
          DateTime todoDate = DateTime(
            todo.atTime.year,
            todo.atTime.month,
            todo.atTime.day,
          );
          if (_events[todoDate] == null) {
            _events[todoDate] = [];
          }
          _events[todoDate]!.add(todo);
        }
      });
    });
  }

  List<Todo> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch công việc',
          style: TextStyle(fontFamily: 'Jaldi'),
        ),
        backgroundColor: const Color(0xfff2a9b6),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff1d2630),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xfff2a9b6),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text('Lịch', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Cài đặt', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TaskStatisticsScreen()),
                ); // Close the drawer
              },
            ),
            // Add more ListTile for other menu options if needed
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat:
                _calendarFormat, // Sử dụng biến để điều chỉnh định dạng lịch
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              // Xử lý khi định dạng thay đổi
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.tealAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedDay == null) {
      return const Center(child: Text('Chọn một ngày để xem các công việc.'));
    }

    final todosForSelectedDay = _getEventsForDay(_selectedDay!);

    if (todosForSelectedDay.isEmpty) {
      return const Center(
          child: Text('Không có công việc nào trong ngày này.'));
    }

    return ListView.builder(
      itemCount: todosForSelectedDay.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Todo todo = todosForSelectedDay[index];
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xfff2a9b6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
          ),
          child: Slidable(
            key: ValueKey(todo.id),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.done,
                  label: "Hoàn Thành",
                  onPressed: (context) {
                    _databaseService.updateTodoStatus(todo.id, true);
                  },
                ),
              ],
            ),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: "Sửa",
                  onPressed: (context) {
                    _showTabDialog(context, todo: todo);
                  },
                ),
                SlidableAction(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: "Xóa",
                  onPressed: (context) async {
                    await _databaseService.deleteTodoTask(todo.id);
                  },
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                todo.title,
                style: const TextStyle(
                  fontFamily: 'Jaldi',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                todo.description,
                style: const TextStyle(
                  fontFamily: 'Jaldi',
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                DateFormat('HH:mm').format(todo.atTime),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
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
