import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/colors.dart';
import '../core/text_style.dart';
import '../core/notification_service.dart';
import '../home/todo_model.dart';
import '../home/todo_provider.dart';
import 'priority_picker.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  // Default waktu: 2 menit dari sekarang (biar enak buat ngetes langsung)
  DateTime selectedDate = DateTime.now().add(const Duration(minutes: 2));
  int priority = 1;

  @override
  void initState() {
    super.initState();
    // Wajib minta izin saat halaman dibuka
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );

      if (pickedTime != null) {
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
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: AppColors.primary),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty) return;

                  final todo = TodoModel(
                    id: DateTime.now().toString(),
                    title: titleController.text,
                    description: descController.text,
                    date: selectedDate,
                    priority: priority,
                  );

                  // 1. Simpan ke Database/Provider
                  context.read<TodoProvider>().addTodo(todo);

                  // 2. Jadwalkan Notifikasi TERLAMBAT (Hanya 1 Notifikasi)
                  // Menggunakan .abs() agar ID aman
                  await NotificationService.scheduleNotification(
                    id: todo.hashCode.abs(),
                    title: "Waktu Habis!",
                    body: "Tugas '${todo.title}' sudah jatuh tempo sekarang.",
                    scheduledDate: selectedDate,
                  );

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}