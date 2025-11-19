import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/models/answer_record.dart';

class QuestionsSummary extends StatelessWidget {
  const QuestionsSummary({super.key, required this.records});

  final List<AnswerRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(4),
      itemCount: records.length,
      separatorBuilder: (context, _) => const Divider(
        color: Colors.white10,
        height: 24,
      ),
      itemBuilder: (context, index) {
        final record = records[index];
        final isCorrect = record.isCorrect;
        final userAnswer =
            record.selectedAnswer ?? (record.timedOut ? 'No answer' : '—');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  isCorrect ? Colors.greenAccent : Colors.redAccent,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.question.question,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your answer: $userAnswer',
                    style: GoogleFonts.lato(
                      color: isCorrect
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Correct: ${record.question.correctAnswer}',
                    style: GoogleFonts.lato(color: Colors.white70),
                  ),
                  if (record.question.fact.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      record.question.fact,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
