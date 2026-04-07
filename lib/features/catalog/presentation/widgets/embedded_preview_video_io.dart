import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EmbeddedPreviewVideo extends StatefulWidget {
  const EmbeddedPreviewVideo({
    super.key,
    required this.videoUrl,
    this.posterUrl,
  });

  final String videoUrl;
  final String? posterUrl;

  @override
  State<EmbeddedPreviewVideo> createState() => _EmbeddedPreviewVideoState();
}

class _EmbeddedPreviewVideoState extends State<EmbeddedPreviewVideo> {
  late final VideoPlayerController _controller;
  bool _failed = false;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);
      await _controller.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleMute() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    final nextMuted = !_muted;
    await _controller.setVolume(nextMuted ? 0 : 1);
    if (mounted) {
      setState(() {
        _muted = nextMuted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return _buildPosterFallback();
    }

    if (!_controller.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildPosterFallback(),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final size = _controller.value.size;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlayback,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PreviewControlButton(
                icon: _controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onTap: _togglePlayback,
              ),
              const SizedBox(width: 8),
              _PreviewControlButton(
                icon: _muted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                onTap: _toggleMute,
              ),
            ],
          ),
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

class _PreviewControlButton extends StatelessWidget {
  const _PreviewControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(150),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
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
