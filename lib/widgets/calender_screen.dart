import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test_appdp/models/todo_model.dart';
import 'package:test_appdp/services/database_services.dart';

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
        title: Text('Lịch công việc'),
        backgroundColor: const Color(0xfff2a9b6),
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
            calendarStyle:const CalendarStyle(
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
      return const Center(child: Text('Không có công việc nào trong ngày này.'));
    }

    return ListView.builder(
      itemCount: todosForSelectedDay.length,
      itemBuilder: (context, index) {
        Todo todo = todosForSelectedDay[index];
        return ListTile(
          title: Text(
            todo.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(todo.description),
          trailing: Text(
            DateFormat('HH:mm').format(todo.atTime),
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
