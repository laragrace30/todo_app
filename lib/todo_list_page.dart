import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'todo_item.dart';
import 'todo_service.dart';

class TodoListPage extends StatefulWidget {
  final List<TodoItem> todos;

  TodoListPage(this.todos);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List - Schedule Planner"),
        backgroundColor: const Color(0xFFFFBB5C),
      ),
      backgroundColor: const Color(0xFFC63D2F),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: 500,
          width: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9B50),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),  
                spreadRadius: 3,  
                blurRadius: 5,  
                offset: const Offset(0, 3), 
              ),
            ], 
          ),
         child: ValueListenableBuilder(
          valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
          builder: (context, Box<TodoItem> box, _) {
            return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                var todo = box.getAt(index);
                return ListTile(
                  title: Text(todo!.title),
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (val) {
                      _todoService.toggleCompleted(index, todo);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _todoService.deleteTodo(index);
                    },
                  ),
                );
              },
            );
          },
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: TextField(
                    controller: _controller,
                  ),
                  actions: [
                    ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          var todo = TodoItem(_controller.text);
                          _todoService.addTodo(todo);
                          _controller.clear();
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}