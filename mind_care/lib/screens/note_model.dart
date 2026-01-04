class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final String? audioPath;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.audioPath,
  });

  // Helper method to create a new Note based on an old one
  // This is very helpful when editing notes to keep the audioPath and ID safe
  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    String? audioPath,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  // Convert a Note into a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateTime': date.toIso8601String(),
      'audioPath': audioPath,
    };
  }

  // Extract a Note object from a Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(
        map['dateTime'] ?? map['date'] ?? DateTime.now().toIso8601String(),
      ),
      audioPath: map['audioPath'] as String?, // Explicitly cast as String?
    );
  }
}
