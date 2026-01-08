import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Pastikan path import ini sesuai dengan struktur folder kamu
import '/../core/colors.dart';
import '/../core/text_style.dart';
import 'todo_model.dart';
import 'todo_provider.dart';

class TodoTile extends StatefulWidget {
  final TodoModel todo;

  const TodoTile({super.key, required this.todo});

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // ⏱ Rebuild otomatis agar countdown realtime
    _timer = Timer.periodic(
      const Duration(seconds: 1), // update tiap 30 detik (hemat performa)
          (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA HITUNG MUNDUR REALTIME ---
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

    // ------------------------------------

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
          // 1. Checkbox (TIDAK BERUBAH)
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

          // 2. Judul, Deskripsi & Waktu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.todo.title,
                  style: AppTextStyle.body.copyWith(
                    decoration: widget.todo.isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                if (widget.todo.description.isNotEmpty) ...[
                  Text(
                    widget.todo.description,
                    style: AppTextStyle.subtitle,
                  ),
                  const SizedBox(height: 8),
                ],

                // Countdown / Terlambat
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 12, color: timeColor),
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

          // 3. Priority Badge (TIDAK BERUBAH)
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
          )
        ],
      ),
    );
  }
}
