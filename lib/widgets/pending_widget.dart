import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:test_appdp/models/todo_model.dart';
import 'package:test_appdp/services/database_services.dart';

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  final DatabaseServices _databaseService = DatabaseServices();
  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  // Danh sách màu cố định
  final List<Color> _colors = [
    Color(0xffC96868), // Màu xanh
    Color(0xff48CFCB), // Màu vàng
    Color(0xff78B7D0), // Màu đỏ
    Color(0xffA5B68D), // Màu xanh lá
    Colors.orange, // Màu cam
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseService.todos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Todo> todos = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];

              // Chọn màu dựa trên chỉ mục của item
              Color tileColor = _colors[
                  index % _colors.length]; // Áp dụng màu tuần tự theo thứ tự

              return Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tileColor, // Áp dụng màu theo chỉ mục
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
                      'Hạn chót: ${DateFormat('yyyy-MM-dd | HH:mm:ss').format(todo.atTime)},',
                      style: const TextStyle(
                        fontFamily: 'Jaldi',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
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
