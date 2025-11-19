import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/questions_summary.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.chosenAnswers, required this.restartQuiz});

  final List<String> chosenAnswers;
  final void Function() restartQuiz;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];

    for (var i = 0; i < chosenAnswers.length; i++) {
      summary.add({
        'question_index': i,
        'question': questions[i].question,
        'correct_answer': questions[i].possibleAnswers[0],
        'user_answer': chosenAnswers[i]
      });
    }
    return summary;
  }

  @override
  Widget build(context) {
    final summaryData = getSummaryData();
    final totalNoOfQuestions = questions.length;
    final totalCorrectlyAnswered = summaryData.where((data) {
      return data['user_answer'] == data['correct_answer'];
    }).length;
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You answered $totalCorrectlyAnswered questions out of $totalNoOfQuestions correctly!',
              style: GoogleFonts.lato(
                fontSize: 22,
                color: const Color.fromARGB(144, 255, 255, 255)
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            QuestionsSummary(summaryData),
            SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: restartQuiz, 
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white
              ),
              icon: Icon(Icons.restart_alt_rounded),
              label: Text('Restart Quiz')
            ),
          ],
        ),
      ),
    );
  }
}
