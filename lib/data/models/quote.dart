class Quote {
  final int? id;
  final String text;
  final String quarterLabel;

  const Quote({
    this.id,
    required this.text,
    required this.quarterLabel,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'text': text,
      'quarter_label': quarterLabel,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'] as int?,
      text: map['text'] as String,
      quarterLabel: map['quarter_label'] as String,
    );
  }
}

class QuoteShownHistory {
  final int? id;
  final int quoteId;
  final int shownAt;

  const QuoteShownHistory({
    this.id,
    required this.quoteId,
    required this.shownAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'quote_id': quoteId,
      'shown_at': shownAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory QuoteShownHistory.fromMap(Map<String, dynamic> map) {
    return QuoteShownHistory(
      id: map['id'] as int?,
      quoteId: map['quote_id'] as int,
      shownAt: map['shown_at'] as int,
    );
  }
}
