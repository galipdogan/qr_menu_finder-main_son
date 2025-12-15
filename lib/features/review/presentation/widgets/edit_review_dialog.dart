import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EditReviewDialog extends StatefulWidget {
  final String initialText;
  final double initialRating;

  const EditReviewDialog({
    super.key,
    required this.initialText,
    required this.initialRating,
  });

  @override
  State<EditReviewDialog> createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<EditReviewDialog> {
  late TextEditingController _textController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yorumu Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating section
            const Text('Puanlama'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.ratingStar,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            // Review text section
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Yorumunuz',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _textController.text.trim();
            if (text.isNotEmpty) {
              Navigator.pop(context, {
                'text': text,
                'rating': _rating,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}