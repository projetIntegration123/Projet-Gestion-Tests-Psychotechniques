import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

/// Erreur renvoyée par l'API (`{ "message": "..." }`) ou réseau.
class ApiException implements Exception {
  final int status; // 0 = serveur injoignable
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

/// Infos de la session candidat (login + `GET /candidat/test`).
class CandidateSession {
  final String candidateName;
  final String title;
  final String description;
  final int durationMin;
  final int questionCount;

  /// invite | en_cours | termine | expire
  final String status;
  final int? remainingSeconds;

  CandidateSession({
    required this.candidateName,
    required this.title,
    required this.description,
    required this.durationMin,
    required this.questionCount,
    required this.status,
    this.remainingSeconds,
  });
}

/// Résultat renvoyé par `/soumettre` et `/resultat`.
class TestResult {
  final String title;
  final bool scoreVisible;
  final int? score;
  final int? scoreMax;
  TestResult({required this.title, required this.scoreVisible, this.score, this.scoreMax});

  factory TestResult.fromApi(Map<String, dynamic> d) => TestResult(
        title: '${d['titre'] ?? ''}',
        scoreVisible: d['scoreVisible'] == true,
        score: (d['score'] as num?)?.toInt(),
        scoreMax: (d['scoreMax'] as num?)?.toInt(),
      );
}

class ApiService {
  /// Surchargeable : flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api');

  String? _token;
  bool get isLoggedIn => _token != null;

  Future<Map<String, dynamic>> _request(String method, String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    http.Response res;
    try {
      final call = switch (method) {
        'GET' => http.get(uri, headers: headers),
        'PUT' => http.put(uri, headers: headers, body: jsonEncode(body ?? {})),
        _ => http.post(uri, headers: headers, body: jsonEncode(body ?? {})),
      };
      res = await call.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException(0, 'Le serveur met trop de temps à répondre. Réessayez.');
    } catch (_) {
      throw ApiException(0, 'Impossible de joindre le serveur. Vérifiez votre connexion.');
    }
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, '${data['message'] ?? 'Erreur serveur (${res.statusCode})'}');
    }
    return data;
  }

  /// POST /candidat/auth/login { cle } puis GET /candidat/test.
  Future<CandidateSession> access(String key) async {
    final login = await _request('POST', '/candidat/auth/login', body: {'cle': key.trim()});
    _token = login['token'] as String;
    final t = await _request('GET', '/candidat/test');
    return CandidateSession(
      candidateName: '${t['candidat'] ?? login['candidat']?['nom'] ?? ''}',
      title: '${t['titre'] ?? ''}',
      description: '${t['description'] ?? ''}',
      durationMin: (t['dureeMinutes'] as num).toInt(),
      questionCount: (t['nbQuestions'] as num).toInt(),
      status: '${t['statut'] ?? login['statut']}',
      remainingSeconds: (t['resteSecondes'] as num?)?.toInt(),
    );
  }

  /// POST /candidat/test/demarrer — lance le chrono (une seule fois côté serveur)
  /// et peut être rappelé pour reprendre un test en cours.
  Future<TestContent> start() async => TestContent.fromApi(await _request('POST', '/candidat/test/demarrer'));

  /// PUT /candidat/test/reponses/:questionId { choix: "A" }
  Future<void> saveAnswer(int questionId, int choiceIndex) =>
      _request('PUT', '/candidat/test/reponses/$questionId', body: {'choix': String.fromCharCode(65 + choiceIndex)});

  /// POST /candidat/test/soumettre
  Future<TestResult> submit() async => TestResult.fromApi(await _request('POST', '/candidat/test/soumettre'));

  /// GET /candidat/test/resultat
  Future<TestResult> result() async => TestResult.fromApi(await _request('GET', '/candidat/test/resultat'));
}
