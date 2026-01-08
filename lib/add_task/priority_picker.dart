import 'package:flutter/material.dart';
import '../core/colors.dart';

class PriorityPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PriorityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.flag, color: AppColors.primary),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.card,
          builder: (_) => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 10,
            itemBuilder: (_, i) {
              final p = i + 1;
              return GestureDetector(
                onTap: () {
                  onChanged(p);
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p == value
                        ? AppColors.primary
                        : AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$p',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
