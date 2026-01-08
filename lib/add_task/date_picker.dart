import 'package:flutter/material.dart';
import '../core/colors.dart';

class DatePickerButton extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onSelected;

  const DatePickerButton({
    super.key,
    required this.date,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calendar_today, color: AppColors.primary),
      onPressed: () async {
        final result = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (result != null) {
          onSelected(result);
        }
      },
    );
  }
}
