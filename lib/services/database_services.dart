import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_appdp/models/todo_model.dart';

class DatabaseServices {
  final CollectionReference todoCollection =
      FirebaseFirestore.instance.collection("todos");

  User? user = FirebaseAuth.instance.currentUser;

  //Add todo task
  Future<DocumentReference> addTodoTask(String title, String description,
      String location, String host, DateTime atTime) async {
    return await todoCollection.add({
      'uid': user!.uid,
      'title': title,
      'description': description,
      'location': location,
      'host': host,
      'atTime': Timestamp.fromDate(atTime),
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //Update todo Task
  Future<void> updateTodo(String id, String title, String description,
      String location, String host, DateTime atTime) async {
    final updatetodoCollection =
        FirebaseFirestore.instance.collection('todos').doc(id);
    return await updatetodoCollection.update({
      'title': title,
      'description': description,
      'location': location,
      'host': host,
      'atTime': Timestamp.fromDate(atTime),
    });
  }

  //update todo status
  Future<void> updateTodoStatus(String id, bool completed) async {
    return await todoCollection.doc(id).update({'completed': completed});
  }

  //deleta todo task
  Future<void> deleteTodoTask(String id) async {
    return await todoCollection.doc(id).delete();
  }

  //get pending tasks
  Stream<List<Todo>> get todos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: false)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  //get completed tasks
  Stream<List<Todo>> get completedtodos {
    return todoCollection
        .where('uid', isEqualTo: user!.uid)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  List<Todo> _todoListFromSnapshot(QuerySnapshot snapshot) {
    print('Number of documents fetched: ${snapshot.docs.length}');
    snapshot.docs.forEach((doc) {
      print('Todo data: ${doc.data()}');
    });

    return snapshot.docs.map((doc) {
      return Todo(
        id: doc.id,
        title: doc['title'] ?? '',
        description: doc['description'] ?? '',
        location: doc['location'] ?? '',
        host: doc['host'] ?? '',
        atTime: (doc['atTime'] as Timestamp).toDate(),
        completed: doc['completed'] ?? false,
        timestamp: doc['createdAt'] ?? '',
      );
    }).toList();
  }
}
