/// Abstract provider interface for AI text generation engines.
abstract class AiProvider {
  /// Provider identifier name.
  String get name;

  /// Generate text output based on prompt input.
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  });
}
