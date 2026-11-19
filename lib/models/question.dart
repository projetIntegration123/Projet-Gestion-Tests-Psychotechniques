/// Question telle que renvoyée par `POST /candidat/test/demarrer`
/// (la bonne réponse n'est jamais envoyée par le serveur).
class Question {
  final int id;
  final int position;
  final String text;
  final int points;

  /// Suite de nombres extraite de l'énoncé (vide si l'énoncé n'en contient pas).
  final List<String> sequence;

  /// Options dans l'ordre A, B, C, D.
  final List<String> options;

  Question({
    required this.id,
    required this.position,
    required this.text,
    required this.points,
    required this.sequence,
    required this.options,
  });

  factory Question.fromApi(Map<String, dynamic> json) {
    final opts = Map<String, dynamic>.from(json['options'] as Map);
    final ordered = ['A', 'B', 'C', 'D']
        .where((k) => opts[k] != null)
        .map((k) => '${opts[k]}')
        .toList();
    final enonce = '${json['enonce']}'.trim();
    final parsed = _splitSequence(enonce);
    return Question(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      text: parsed.$1,
      points: (json['points'] as num?)?.toInt() ?? 1,
      sequence: parsed.$2,
      options: ordered,
    );
  }

  /// « Quel nombre complète la suite : 3, 6, 12, ? » -> ("Quel nombre complète la suite ?", [3, 6, 12]).
  /// Si l'énoncé n'a pas ce format, il est affiché tel quel, sans suite.
  static (String, List<String>) _splitSequence(String enonce) {
    final i = enonce.indexOf(':');
    if (i > 0 && enonce.trimRight().endsWith('?')) {
      var tail = enonce.substring(i + 1).trim();
      tail = tail.substring(0, tail.length - 1).trim(); // retire le « ? » final
      if (tail.endsWith(',')) tail = tail.substring(0, tail.length - 1);
      final items = tail.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (items.length >= 3 && items.every((e) => e.length <= 8)) {
        return ('${enonce.substring(0, i).trim()} ?', items);
      }
    }
    return (enonce, const <String>[]);
  }
}

/// Contenu du test en cours (réponse de `/demarrer` et `/questions`).
class TestContent {
  final String title;
  final int durationMinutes;
  final int remainingSeconds;
  final List<Question> questions;

  /// Réponses déjà enregistrées (reprise après rafraîchissement) : index de question -> index de choix.
  final Map<int, int> answers;

  TestContent({
    required this.title,
    required this.durationMinutes,
    required this.remainingSeconds,
    required this.questions,
    required this.answers,
  });

  factory TestContent.fromApi(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((q) => Question.fromApi(Map<String, dynamic>.from(q as Map)))
        .toList();
    final saved = Map<String, dynamic>.from((json['reponses'] ?? const {}) as Map);
    final answers = <int, int>{};
    for (var i = 0; i < questions.length; i++) {
      final letter = saved['${questions[i].id}'];
      if (letter is String && letter.isNotEmpty) {
        final idx = letter.codeUnitAt(0) - 65;
        if (idx >= 0 && idx < questions[i].options.length) answers[i] = idx;
      }
    }
    return TestContent(
      title: '${json['titre'] ?? ''}',
      durationMinutes: (json['dureeMinutes'] as num).toInt(),
      remainingSeconds: (json['resteSecondes'] as num).toInt(),
      questions: questions,
      answers: answers,
    );
  }
}
