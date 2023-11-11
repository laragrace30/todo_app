import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'todo_item.dart';
import 'todo_list_page.dart';
import 'todo_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(TodoItemAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive TODO List',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _todoService.getAllTodos(),
        builder: (context, AsyncSnapshot<List<TodoItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TodoListPage(snapshot.data ?? []);
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

