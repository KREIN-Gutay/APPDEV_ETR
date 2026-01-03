import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';

class EntryAct extends StatefulWidget {
  final String? emoji;
  const EntryAct({super.key, this.emoji});
  @override
  State<EntryAct> createState() => _EntryActState();
}

class _EntryActState extends State<EntryAct> {
  // TRACK SELECTED ACTIVITIES
  final Set<String> selectedActivities = {};
  final TextEditingController noteController = TextEditingController();
  File? imageFile;
  String selectedEmoji = "🙂";

  @override
  void initState() {
    super.initState();
    if (widget.emoji != null) {
      selectedEmoji = widget.emoji!;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Text(selectedEmoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 10),

            /// ------------------------------------------------
            /// WHITE ACTIVITY CARD
            /// ------------------------------------------------
            ///
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What did you do today?",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.count(
                    crossAxisCount: 5, // 5 icons per row
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1, // ensures perfect square/circle
                    children: [
                      activityItem(Icons.family_restroom, "family"),
                      activityItem(Icons.groups, "friends"),
                      activityItem(Icons.favorite, "lover"),
                      activityItem(Icons.fitness_center, "exercise"),
                      activityItem(Icons.sports_soccer, "sport"),
                      activityItem(Icons.bed, "sleep"),
                      activityItem(Icons.restaurant, "eat"),
                      activityItem(Icons.beach_access, "vacation"),
                      activityItem(Icons.movie, "movies"),
                      activityItem(Icons.menu_book, "read"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ------------------------------------------------
            /// NOTE SECTION
            /// ------------------------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Note",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Add note...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// ------------------------------------------------
            /// PHOTO SECTION
            /// ------------------------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Photo",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                const SizedBox(height: 10),

                // 👇 PUT IT HERE (image preview)
                if (imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imageFile!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: pickImage, // make sure this is connected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Tap to Add Photo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// ------------------------------------------------
            /// SAVE BUTTON (BOTTOM)
            /// ------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final data = {
                    "emoji": selectedEmoji,
                    "activities": selectedActivities.join(","),
                    "note": noteController.text,
                    "imagePath": imageFile?.path,
                    "date": DateTime.now().toIso8601String(),
                  };

                  await DBHelper.insertEntry(data);
                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  final Color selectedBg = const Color.fromARGB(
    255,
    59,
    129,
    248,
  ).withOpacity(0.2);

  /// ------------------------------------------------
  /// ACTIVITY ITEM (PRESSABLE + SELECTABLE + ANIMATED)
  /// ------------------------------------------------
  Widget activityItem(IconData icon, String label) {
    bool isSelected = selectedActivities.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedActivities.remove(label);
          } else {
            selectedActivities.add(label);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 60, // fixed width
        height: 60, // fixed height
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? selectedBg : Colors.transparent,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: Colors.blue),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
