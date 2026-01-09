import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/colors.dart';
import '../core/text_style.dart';
import '../home/todo_model.dart';
import '../home/todo_provider.dart';
import 'priority_picker.dart';

// ⬇️ GANTI ini sesuai nama halaman awal kamu
import '../home/home_page.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  // Default waktu: 2 menit dari sekarang
  DateTime selectedDate = DateTime.now().add(const Duration(minutes: 2));
  int priority = 1;

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  /// 🔥 Simpan task lalu langsung kembali ke halaman awal
  void _saveTask() {
    if (titleController.text.isEmpty) return;

    final todo = TodoModel(
      id: DateTime.now().toString(),
      title: titleController.text,
      description: descController.text,
      date: selectedDate,
      priority: priority,
    );

    // 1️⃣ Simpan ke Provider
    context.read<TodoProvider>().addTodo(todo);

    if (!mounted) return;

    // 2️⃣ LANGSUNG kembali ke halaman awal (tanpa notif)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Add Task"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== JUDUL =====
            TextField(
              controller: titleController,
              style: AppTextStyle.body,
              decoration: const InputDecoration(
                hintText: "Judul Tugas",
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ===== DESKRIPSI =====
            TextField(
              controller: descController,
              style: AppTextStyle.subtitle,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Deskripsi",
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== DATE & PRIORITY =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM, HH:mm').format(selectedDate),
                          style: AppTextStyle.body.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                PriorityPicker(
                  value: priority,
                  onChanged: (v) => setState(() => priority = v),
                ),
              ],
            ),

            const Spacer(),

            // ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveTask,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
