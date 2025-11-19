import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:quiz_app/models/quiz_settings.dart';
import 'package:quiz_app/services/score_storage.dart';
import 'package:quiz_app/widgets/glass_panel.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({
    super.key,
    required this.onStartQuiz,
    required this.scoreSnapshot,
    required this.isLoadingSnapshot,
    required this.totalQuestionsAvailable,
  });

  final void Function(QuizSettings settings) onStartQuiz;
  final ScoreSnapshot scoreSnapshot;
  final bool isLoadingSnapshot;
  final int totalQuestionsAvailable;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late QuizSettings _draftSettings;

  final List<int> _durationOptions = [12, 18, 25];

  @override
  void initState() {
    super.initState();
    _draftSettings = QuizSettings.recommended(widget.totalQuestionsAvailable);
  }

  void _toggleTimedMode(bool value) {
    setState(() {
      _draftSettings = _draftSettings.copyWith(isTimedMode: value);
    });
  }

  void _updateDuration(int seconds) {
    setState(() {
      _draftSettings = _draftSettings.copyWith(
        questionDuration: Duration(seconds: seconds),
      );
    });
  }

  void _updateQuestionCount(double value) {
    setState(() {
      _draftSettings = _draftSettings.copyWith(questionCount: value.round());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bestAccuracy = widget.scoreSnapshot.bestAccuracy.toStringAsFixed(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 760;

        final hero = Column(
          children: [
            Image.asset(
              'assets/images/quiz-logo.png',
              width: isWide ? 260 : 220,
              color: const Color.fromARGB(160, 255, 255, 255),
            ),
            const SizedBox(height: 28),
            Text(
              'Level up your Flutter knowledge',
              style: GoogleFonts.lato(
                fontSize: isWide ? 32 : 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Curated drills • Progress tracking • Timed challenges',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

        final statsPanel = GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: _ScoreHighlights(
            snapshot: widget.scoreSnapshot,
            isLoading: widget.isLoadingSnapshot,
            bestAccuracy: bestAccuracy,
          ),
        );

        final settingsPanel = GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: _buildSettingsCard(context),
        );

        final cta = Align(
          child: FilledButton.icon(
            onPressed: () => widget.onStartQuiz(_draftSettings),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Challenge'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 18),
            ),
          ),
        );

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 28,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                hero,
                const SizedBox(height: 32),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: statsPanel),
                      const SizedBox(width: 24),
                      Expanded(child: settingsPanel),
                    ],
                  )
                else ...[
                  statsPanel,
                  const SizedBox(height: 22),
                  settingsPanel,
                ],
                const SizedBox(height: 28),
                cta,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final minQuestions = 3;
    final maxQuestions = widget.totalQuestionsAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Settings',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _draftSettings.isTimedMode,
          onChanged: _toggleTimedMode,
          title: const Text('Timed mode'),
          subtitle: const Text('Beat the clock each question'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _draftSettings.isTimedMode ? 1 : 0.3,
          child: IgnorePointer(
            ignoring: !_draftSettings.isTimedMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Per-question timer',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _durationOptions.map((seconds) {
                    final isSelected =
                        _draftSettings.questionDuration.inSeconds == seconds;
                    return ChoiceChip(
                      label: Text('${seconds}s'),
                      selected: isSelected,
                      onSelected: (_) => _updateDuration(seconds),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.white24, height: 32),
        Text(
          'Questions per run: ${_draftSettings.questionCount}',
          style: GoogleFonts.lato(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _draftSettings.questionCount
              .clamp(minQuestions, maxQuestions)
              .toDouble(),
          onChanged: maxQuestions > minQuestions ? _updateQuestionCount : null,
          min: minQuestions.toDouble(),
          max: maxQuestions.toDouble(),
          divisions:
              maxQuestions > minQuestions ? (maxQuestions - minQuestions) : null,
          label: '${_draftSettings.questionCount}',
        ),
      ],
    );
  }
}

class _ScoreHighlights extends StatelessWidget {
  const _ScoreHighlights({
    required this.snapshot,
    required this.isLoading,
    required this.bestAccuracy,
  });

  final ScoreSnapshot snapshot;
  final bool isLoading;
  final String bestAccuracy;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth > 520;
        final children = [
          _StatChip(
            label: 'Best score',
            value: snapshot.bestScore.toString(),
            icon: Icons.emoji_events_outlined,
          ),
          _StatChip(
            label: 'Accuracy',
            value: '$bestAccuracy%',
            icon: Icons.bolt_outlined,
          ),
          _StatChip(
            label: 'Quizzes',
            value: snapshot.quizzesPlayed.toString(),
            icon: Icons.repeat_rounded,
          ),
        ];

        if (horizontal) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children,
          );
        }

        return Column(
          children: children
              .map((chip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: chip,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
