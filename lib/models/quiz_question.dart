enum QuestionDifficulty { easy, medium, hard }

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.possibleAnswers,
    required this.category,
    this.difficulty = QuestionDifficulty.easy,
    this.fact = '',
  });

  final String id;
  final String question;
  final List<String> possibleAnswers;
  final String category;
  final QuestionDifficulty difficulty;
  final String fact;

  String get correctAnswer => possibleAnswers.first;

  List<String> getShuffledAnswers() {
    final shuffledAnswers = List.of(possibleAnswers);
    shuffledAnswers.shuffle();

    return shuffledAnswers;
  }
}