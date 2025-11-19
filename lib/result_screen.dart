import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:quiz_app/models/answer_record.dart';
import 'package:quiz_app/models/quiz_settings.dart';
import 'package:quiz_app/questions_summary.dart';
import 'package:quiz_app/services/score_storage.dart';
import 'package:quiz_app/widgets/glass_panel.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.answerLog,
    required this.onRestart,
    required this.onPlayAgain,
    required this.snapshot,
    required this.settings,
  });

  final List<AnswerRecord> answerLog;
  final VoidCallback onRestart;
  final VoidCallback onPlayAgain;
  final ScoreSnapshot snapshot;
  final QuizSettings settings;

  @override
  Widget build(context) {
    final correctAnswers = answerLog.where((entry) => entry.isCorrect).length;
    final totalQuestions = answerLog.length;
    final accuracy = totalQuestions == 0
        ? 0.0
        : (correctAnswers / totalQuestions.toDouble()) * 100;
    final totalDuration = answerLog.fold<Duration>(
      Duration.zero,
      (sum, entry) => sum + entry.responseTime,
    );
    final avgSeconds = totalQuestions == 0
        ? 0.0
        : totalDuration.inMilliseconds / totalQuestions / 1000;
    final summaryMessage = _buildHeadline(accuracy);
    final streak = _longestCorrectStreak();

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GlassPanel(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              child: Column(
                children: [
                  Text(
                    summaryMessage,
                    style: GoogleFonts.lato(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You nailed $correctAnswers of $totalQuestions questions',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassPanel(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              child: _ResultStatsRow(
                accuracy: accuracy,
                avgSeconds: avgSeconds,
                bestScore: snapshot.bestScore,
                streak: streak,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 16,
                ),
                child: QuestionsSummary(records: answerLog),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play again'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to start'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Fastest run: ${_formatDuration(snapshot.fastestCompletion)} • Timed mode: ${settings.isTimedMode ? 'On' : 'Off'}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _buildHeadline(double accuracy) {
    if (accuracy >= 90) return 'Incredible accuracy!';
    if (accuracy >= 70) return 'Strong run!';
    if (accuracy >= 50) return 'Nice progress!';
    return 'Keep practicing!';
  }

  int _longestCorrectStreak() {
    var current = 0;
    var best = 0;
    for (final record in answerLog) {
      if (record.isCorrect) {
        current++;
        best = current > best ? current : best;
      } else {
        current = 0;
      }
    }
    return best;
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '—';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}

class _ResultStatsRow extends StatelessWidget {
  const _ResultStatsRow({
    required this.accuracy,
    required this.avgSeconds,
    required this.bestScore,
    required this.streak,
  });

  final double accuracy;
  final double avgSeconds;
  final int bestScore;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ResultChip(
          label: 'Accuracy',
          value: '${accuracy.toStringAsFixed(1)}%',
          icon: Icons.check_circle_outline,
        ),
        _ResultChip(
          label: 'Avg speed',
          value: '${avgSeconds.toStringAsFixed(1)}s',
          icon: Icons.speed_rounded,
        ),
        _ResultChip(
          label: 'Best score',
          value: '$bestScore',
          icon: Icons.emoji_events_outlined,
        ),
        _ResultChip(
          label: 'Streak',
          value: '$streak',
          icon: Icons.local_fire_department_outlined,
        ),
      ],
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
