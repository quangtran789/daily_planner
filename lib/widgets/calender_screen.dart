import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test_appdp/home_screen.dart';
import 'package:test_appdp/login_screen.dart';
import 'package:test_appdp/services/auth_service.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<DateTime, List<dynamic>> events = {};
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("todos")
        .where('uid', isEqualTo: user!.uid)
        .get();

    Map<DateTime, List<dynamic>> eventMap = {};
    for (var doc in snapshot.docs) {
      DateTime eventDate = (doc['atTime'] as Timestamp).toDate();
      if (eventMap[eventDate] == null) {
        eventMap[eventDate] = [];
      }
      eventMap[eventDate]!.add(doc.data());
    }

    setState(() {
      events = eventMap;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1d2630),
      appBar: AppBar(
        backgroundColor: const Color(0xff1d2630),
        foregroundColor: Colors.white,
        title: const Text(
          'Calendar View',
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
                color: Colors.indigo,
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
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title:
                  const Text('Calendar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Handle navigation to Home if needed
              },
            ),
            // Add more ListTile for other menu options if needed
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
              });
              // Show event details when a day is selected
            },
            eventLoader: _getEventsForDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.indigo, // Change header color
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange, // Change today’s date color
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue, // Change selected date color
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(
                color: Colors.red, // Change weekend text color
              ),
              defaultTextStyle: const TextStyle(
                color: Colors.white, // Change default text color
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(selectedDay).length,
              itemBuilder: (context, index) {
                var event = _getEventsForDay(selectedDay)[index];
                return ListTile(
                  title: Text(event['title']),
                  subtitle: Text(event['description']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
