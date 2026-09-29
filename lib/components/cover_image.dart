import 'dart:io';
import 'package:flutter/material.dart';

class CoverImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CoverImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  bool get _isRemote => path.startsWith('http') || path.startsWith('blob:');

  Widget _buildError(BuildContext context, Object error, StackTrace? stackTrace) {
    final Widget fallback = errorBuilder != null
        ? errorBuilder!(context, error, stackTrace)
        : Container(
            color: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.music_note),
          );
    // errorBuilder replaces Image entirely, so it doesn't inherit Image's
    // width/height — without this, a fallback like a plain Container tries
    // to expand unbounded, which breaks layouts such as ListTile.leading.
    return SizedBox(width: width, height: height, child: fallback);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemote) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: _buildError,
      );
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: _buildError,
    );
  }
}
