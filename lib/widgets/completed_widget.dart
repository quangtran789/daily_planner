import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:test_appdp/models/todo_model.dart';
import 'package:test_appdp/services/database_services.dart';

class CompletedWidget extends StatefulWidget {
  const CompletedWidget({super.key});

  @override
  State<CompletedWidget> createState() => _CompletedWidgetState();
}

class _CompletedWidgetState extends State<CompletedWidget> {
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
    const Color(0xffC4D7FF), // Màu xanh
    const Color(0xffEE66A6), // Màu vàng
    const Color(0xffC1CFA1), // Màu đỏ
    const Color(0xff86D293), // Màu xanh lá
    const Color(0xffD2FF72), // Màu cam
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseService.completedtodos,
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
                  index % _colors.length]; // Áp dụng màu tuần tự theo chỉ mục

              return Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tileColor, // Áp dụng màu cho mỗi ô
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 3.0,
                  ),
                ),
                child: Slidable(
                  key: ValueKey(todo.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
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
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Đã hoàn thành \n',
                            style: const TextStyle(
                              fontFamily: 'Jaldi',
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .red, // Đặt màu đỏ cho phần "Đã hoàn thành"
                            ),
                          ),
                          TextSpan(
                            text: todo.title,
                            style: const TextStyle(
                              fontFamily: 'Jaldi',
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration
                                  .lineThrough, // Gạch ngang cho nhiệm vụ hoàn thành
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      todo.description,
                      style: const TextStyle(
                        fontFamily: 'Jaldi',
                        fontWeight: FontWeight.w500,
                        // Gạch ngang cho nhiệm vụ hoàn thành
                      ),
                    ),
                    trailing: Text(
                      'Hạn chót: ${DateFormat('yyyy-MM-dd | HH:mm:ss').format(todo.atTime)},',
                      style: const TextStyle(
                        fontFamily: 'Jaldi',
                        fontWeight: FontWeight.w500,
                        color: Colors.black, // Màu chữ
                        fontSize: 13, // Kích thước chữ
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
}
