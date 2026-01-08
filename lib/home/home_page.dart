import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/text_style.dart';
import '../add_task/add_task_page.dart';
import 'todo_provider.dart';
import 'todo_tile.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Index"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<TodoProvider>(
          builder: (context, provider, _) {
            if (provider.todos.isEmpty) {
              return Center(
                child: Text(
                  "Apa yang kamu perlu ingat hari ini?\nTambahkan To-Do List anda",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subtitle,
                ),
              );
            }

            return ListView(
              children: provider.todos
                  .map((todo) => TodoTile(todo: todo))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}