import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_colors.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(File audioFile, int durationInSeconds) onRecordingCompleted;
  final VoidCallback onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingCompleted,
    required this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _path;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        widget.onCancel();
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _path!,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      widget.onCancel();
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null && _recordDuration > 0) {
        widget.onRecordingCompleted(File(path), _recordDuration);
      } else {
        widget.onCancel();
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      widget.onCancel();
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    try {
      await _audioRecorder.stop();
      if (_path != null) {
        final file = File(_path!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup error
    }
    widget.onCancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatDuration(int duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration ~/ 60);
    final seconds = twoDigits(duration % 60);
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _cancelRecording,
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isRecording ? 1.0 : 0.4,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_recordDuration),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary, size: 28),
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }
}
