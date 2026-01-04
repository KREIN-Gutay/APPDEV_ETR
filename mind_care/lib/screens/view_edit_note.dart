import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:mind_care/screens/note_model.dart';
import 'services/gemini_service.dart';
import 'package:audioplayers/audioplayers.dart'; // Added for audio playback

class ViewEditNoteScreen extends StatefulWidget {
  final Note note;
  final int index;

  const ViewEditNoteScreen({
    super.key,
    required this.note,
    required this.index,
  });

  @override
  State<ViewEditNoteScreen> createState() => _ViewEditNoteScreenState();
}

class _ViewEditNoteScreenState extends State<ViewEditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool isEditing = false;
  bool _isAnalyzing = false;

  // Audio Player State
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);

    // Initialize Audio Player if a recording exists
    _audioPlayer = AudioPlayer();
    if (widget.note.audioPath != null) {
      _setupAudioListeners();
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _position = Duration.zero);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _audioPlayer.dispose(); // Always dispose the player
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.note.audioPath!));
    }
  }

  // Helper for glass containers
  Widget buildGlassContainer({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // AI Analysis Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blueAccent,
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.blueAccent,
                    ),
              onPressed: _isAnalyzing
                  ? null
                  : () async {
                      setState(() => _isAnalyzing = true);
                      final result = await GeminiService.analyzeEmotion(
                        _contentController.text,
                      );
                      setState(() => _isAnalyzing = false);

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black26,
                        isScrollControlled: true,
                        builder: (_) => _buildAnalysisSheet(context, result),
                      );
                    },
            ),
          ),
          // Edit/Save Button
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(
                isEditing
                    ? Icons.check_circle_rounded
                    : Icons.edit_note_rounded,
                color: isEditing ? Colors.green : Colors.black87,
              ),
              onPressed: () {
                if (isEditing) {
                  Navigator.pop(context, {
                    "action": "edit",
                    "note": Note(
                      id: widget.note.id, // Preserve ID
                      title: _titleController.text,
                      content: _contentController.text,
                      date: widget.note.date,
                      audioPath: widget.note.audioPath, // Preserve Audio
                    ),
                    "index": widget.index,
                  });
                }
                setState(() => isEditing = !isEditing);
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                buildGlassContainer(
                  child: TextField(
                    controller: _titleController,
                    enabled: isEditing,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Untitled Note",
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- AUDIO PLAYER SECTION ---
                if (widget.note.audioPath != null) ...[
                  buildGlassContainer(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                          onPressed: _togglePlayback,
                        ),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.blueAccent,
                            inactiveColor: Colors.blueAccent.withOpacity(0.2),
                            min: 0,
                            max: _duration.inSeconds.toDouble(),
                            value: _position.inSeconds.toDouble(),
                            onChanged: (value) async {
                              final position = Duration(seconds: value.toInt());
                              await _audioPlayer.seek(position);
                            },
                          ),
                        ),
                        Text(
                          "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ---------------------------
                Expanded(
                  child: buildGlassContainer(
                    child: TextField(
                      controller: _contentController,
                      enabled: isEditing,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Your thoughts here...",
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.6,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSheet(BuildContext context, String text) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Text(
                    "AI Emotion Insight",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Note: This is an AI-generated suggestion to support your reflection, not professional clinical advice.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
