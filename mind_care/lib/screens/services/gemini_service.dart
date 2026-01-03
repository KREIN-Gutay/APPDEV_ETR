import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class JournalAnalysisResult {
  final String stressLevel; // low, medium, high
  final String suggestedExercise;

  JournalAnalysisResult({
    required this.stressLevel,
    required this.suggestedExercise,
  });
}

class GeminiService {
  /// ------------------------------
  /// Emotion + journaling feedback
  /// ------------------------------
  static Future<String> analyzeEmotion(String noteContent) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        return "⚠️ Gemini API key not found.";
      }

      final model = GenerativeModel(
        model: 'models/gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt =
          '''
You are a supportive journaling assistant.

Analyze the emotional tone of the journal entry.

Respond ONLY in this format:

Emotion:
(one or two words)

Suggestions:
- suggestion 1
- suggestion 2
- suggestion 3

Rules:
- No medical advice
- Be calm and supportive

Journal:
"$noteContent"
''';

      final response = await model.generateContent([Content.text(prompt)]);

      return response.text ?? "I couldn't analyze this entry right now.";
    } catch (_) {
      return '''
Emotion:
Tired

Suggestions:
- Consider resting your body
- Take a few slow breaths
- Be kind to yourself today
''';
    }
  }

  static JournalAnalysisResult _keywordFallback(String text) {
    final lower = text.toLowerCase();

    if (lower.contains("tired") ||
        lower.contains("exhausted") ||
        lower.contains("burnout")) {
      return JournalAnalysisResult(
        stressLevel: "low",
        suggestedExercise: "Pepper Calm 4-4-2",
      );
    }

    if (lower.contains("anxious") ||
        lower.contains("stress") ||
        lower.contains("overwhelmed") ||
        lower.contains("panic")) {
      return JournalAnalysisResult(
        stressLevel: "high",
        suggestedExercise: "Box Breathing",
      );
    }

    if (lower.contains("angry") ||
        lower.contains("frustrated") ||
        lower.contains("irritated")) {
      return JournalAnalysisResult(
        stressLevel: "medium",
        suggestedExercise: "4-7-8 Relax",
      );
    }

    // default safe fallback
    return JournalAnalysisResult(
      stressLevel: "medium",
      suggestedExercise: "Box Breathing",
    );
  }

  /// ------------------------------
  /// Stress → auto breathing logic
  /// ------------------------------
  static Future<JournalAnalysisResult> analyzeJournalStress(
    String noteContent,
  ) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        return JournalAnalysisResult(
          stressLevel: "medium",
          suggestedExercise: "Box Breathing",
        );
      }

      final model = GenerativeModel(
        model: 'models/gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt =
          '''
Analyze the stress level of this journal entry.

Respond with ONE word only:
low
medium
high

Journal:
"$noteContent"
''';

      final response = await model.generateContent([Content.text(prompt)]);

      final stress = response.text?.trim().toLowerCase() ?? "medium";

      // ✅ APP decides breathing (safe & deterministic)
      String exercise;
      switch (stress) {
        case "high":
          exercise = "Box Breathing";
          break;
        case "low":
          exercise = "Pepper Calm 4-4-2";
          break;
        default:
          exercise = "4-7-8 Relax";
      }

      return JournalAnalysisResult(
        stressLevel: stress,
        suggestedExercise: exercise,
      );
    } catch (_) {
      return _keywordFallback(noteContent);
    }
  }
}
