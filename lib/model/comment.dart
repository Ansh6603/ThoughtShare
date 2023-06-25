class Comment {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String url;

  Comment({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.url,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      title: map['title'],
      thumbnailUrl: map['thumbnailUrl'],
      url: map['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'url': url,
    };
  }
}
