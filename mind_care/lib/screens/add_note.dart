import 'dart:ui';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'note_model.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Audio & Speech objects
  late stt.SpeechToText _speech;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isListening = false;
  bool _isPlaying = false;
  String? _audioPath;
  double _speechStartTimestamp = 0;
  String _emotionalInsight = "";
  double _soundLevel = 0.0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Listen for player completion to reset UI
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() => _isPlaying = false);
    });
  }

  void _listen() async {
    if (!_isListening) {
      try {
        // 1. Initialize Speech
        bool speechAvailable = await _speech.initialize(
          onStatus: (val) => debugPrint('Status: $val'),
          onError: (val) => setState(() => _isListening = false),
        );

        // 2. Check Microphone Permissions for Recorder
        if (await _audioRecorder.hasPermission() && speechAvailable) {
          final directory = await getApplicationDocumentsDirectory();
          // Create a temporary path for the recording
          final String tempPath =
              '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

          setState(() {
            _isListening = true;
            _audioPath = tempPath; // Store path locally
            _speechStartTimestamp = DateTime.now().millisecondsSinceEpoch
                .toDouble();
          });

          // Start Recording Audio File
          await _audioRecorder.start(const RecordConfig(), path: tempPath);

          // Start Transcribing
          _speech.listen(
            onResult: (val) =>
                setState(() => _contentController.text = val.recognizedWords),
            onSoundLevelChange: (level) => setState(() => _soundLevel = level),
          );
        }
      } catch (e) {
        debugPrint("Recording error: $e");
      }
    } else {
      _stopAll();
    }
  }

  void _stopAll() async {
    // The stop() method returns the final path where the file was saved
    final path = await _audioRecorder.stop();
    _speech.stop();

    setState(() {
      _isListening = false;
      _audioPath = path; // Ensure we use the path returned by the recorder
      _soundLevel = 0.0;
    });
    _analyzeTone();
  }

  void _togglePlayback() async {
    if (_audioPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // Use DeviceFileSource for local file paths
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _cancelListening() async {
    await _audioRecorder.stop();
    _speech.cancel();
    setState(() {
      _isListening = false;
      _audioPath = null;
      _contentController.clear();
    });
  }

  void _analyzeTone() {
    if (_contentController.text.isEmpty) return;
    final durationSeconds =
        (DateTime.now().millisecondsSinceEpoch - _speechStartTimestamp) / 1000;
    final words = _contentController.text
        .split(' ')
        .where((w) => w.isNotEmpty)
        .length;
    if (durationSeconds < 1) return;
    final wpm = (words / durationSeconds) * 60;

    setState(() {
      if (wpm > 180) {
        _emotionalInsight =
            "\n\n[Insight: You spoke rapidly (${wpm.toStringAsFixed(0)} WPM).]";
      } else if (words > 5) {
        _emotionalInsight = "\n\n[Insight: Your pace was calm.]";
      }
    });
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        double height =
            5 + (math.Random().nextDouble() * _soundLevel.abs() * 5);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: _isListening ? height.clamp(5, 40) : 5,
          decoration: BoxDecoration(
            color: _isListening
                ? Colors.redAccent
                : Colors.blueAccent.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget buildGlassField({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("New Journal Entry"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                buildGlassField(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Audio Preview Strip
                if (_isListening || _audioPath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: buildGlassField(
                      height: 70,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isListening
                                  ? Icons.graphic_eq
                                  : (_isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill),
                            ),
                            color: _isListening
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            onPressed: _isListening ? null : _togglePlayback,
                          ),
                          Expanded(child: _buildWaveform()),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: Stack(
                    children: [
                      buildGlassField(
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: "Speak or type...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: ScaleTransition(
                          scale: _isListening
                              ? _pulseController.drive(
                                  Tween(begin: 1.0, end: 1.1),
                                )
                              : const AlwaysStoppedAnimation(1.0),
                          child: FloatingActionButton(
                            onPressed: _listen,
                            backgroundColor: _isListening
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            child: Icon(_isListening ? Icons.stop : Icons.mic),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent[700],
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    final String contentText = _contentController.text.trim();
                    // Allow saving if there is either content OR a recording
                    if (contentText.isEmpty && _audioPath == null) return;

                    final newNote = Note(
                      title: _titleController.text.isEmpty
                          ? "Untitled"
                          : _titleController.text,
                      content: contentText + _emotionalInsight,
                      date: DateTime.now(),
                      audioPath:
                          _audioPath, // This passes the path to the database logic
                    );
                    Navigator.pop(context, newNote);
                  },
                  child: const Text(
                    "Save Entry",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
