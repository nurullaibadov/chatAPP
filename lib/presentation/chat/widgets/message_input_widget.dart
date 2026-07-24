import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/message_model.dart';
import 'reply_preview_widget.dart';
import 'voice_recorder_widget.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(String text) onSendTextMessage;
  final Function(File imageFile) onSendImageMessage;
  final Function(File audioFile, int duration) onSendAudioMessage;
  final Function(bool isTyping) onTypingChanged;
  final MessageModel? replyMessage;
  final VoidCallback onCancelReply;
  final MessageModel? editingMessage;
  final VoidCallback onCancelEdit;

  const MessageInputWidget({
    super.key,
    required this.onSendTextMessage,
    required this.onSendImageMessage,
    required this.onSendAudioMessage,
    required this.onTypingChanged,
    this.replyMessage,
    required this.onCancelReply,
    this.editingMessage,
    required this.onCancelEdit,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final _controller = TextEditingController();
  bool _isComposing = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingMessage != null) {
      _controller.text = widget.editingMessage!.text ?? '';
      _isComposing = _controller.text.trim().isNotEmpty;
    }
  }

  @override
  void didUpdateWidget(covariant MessageInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingMessage != oldWidget.editingMessage &&
        widget.editingMessage != null) {
      _controller.text = widget.editingMessage!.text ?? '';
      _isComposing = _controller.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final isComposing = text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
      widget.onTypingChanged(isComposing);
    }
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;

    widget.onSendTextMessage(_controller.text.trim());
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    widget.onTypingChanged(false);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        widget.onSendImageMessage(File(picked.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachmentOption(
                icon: Icons.photo_library,
                color: Colors.purple,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _AttachmentOption(
                icon: Icons.camera_alt,
                color: Colors.pink,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return VoiceRecorderWidget(
        onRecordingCompleted: (file, duration) {
          setState(() {
            _isRecording = false;
          });
          widget.onSendAudioMessage(file, duration);
        },
        onCancel: () {
          setState(() {
            _isRecording = false;
          });
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.replyMessage != null)
          ReplyPreviewWidget(
            replyMessage: widget.replyMessage!,
            onCancel: widget.onCancelReply,
          ),
        if (widget.editingMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.withAlpha(40),
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Editing message',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: widget.onCancelEdit,
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: _showAttachmentSheet,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isComposing
                  ? CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: _handleSend,
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.mic, color: Colors.white, size: 20),
                        onPressed: () {
                          setState(() {
                            _isRecording = true;
                          });
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withAlpha(40),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
