import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mind_care/screens/calendar_state.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';
//import '../calendar_state.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime get currentDate => selectedDate.value;
  DateTime _activeSelectedDay = selectedDate.value;
  DateTime displayedMonth = DateTime(
    selectedDate.value.year,
    selectedDate.value.month,
  );

  void _refreshData() {
    setState(() {});
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _activeSelectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _activeSelectedDay = picked;
        displayedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _deleteNote(int id) async {
    await DBHelper.deleteEntry(id);
    _refreshData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Entry deleted"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- NEW: Modal for Add/Edit/View ---
  void _showEntryModal({Map<String, dynamic>? entry}) {
    final bool isEditing = entry != null;
    final TextEditingController titleController = TextEditingController(
      text: isEditing ? entry['title'] : "",
    );
    final TextEditingController contentController = TextEditingController(
      text: isEditing ? entry['content'] : "",
    );
    String selectedEmoji = isEditing ? entry['emoji'] : "📝";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? "Edit Entry" : "New Entry",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Title",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "How was your day?",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: () async {
                  final data = {
                    'title': titleController.text,
                    'content': contentController.text,
                    'emoji': selectedEmoji,
                    'date': DateFormat('yyyy-MM-dd').format(_activeSelectedDay),
                  };

                  if (isEditing) {
                    await DBHelper.updateEntry(entry['id'], data);
                  } else {
                    await DBHelper.insertEntry(data);
                  }

                  if (mounted) Navigator.pop(context);
                  _refreshData();
                },
                child: Text(
                  isEditing ? "Update Note" : "Save Note",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGlassContainer({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
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
    int daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;
    int firstWeekday = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    ).weekday;
    int startOffset = firstWeekday % 7;
    int totalItems = startOffset + daysInMonth;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Journal Calendar",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 40, 20, 20),
          children: [
            buildGlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat("MMMM yyyy").format(displayedMonth),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "S",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "M",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "T",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "W",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "T",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "F",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          "S",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalItems,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        if (index < startOffset) return const SizedBox();
                        int day = index - startOffset + 1;
                        DateTime thisDay = DateTime(
                          displayedMonth.year,
                          displayedMonth.month,
                          day,
                        );
                        bool isSelected =
                            thisDay.year == _activeSelectedDay.year &&
                            thisDay.month == _activeSelectedDay.month &&
                            thisDay.day == _activeSelectedDay.day;
                        bool isToday =
                            thisDay.year == DateTime.now().year &&
                            thisDay.month == DateTime.now().month &&
                            thisDay.day == DateTime.now().day;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _activeSelectedDay = thisDay),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : (isToday
                                        ? Colors.blueAccent.withOpacity(0.2)
                                        : Colors.transparent),
                              borderRadius: BorderRadius.circular(12),
                              border: isToday
                                  ? Border.all(
                                      color: Colors.blueAccent,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Entries for ${DateFormat("MMM d").format(_activeSelectedDay)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showEntryModal(), // --- CHANGED: Open Modal for Add ---
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Note"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper.getEntriesByDate(
                DateFormat('yyyy-MM-dd').format(_activeSelectedDay),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return buildGlassContainer(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "No entries for this day.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = snapshot.data![index];
                    return GestureDetector(
                      onTap: () => _showEntryModal(
                        entry: entry,
                      ), // --- CHANGED: Tap list to view/edit ---
                      child: buildEntryTile(entry),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEntryTile(Map<String, dynamic> entry) {
    return buildGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Text(
          entry['emoji'] ?? "📝",
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          entry['title'] ?? "Untitled",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          entry['content'] ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEntryModal(
                entry: entry,
              ), // --- CHANGED: Modal for Edit ---
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _deleteNote(entry['id']),
            ),
          ],
        ),
      ),
    );
  }
}
