import 'package:shared_preferences/shared_preferences.dart';

class ScoreSnapshot {
  const ScoreSnapshot({
    required this.bestScore,
    required this.bestAccuracy,
    required this.quizzesPlayed,
    required this.fastestCompletion,
    required this.lastScore,
  });

  final int bestScore;
  final double bestAccuracy;
  final int quizzesPlayed;
  final Duration fastestCompletion;
  final int lastScore;

  ScoreSnapshot copyWith({
    int? bestScore,
    double? bestAccuracy,
    int? quizzesPlayed,
    Duration? fastestCompletion,
    int? lastScore,
  }) {
    return ScoreSnapshot(
      bestScore: bestScore ?? this.bestScore,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      quizzesPlayed: quizzesPlayed ?? this.quizzesPlayed,
      fastestCompletion: fastestCompletion ?? this.fastestCompletion,
      lastScore: lastScore ?? this.lastScore,
    );
  }

  static ScoreSnapshot initial() => const ScoreSnapshot(
    bestScore: 0,
    bestAccuracy: 0.0,
    quizzesPlayed: 0,
    fastestCompletion: Duration.zero,
    lastScore: 0,
  );
}

class ScoreStorage {
  static const _bestScoreKey = 'best_score';
  static const _bestAccuracyKey = 'best_accuracy';
  static const _quizzesPlayedKey = 'quizzes_played';
  static const _fastestCompletionKey = 'fastest_completion_ms';
  static const _lastScoreKey = 'last_score';

  Future<ScoreSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final fastestMs = prefs.getInt(_fastestCompletionKey) ?? 0;

    return ScoreSnapshot(
      bestScore: prefs.getInt(_bestScoreKey) ?? 0,
      bestAccuracy: prefs.getDouble(_bestAccuracyKey) ?? 0.0,
      quizzesPlayed: prefs.getInt(_quizzesPlayedKey) ?? 0,
      fastestCompletion: Duration(milliseconds: fastestMs),
      lastScore: prefs.getInt(_lastScoreKey) ?? 0,
    );
  }

  Future<ScoreSnapshot> persistRun({
    required int correctAnswers,
    required int totalQuestions,
    required Duration totalDuration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final previous = await load();

    final accuracy = totalQuestions == 0
        ? 0.0
        : (correctAnswers / totalQuestions.toDouble()) * 100;

    final updated = previous.copyWith(
      lastScore: correctAnswers,
      quizzesPlayed: previous.quizzesPlayed + 1,
      bestScore: correctAnswers > previous.bestScore
          ? correctAnswers
          : previous.bestScore,
      bestAccuracy: accuracy > previous.bestAccuracy
          ? accuracy
          : previous.bestAccuracy,
      fastestCompletion: _resolveFastestDuration(
        previous.fastestCompletion,
        totalDuration,
      ),
    );

    await prefs.setInt(_lastScoreKey, updated.lastScore);
    await prefs.setInt(_quizzesPlayedKey, updated.quizzesPlayed);
    await prefs.setInt(_bestScoreKey, updated.bestScore);
    await prefs.setDouble(_bestAccuracyKey, updated.bestAccuracy);
    await prefs.setInt(
      _fastestCompletionKey,
      updated.fastestCompletion.inMilliseconds,
    );

    return updated;
  }

  Duration _resolveFastestDuration(
    Duration previousFastest,
    Duration candidate,
  ) {
    if (previousFastest == Duration.zero) {
      return candidate;
    }

    if (candidate == Duration.zero) {
      return previousFastest;
    }

    return candidate < previousFastest ? candidate : previousFastest;
  }
}
