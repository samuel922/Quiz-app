# Quiz App 2.0

An opinionated Flutter quiz experience focused on learning fast and tracking progress.  
The original single-screen quiz was upgraded with better UX, richer data, analytics, and persistence.

## Highlights

- 🎯 **Configurable runs** – choose question counts and timed vs relaxed play.
- ⏱️ **Per-question timer** – visual countdown plus auto-advance on timeout.
- 📈 **Smart stats** – accuracy, streaks, fastest run, and more stored locally.
- 🧠 **Richer content** – each question has categories, difficulty, and pro tips.
- 🧾 **Detailed summaries** – review every answer with instant feedback.
- ✨ **Modern UI** – gradient shell, cards, and animated transitions.

## Getting Started

```bash
flutter pub get
flutter run
```

The app runs on Android, iOS, web, macOS, Windows, and Linux (desktop builds require the matching toolchains).

## Structure

- `lib/data/questions.dart` – curated question bank with metadata.
- `lib/models/` – quiz domain models & settings.
- `lib/services/score_storage.dart` – local persistence via `shared_preferences`.
- `lib/questions_screen.dart` – timed gameplay experience.
- `lib/result_screen.dart` – analytics & answer review.

## Customization Ideas

- Add remote questions or categories.
- Wire analytics to a backend/high-score board.
- Theme switcher (dark/light) or seasonal gradients.
- Accessibility improvements (larger fonts, voiceover cues).

Have fun leveling up your Flutter knowledge! 🚀
