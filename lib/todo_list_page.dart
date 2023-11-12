import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'todo_item.dart';
import 'todo_service.dart';

class TodoListPage extends StatefulWidget {
  final List<TodoItem> todos;

  const TodoListPage(this.todos, {Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();
  List<Widget> containers = [];
  List<bool> isMinimizedList = []; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List - Schedule Planner"),
        backgroundColor: const Color(0xFFFFBB5C),
      ),
      backgroundColor: const Color(0xFFC63D2F),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _addNewContainer();
            },
            child: const Text('Add New Container'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: containers.length,
              itemBuilder: (context, index) {
                return _buildContainer(index);
              },
            ),
          ),
        ],
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
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewContainer() {
    setState(() {
      containers.add(_buildContainer(containers.length));
      isMinimizedList.add(false); 
    });
  }

  Widget _buildContainer(int index) {
  if (index >= 0 && index < containers.length) {
    return Container(
      height: isMinimizedList[index] ? 50 : 250,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  _removeContainer(index);
                },
              ),
              IconButton(
                icon: isMinimizedList[index]
                    ? const Icon(Icons.restore)
                    : const Icon(Icons.minimize),
                onPressed: () {
                  _toggleMinimized(index);
                },
              ),
            ],
          ),
          Expanded(
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
        ],
      ),
    );
  } else {
    return Container();
  }
}

  void _removeContainer(int index) {
    setState(() {
      containers.removeAt(index);
      isMinimizedList.removeAt(index);
    });
  }

  void _toggleMinimized(int index) {
    setState(() {
      isMinimizedList[index] = !isMinimizedList[index];
    });
  }
}