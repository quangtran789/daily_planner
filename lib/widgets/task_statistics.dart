import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:test_appdp/home_screen.dart';
import 'package:test_appdp/services/database_services.dart';
import 'package:test_appdp/widgets/calender_screen.dart';

class TaskStatisticsScreen extends StatefulWidget {
  const TaskStatisticsScreen({super.key});

  @override
  _TaskStatisticsScreenState createState() => _TaskStatisticsScreenState();
}

class _TaskStatisticsScreenState extends State<TaskStatisticsScreen> {
  final DatabaseServices _databaseService = DatabaseServices();
  int completedTasks = 0;
  int ongoingTasks = 0;
  int createdTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadTaskStatistics();
  }

  void _loadTaskStatistics() {
    _databaseService.completedtodos.listen((tasks) {
      setState(() {
        completedTasks = tasks.length;
      });
    });

    // Giả sử bạn có một stream để lấy công việc đang thực hiện và mới tạo
    _databaseService.ongoingTodos.listen((tasks) {
      setState(() {
        ongoingTasks = tasks.length;
      });
    });

    _databaseService.createdTodos.listen((tasks) {
      setState(() {
        createdTasks = tasks.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = completedTasks + ongoingTasks + createdTasks;
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê công việc'),
        backgroundColor: const Color(0xfff2a9b6),
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
              },
            ),
            // Add more ListTile for other menu options if needed
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: completedTasks.toDouble(),
                    color: Colors.green,
                    title: totalTasks > 0
                        ? 'Hoàn thành\n${(completedTasks / totalTasks * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  PieChartSectionData(
                    value: ongoingTasks.toDouble(),
                    color: Colors.orange,
                    title: totalTasks > 0
                        ? 'Đang thực hiện\n${(ongoingTasks / totalTasks * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                  PieChartSectionData(
                    value: createdTasks.toDouble(),
                    color: Colors.blue,
                    title: totalTasks > 0
                        ? 'Tạo mới\n ${(createdTasks / totalTasks * 100).toStringAsFixed(1)}%'
                        : '0%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
