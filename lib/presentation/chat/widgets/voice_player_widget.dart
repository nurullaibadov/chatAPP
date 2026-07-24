import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';

class VoicePlayerWidget extends StatefulWidget {
  final String audioUrl;
  final int? durationInSeconds;
  final bool isMe;

  const VoicePlayerWidget({
    super.key,
    required this.audioUrl,
    this.durationInSeconds,
    required this.isMe,
  });

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _duration = (await _audioPlayer.setUrl(widget.audioUrl)) ??
          Duration(seconds: widget.durationInSeconds ?? 0);

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing &&
                state.processingState != ProcessingState.completed;
            if (state.processingState == ProcessingState.completed) {
              _position = Duration.zero;
              _audioPlayer.seek(Duration.zero);
              _audioPlayer.pause();
            }
          });
        }
      });

      _audioPlayer.positionStream.listen((pos) {
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      });
    } catch (e) {
      debugPrint('Audio loading error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isMe ? Colors.white : AppColors.primary;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 36,
              color: activeColor,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: activeColor,
                    inactiveTrackColor: activeColor.withAlpha(80),
                    thumbColor: activeColor,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    value: _position.inMilliseconds
                        .clamp(0, _duration.inMilliseconds.toDouble())
                        .toDouble(),
                    onChanged: (val) {
                      _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
