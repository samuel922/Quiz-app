import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:quiz_app/answer_button.dart';
import 'package:quiz_app/models/answer_record.dart';
import 'package:quiz_app/models/quiz_question.dart';
import 'package:quiz_app/models/quiz_settings.dart';
import 'package:quiz_app/widgets/glass_panel.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.questions,
    required this.onAnswer,
    required this.settings,
  });

  final List<QuizQuestion> questions;
  final void Function(AnswerRecord record) onAnswer;
  final QuizSettings settings;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int currentQuestionIndex = 0;
  late DateTime _questionStart;
  Timer? _timer;
  double _timeLeftMs = 0;
  bool _hasAnsweredCurrent = false;
  List<String> _shuffledAnswers = [];

  @override
  void initState() {
    super.initState();
    _setupQuestionState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  QuizQuestion get _currentQuestion =>
      widget.questions[currentQuestionIndex];

  void _setupQuestionState() {
    _timer?.cancel();
    _questionStart = DateTime.now();
    _hasAnsweredCurrent = false;
    _timeLeftMs = widget.settings.questionDuration.inMilliseconds.toDouble();
    _shuffledAnswers = _currentQuestion.getShuffledAnswers();

    if (widget.settings.isTimedMode) {
      _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        setState(() {
          _timeLeftMs = (_timeLeftMs - 200).clamp(0, double.infinity);
        });

        if (_timeLeftMs <= 0) {
          timer.cancel();
          _handleAnswer(null, timedOut: true);
        }
      });
    }
  }

  void _handleAnswer(String? answer, {bool timedOut = false}) {
    if (_hasAnsweredCurrent) return;
    _hasAnsweredCurrent = true;
    _timer?.cancel();

    final responseTime = DateTime.now().difference(_questionStart);

    widget.onAnswer(
      AnswerRecord(
        question: _currentQuestion,
        selectedAnswer: answer,
        responseTime: responseTime,
        timedOut: timedOut,
      ),
    );

    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    if (!mounted) return;

    final isLastQuestion =
        currentQuestionIndex + 1 >= widget.questions.length;

    if (isLastQuestion) return;

    setState(() {
      currentQuestionIndex++;
    });

    _setupQuestionState();
  }

  @override
  Widget build(context) {
    if (currentQuestionIndex >= widget.questions.length) {
      return const SizedBox.shrink();
    }

    final progress =
        (currentQuestionIndex + 1) / widget.questions.length.toDouble();
    final timerProgress = widget.settings.isTimedMode
        ? _timeLeftMs / widget.settings.questionDuration.inMilliseconds
        : 1.0;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.questions.length}',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  if (widget.settings.isTimedMode) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Beat the clock',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${(_timeLeftMs / 1000).ceil()}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: timerProgress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        color:
                            timerProgress < 0.3 ? Colors.redAccent : Colors.cyan,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlassPanel(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.cyanAccent.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            _currentQuestion.category,
                            style: const TextStyle(
                              letterSpacing: 0.6,
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _difficultyIcon(_currentQuestion.difficulty),
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentQuestion.difficulty.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _currentQuestion.question,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _shuffledAnswers.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final answer = _shuffledAnswers[index];
                          return AnswerButton(
                            answer: answer,
                            isEnabled: !_hasAnsweredCurrent,
                            onTap: () => _handleAnswer(answer),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _difficultyIcon(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return Icons.self_improvement_outlined;
      case QuestionDifficulty.medium:
        return Icons.trending_up_outlined;
      case QuestionDifficulty.hard:
        return Icons.flash_on_outlined;
    }
  }
}
