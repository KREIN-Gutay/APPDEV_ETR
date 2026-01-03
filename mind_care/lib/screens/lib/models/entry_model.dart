class EntryModel {
  final int? id;
  final String emoji;
  final String title;
  final String content;
  final String? imagePath;
  final String date;

  EntryModel({
    this.id,
    required this.emoji,
    required this.title,
    required this.content,
    this.imagePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emoji': emoji,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'date': date,
    };
  }
}
