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
      onBackgroundImageError: _imageProvider == null ? null : (_, __) {},
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
    final remoteUrl = _normalizeRemoteUrl(imageUrl);
    if (remoteUrl != null) {
      return NetworkImage(remoteUrl);
    }
    return null;
  }

  String? _normalizeRemoteUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    if (uri.host == 'localhost') {
      return uri.replace(host: '127.0.0.1').toString();
    }
    return uri.toString();
  }
}
