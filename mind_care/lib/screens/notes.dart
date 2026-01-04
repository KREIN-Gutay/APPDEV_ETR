import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:mind_care/screens/home.dart';
import 'package:mind_care/screens/analytics.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';
import 'package:mind_care/screens/profile.dart';
import 'note_model.dart';
import 'add_note.dart';
import 'view_edit_note.dart';

class Notes extends StatefulWidget {
  final String userName;

  const Notes({super.key, required this.userName});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final int _currentIndex = 2; // Notes tab
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Fetch notes from the database
  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await DBHelper.getNotes();
      if (mounted) {
        setState(() {
          _notes = data.map((item) => Note.fromMap(item)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading notes: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Journal Entries'),
        centerTitle: true,
        backgroundColor: const Color(0xFFCFDEF3),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(221, 77, 110, 185),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 80,
                        color: Colors.blueAccent.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your journal is empty.\nTap + to start journaling.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10, bottom: 150),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewEditNoteScreen(
                                      note: note,
                                      index: index,
                                    ),
                                  ),
                                );

                                if (result == null) return;

                                if (result["action"] == "delete") {
                                  await DBHelper.deleteNote(note.id!);
                                } else if (result["action"] == "edit") {
                                  final updatedNote = result["note"] as Note;
                                  await DBHelper.updateNote(
                                    updatedNote.id!,
                                    updatedNote.toMap(),
                                  );
                                }
                                _loadNotes();
                              },
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  // Play icon appears if audioPath is not null
                                  if (note.audioPath != null)
                                    const Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: Colors.blueAccent,
                                      size: 24,
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.black45,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                onSelected: (value) async {
                                  if (value == "delete") {
                                    await DBHelper.deleteNote(note.id!);
                                    _loadNotes();
                                  } else if (value == "edit") {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ViewEditNoteScreen(
                                          note: note,
                                          index: index,
                                        ),
                                      ),
                                    );
                                    _loadNotes();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: "edit",
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text("Edit"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice Journaling Button
            _buildQuickActionButton(
              icon: Icons.mic_rounded,
              label: "Voice Entry",
              color: Colors.deepPurpleAccent,
              onTap: () async {
                // Navigate to AddNoteScreen (Voice mode logic handled there)
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                );
                if (result != null && result is Note) {
                  await DBHelper.insertNote(result.toMap());
                  await _loadNotes();
                }
              },
            ),
            const SizedBox(height: 12),
            // Text Journaling Button
            _buildQuickActionButton(
              icon: Icons.add_rounded,
              label: "New Entry",
              color: Colors.blueAccent[700]!,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                );
                if (result != null && result is Note) {
                  await DBHelper.insertNote(result.toMap());
                  await _loadNotes();
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Helper to build consistent action buttons
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: color,
            elevation: 0,
            shape: const CircleBorder(),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.white.withOpacity(0.7),
            elevation: 0,
            unselectedItemColor: Colors.black38,
            selectedItemColor: Colors.blueAccent[700],
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == _currentIndex) return;
              Widget nextScreen;
              switch (index) {
                case 0:
                  nextScreen = Home(userName: widget.userName);
                  break;
                case 1:
                  nextScreen = Analytics(userName: widget.userName);
                  break;
                case 3:
                  nextScreen = Profile(userName: widget.userName);
                  break;
                default:
                  return;
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => nextScreen),
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_rounded),
                label: "Analytics",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sticky_note_2_rounded),
                label: "Notes",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
