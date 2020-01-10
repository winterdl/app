import 'author.dart';
import 'reference.dart';

class Quote {
  final Author author;
  final String id;
  final String name;
  final List<Reference> references;
  bool starred;
  final List<String> topics;

  Quote({
    this.author,
    this.id,
    this.name,
    this.references,
    this.starred = false,
    this.topics,
  });

  factory Quote.fromJSON(Map<String, dynamic> json) {
    List<Reference> refs = [];
    List<String> topicsList = [];

    if (json['references'] != null) {
      for (var ref in json['references']) {
        refs.add(Reference.fromJSON(ref));
      }
    }

    if (json['topics'] != null) {
      for (var tag in json['topics']) {
        topicsList.add(tag);
      }
    }

    return Quote(
      author: json['author'] != null ? Author.fromJSON(json['author']) : null,
      id: json['id'],
      name: json['name'],
      references: refs,
      starred: json['starred'] ?? false,
      topics: topicsList,
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();
    List<Map<String, dynamic>> refStr = [];

    for (var ref in references) {
      refStr.add(ref.toJSON());
    }

    json['author']      = author.toJSON();
    json['id']          = id;
    json['name']        = name;
    json['references']  = refStr;
    json['starred']     = starred;
    json['topics']      = topics;

    return json;
  }
}
