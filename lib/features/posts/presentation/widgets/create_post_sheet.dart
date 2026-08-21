import 'dart:typed_data';

import 'package:fitness_social_app/core/network/api_client.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _picker = ImagePicker();
  final List<XFile> _selectedImages = <XFile>[];
  bool _isSubmitting = false;
  bool _isPickingImages = false;

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
        child: SingleChildScrollView(
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
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                  hintText: 'Share your progress with the community...',
                  hintStyle: const TextStyle(color: FeedTheme.muted),
                  filled: true,
                  fillColor: FeedTheme.panelDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty && _selectedImages.isEmpty) {
                    return 'Add content or at least one image.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSubmitting || _isPickingImages ? null : _pickImages,
                icon: _isPickingImages
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(
                  _selectedImages.isEmpty
                      ? 'Choose images'
                      : 'Add images (${_selectedImages.length})',
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 10),
                _SelectedImagesPreview(
                  images: _selectedImages,
                  onRemove: _isSubmitting
                      ? null
                      : (index) => setState(() => _selectedImages.removeAt(index)),
                ),
              ],
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
                          'Post',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    setState(() => _isPickingImages = true);
    try {
      final images = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1600);
      if (!mounted) return;
      setState(() {
        final existingPaths = _selectedImages.map((image) => image.path).toSet();
        _selectedImages.addAll(
          images.where((image) => existingPaths.add(image.path)),
        );
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to select images.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final files = <MultipartUploadFile>[];
    for (final image in _selectedImages) {
      files.add(MultipartUploadFile(
        fileName: image.name,
        bytes: await image.readAsBytes(),
      ));
    }
    final mediaUrls = files.isEmpty
        ? const <String>[]
        : await widget.controller.uploadPostMedia(files);
    if (mediaUrls == null) {
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }
    final post = await widget.controller.createPost(
      content: _contentController.text.trim(),
      mediaUrls: mediaUrls,
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (post != null) Navigator.of(context).pop(true);
  }

}

class _SelectedImagesPreview extends StatelessWidget {
  const _SelectedImagesPreview({required this.images, required this.onRemove});

  final List<XFile> images;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List>(
            future: images[index].readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 92,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      snapshot.data!,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove!(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black87,
                          child: Icon(Icons.close, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
