import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/posts/presentation/controllers/posts_controller.dart';
import 'package:fitness_social_app/features/user/presentation/components/feed/feed_theme.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({required this.controller, super.key});

  final PostsController controller;

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'CREATE POST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: FeedTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              autofocus: true,
              minLines: 4,
              maxLines: 8,
              maxLength: 2000,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'شارك تقدمك مع المجتمع...',
                hintStyle: const TextStyle(color: FeedTheme.muted),
                filled: true,
                fillColor: FeedTheme.panelDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return 'محتوى المنشور مطلوب.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: FeedTheme.lime,
                  foregroundColor: Colors.black,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : const Text(
                        'نشر',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final post = await widget.controller.createPost(
      content: _contentController.text.trim(),
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (post != null) Navigator.of(context).pop(true);
  }
}
