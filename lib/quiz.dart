import 'package:flutter/material.dart';

import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/models/answer_record.dart';
import 'package:quiz_app/models/quiz_question.dart';
import 'package:quiz_app/models/quiz_settings.dart';
import 'package:quiz_app/questions_screen.dart';
import 'package:quiz_app/result_screen.dart';
import 'package:quiz_app/services/score_storage.dart';
import 'package:quiz_app/start_screen.dart';
import 'package:quiz_app/theme/app_theme.dart';

enum ActiveScreen { start, questions, results }

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final ScoreStorage _scoreStorage = ScoreStorage();
  ScoreSnapshot _scoreSnapshot = ScoreSnapshot.initial();
  final List<AnswerRecord> _answerLog = [];
  List<QuizQuestion> _activeQuestions = List.of(questions);
  QuizSettings _settings = QuizSettings.recommended(questions.length);
  ActiveScreen _activeScreen = ActiveScreen.start;
  int _runId = 0;
  bool _isLoadingScores = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final snapshot = await _scoreStorage.load();
    if (!mounted) return;
    setState(() {
      _scoreSnapshot = snapshot;
      _isLoadingScores = false;
    });
  }

  void _startQuiz(QuizSettings settings) {
    final shuffled = List.of(questions)..shuffle();
    final requestedCount = settings.questionCount.clamp(1, questions.length);
    setState(() {
      _settings = settings.copyWith(questionCount: requestedCount);
      _activeQuestions = shuffled.take(requestedCount).toList();
      _answerLog.clear();
      _activeScreen = ActiveScreen.questions;
      _runId++;
    });
  }

  Future<void> _handleAnswer(AnswerRecord record) async {
    _answerLog.add(record);
    if (_answerLog.length == _activeQuestions.length) {
      final totalDuration = _answerLog.fold<Duration>(
        Duration.zero,
        (duration, entry) => duration + entry.responseTime,
      );
      final correctAnswers = _answerLog
          .where((entry) => entry.isCorrect)
          .length;

      final updatedSnapshot = await _scoreStorage.persistRun(
        correctAnswers: correctAnswers,
        totalQuestions: _activeQuestions.length,
        totalDuration: totalDuration,
      );

      if (!mounted) return;

      setState(() {
        _scoreSnapshot = updatedSnapshot;
        _activeScreen = ActiveScreen.results;
      });
      return;
    }

    if (!mounted) return;
    setState(() {});
  }

  void _restartQuiz() {
    setState(() {
      _activeScreen = ActiveScreen.start;
      _answerLog.clear();
    });
  }

  void _playAgain() {
    _startQuiz(_settings);
  }

  @override
  Widget build(context) {
    Widget screenWidget = StartScreen(
      onStartQuiz: _startQuiz,
      scoreSnapshot: _scoreSnapshot,
      isLoadingSnapshot: _isLoadingScores,
      totalQuestionsAvailable: questions.length,
    );

    if (_activeScreen == ActiveScreen.questions) {
      screenWidget = QuestionsScreen(
        key: ValueKey(_runId),
        questions: _activeQuestions,
        onAnswer: _handleAnswer,
        settings: _settings,
      );
    } else if (_activeScreen == ActiveScreen.results) {
      screenWidget = ResultsScreen(
        answerLog: _answerLog,
        onRestart: _restartQuiz,
        onPlayAgain: _playAgain,
        snapshot: _scoreSnapshot,
        settings: _settings,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF160B33), Color(0xFF3A0CA3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: screenWidget,
            ),
          ),
        ),
      ),
    );
  }
}
