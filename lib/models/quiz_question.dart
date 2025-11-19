class QuizQuestion {

  const QuizQuestion(this.question, this.possibleAnswers);

  final String question;
  final List<String> possibleAnswers;

  List<String> getShuffledAnswers() {
    final shuffledAnsers = List.of(possibleAnswers);
    shuffledAnsers.shuffle();

    return shuffledAnsers;
  }
}