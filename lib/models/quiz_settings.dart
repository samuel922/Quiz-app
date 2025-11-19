class QuizSettings {
  const QuizSettings({
    required this.isTimedMode,
    required this.questionDuration,
    required this.questionCount,
  });

  final bool isTimedMode;
  final Duration questionDuration;
  final int questionCount;

  QuizSettings copyWith({
    bool? isTimedMode,
    Duration? questionDuration,
    int? questionCount,
  }) {
    return QuizSettings(
      isTimedMode: isTimedMode ?? this.isTimedMode,
      questionDuration: questionDuration ?? this.questionDuration,
      questionCount: questionCount ?? this.questionCount,
    );
  }

  factory QuizSettings.recommended(int totalQuestions) {
    return QuizSettings(
      isTimedMode: true,
      questionDuration: const Duration(seconds: 18),
      questionCount: totalQuestions,
    );
  }

  factory QuizSettings.relaxed(int totalQuestions) {
    return QuizSettings(
      isTimedMode: false,
      questionDuration: const Duration(seconds: 25),
      questionCount: totalQuestions,
    );
  }
}

