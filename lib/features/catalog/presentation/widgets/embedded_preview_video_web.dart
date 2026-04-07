// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class EmbeddedPreviewVideo extends StatefulWidget {
  const EmbeddedPreviewVideo({
    super.key,
    required this.videoUrl,
    this.posterUrl,
  });

  final String videoUrl;
  final String? posterUrl;

  @override
  State<EmbeddedPreviewVideo> createState() => _EmbeddedPreviewVideoWebState();
}

class _EmbeddedPreviewVideoWebState extends State<EmbeddedPreviewVideo> {
  static int _nextViewId = 0;

  late final String _viewType;
  late final html.VideoElement _videoElement;
  bool _failed = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'exeos-preview-video-${_nextViewId++}';
    _videoElement = html.VideoElement()
      ..src = widget.videoUrl
      ..autoplay = true
      ..muted = true
      ..loop = true
      ..controls = true
      ..preload = 'auto'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.border = '0'
      ..style.backgroundColor = '#172133';
    if (widget.posterUrl != null && widget.posterUrl!.trim().isNotEmpty) {
      _videoElement.poster = widget.posterUrl!;
    }
    _videoElement.setAttribute('playsinline', 'true');
    _videoElement.setAttribute('webkit-playsinline', 'true');
    _videoElement.onCanPlay.first.then((_) async {
      try {
        await _videoElement.play();
      } catch (_) {
        // Browser autoplay restrictions are acceptable; controls stay visible.
      }
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
    _videoElement.onError.first.then((_) {
      if (mounted) {
        setState(() {
          _failed = true;
        });
      }
    });
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return _videoElement;
    });
  }

  @override
  void dispose() {
    _videoElement.pause();
    _videoElement.removeAttribute('src');
    _videoElement.load();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _buildPosterFallback();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView(viewType: _viewType),
        if (!_ready)
          Stack(
            fit: StackFit.expand,
            children: [
              _buildPosterFallback(),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
      ],
    );
  }

  Widget _buildPosterFallback() {
    if (widget.posterUrl == null) {
      return const _EmbeddedPreviewFallback();
    }
    return Image.network(
      widget.posterUrl!,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, __, ___) => const _EmbeddedPreviewFallback(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _EmbeddedPreviewFallback(),
    );
  }
}

class _EmbeddedPreviewFallback extends StatelessWidget {
  const _EmbeddedPreviewFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF172133),
      alignment: Alignment.center,
      child: const Icon(
        Icons.motion_photos_on_rounded,
        size: 44,
        color: Color(0xFF63D5FF),
      ),
    );
  }
}
