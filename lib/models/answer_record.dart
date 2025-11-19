import 'package:quiz_app/models/quiz_question.dart';

class AnswerRecord {
  const AnswerRecord({
    required this.question,
    this.selectedAnswer,
    required this.responseTime,
    this.timedOut = false,
  });

  final QuizQuestion question;
  final String? selectedAnswer;
  final Duration responseTime;
  final bool timedOut;

  bool get isCorrect => !timedOut && selectedAnswer == question.correctAnswer;
}

