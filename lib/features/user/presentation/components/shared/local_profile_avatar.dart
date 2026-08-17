import 'dart:convert';

import 'package:flutter/material.dart';

class LocalProfileAvatar extends StatelessWidget {
  const LocalProfileAvatar({
    this.base64Image,
    this.imageUrl,
    this.radius = 21,
    this.onTap,
    super.key,
  });

  final String? base64Image;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF151515),
      backgroundImage: _imageProvider,
      child: _imageProvider == null
          ? Icon(Icons.person, color: Colors.grey.shade500, size: radius * 1.1)
          : null,
    );
    return onTap == null ? avatar : InkWell(onTap: onTap, child: avatar);
  }

  ImageProvider<Object>? get _imageProvider {
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(base64Image!));
      } catch (_) {
        // Fall through to the remote URL if the local cache is invalid.
      }
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }
}
