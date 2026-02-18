import 'package:flutter/material.dart';

Future<String?> showEditTextDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String initialValue = "",
  int maxLines = 1,
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isEmpty) return; 
            Navigator.pop(context, value);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

Future<int?> showEditIntDialog(
  BuildContext context, {
  required String title,
  required String hint,
  int? initialValue,

}) {
  final controller = TextEditingController(
    text: initialValue?.toString() ?? "",
  );

  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            final n = int.tryParse(text);

            if (n == null) return; 
            if (n < 1 || n > 120) return; 

            Navigator.pop(context, n);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
