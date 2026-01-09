import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/../core/colors.dart';
import '/../core/text_style.dart';
import '/../core/notification_service.dart';
import 'todo_model.dart';
import 'todo_provider.dart';

class TodoTile extends StatefulWidget {
  final TodoModel todo;

  const TodoTile({super.key, required this.todo});

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  Timer? _rebuildTimer; // untuk update UI
  Timer? _notifyTimer; // untuk trigger notif sekali

  bool _hasNotified = false;

  @override
  void initState() {
    super.initState();

    // 🔁 Rebuild UI tiap 1 detik (countdown realtime)
    _rebuildTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _setupNotificationTrigger();
  }

  /// Setup timer agar notif muncul tepat saat waktu habis
  void _setupNotificationTrigger() {
    final now = DateTime.now();
    final diff = widget.todo.date.difference(now);

    // Kalau sudah lewat atau sudah selesai → tidak perlu notif
    if (diff.isNegative || widget.todo.isDone) return;

    _notifyTimer = Timer(diff, () async {
      if (!_hasNotified && mounted) {
        _hasNotified = true;

        await NotificationService.showNow(
          title: "Waktu Habis",
          body: "Tugas '${widget.todo.title}' sudah selesai waktunya!",
        );
      }
    });
  }

  @override
  void dispose() {
    _rebuildTimer?.cancel();
    _notifyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = widget.todo.date.difference(now);

    String timeText;
    Color timeColor;

    // 🔴 TELAT & BELUM SELESAI
    if (diff.isNegative && !widget.todo.isDone) {
      final late = diff.abs();

      if (late.inSeconds < 60) {
        timeText = "Terlambat beberapa detik";
      } else if (late.inMinutes < 60) {
        timeText = "Terlambat ${late.inMinutes} menit";
      } else if (late.inHours < 24) {
        timeText = "Terlambat ${late.inHours} jam";
      } else {
        timeText = "Terlambat ${late.inDays} hari";
      }

      timeColor = Colors.red;
    }
    // 🟠 SELESAI TAPI TELAT
    else if (widget.todo.isDone && diff.isNegative) {
      timeText = "Selesai (Terlambat)";
      timeColor = Colors.orange;
    }
    // 🟢 SELESAI TEPAT WAKTU
    else if (widget.todo.isDone) {
      timeText = "Selesai";
      timeColor = Colors.green;
    }
    // ⏱ COUNTDOWN
    else {
      if (diff.inSeconds < 60) {
        timeText = "Sisa ${diff.inSeconds} detik";
        timeColor = Colors.orange;
      } else if (diff.inMinutes < 60) {
        timeText = "Sisa ${diff.inMinutes} menit";
        timeColor = Colors.grey;
      } else if (diff.inHours < 24) {
        timeText = "Sisa ${diff.inHours} jam";
        timeColor = Colors.grey;
      } else {
        timeText = "Sisa ${diff.inDays} hari";
        timeColor = Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Checkbox
          GestureDetector(
            onTap: () {
              context.read<TodoProvider>().toggleTodo(widget.todo.id);
            },
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary),
                color: widget.todo.isDone
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: widget.todo.isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // 2. Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.todo.title,
                  style: AppTextStyle.body.copyWith(
                    decoration: widget.todo.isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),

                if (widget.todo.description.isNotEmpty) ...[
                  Text(widget.todo.description, style: AppTextStyle.subtitle),
                  const SizedBox(height: 8),
                ],

                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: timeColor),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: timeColor,
                        fontWeight: diff.isNegative
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 3. Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "P${widget.todo.priority}",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
