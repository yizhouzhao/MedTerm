enum BodySystem {
  digestive,
  respiratory,
  cardiovascular,
  nervous,
  musculoskeletal,
  integumentary,
  endocrine,
  lymphatic,
  urinary,
  reproductive,
  sensory,
  immune,
  general,
  
}

class MedWord {
  final String word;
  final String prefix;
  final String root;
  final String suffix;
  final String meaning;
  final String explanation;
  final String chineseTranslation;
  final BodySystem category;

  const MedWord({
    required this.word,
    required this.prefix,
    required this.root,
    required this.suffix,
    required this.meaning,
    required this.explanation,
    required this.chineseTranslation,
    required this.category,
  });

  // Create a copy of the MedWord with some fields updated
  MedWord copyWith({
    String? word,
    String? prefix,
    String? root,
    String? suffix,
    String? meaning,
    String? explanation,
    String? chineseTranslation,
    BodySystem? category,
  }) {
    return MedWord(
      word: word ?? this.word,
      prefix: prefix ?? this.prefix,
      root: root ?? this.root,
      suffix: suffix ?? this.suffix,
      meaning: meaning ?? this.meaning,
      explanation: explanation ?? this.explanation,
      chineseTranslation: chineseTranslation ?? this.chineseTranslation,
      category: category ?? this.category,
    );
  }

  // Convert MedWord to a Map
  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'prefix': prefix,
      'root': root,
      'suffix': suffix,
      'meaning': meaning,
      'explanation': explanation,
      'chineseTranslation': chineseTranslation,
      'category': category.name,
    };
  }

  // Create MedWord from a Map
  factory MedWord.fromMap(Map<String, dynamic> map) {
    return MedWord(
      word: map['word'] as String,
      prefix: map['prefix'] as String,
      root: map['root'] as String,
      suffix: map['suffix'] as String,
      meaning: map['meaning'] as String,
      explanation: map['explanation'] as String,
      chineseTranslation: map['chineseTranslation'] as String,
      category: BodySystem.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => BodySystem.general,
      ),
    );
  }

  @override
  String toString() {
    return 'MedWord(word: $word, prefix: $prefix, root: $root, suffix: $suffix, meaning: $meaning, explanation: $explanation, chineseTranslation: $chineseTranslation, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MedWord &&
      other.word == word &&
      other.prefix == prefix &&
      other.root == root &&
      other.suffix == suffix &&
      other.meaning == meaning &&
      other.explanation == explanation &&
      other.chineseTranslation == chineseTranslation &&
      other.category == category;
  }

  @override
  int get hashCode {
    return word.hashCode ^
      prefix.hashCode ^
      root.hashCode ^
      suffix.hashCode ^
      meaning.hashCode ^
      explanation.hashCode ^
      chineseTranslation.hashCode ^
      category.hashCode;
  }
}

// final word = MedWord(
//   word: 'Cardiology',
//   prefix: 'Cardio',
//   root: 'log',
//   suffix: 'y',
//   meaning: 'Study of the heart',
//   explanation: 'Cardio- means heart, -logy means study of',
//   chineseTranslation: '心脏病学',
//   category: BodySystem.cardiovascular,
// );
