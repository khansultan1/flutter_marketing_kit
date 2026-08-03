import 'package:ai_engine/src/providers/ai_provider.dart';

/// Google Gemini AI provider implementation.
class GeminiAiProvider implements AiProvider {
  /// Creates a [GeminiAiProvider].
  const GeminiAiProvider();

  @override
  String get name => 'gemini';

  @override
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  }) async {
    return '[Gemini AI Generated Copy] $prompt';
  }
}

/// OpenAI GPT provider implementation.
class OpenAiProvider implements AiProvider {
  /// Creates an [OpenAiProvider].
  const OpenAiProvider();

  @override
  String get name => 'openai';

  @override
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  }) async {
    return '[OpenAI Generated Copy] $prompt';
  }
}

/// Anthropic Claude provider implementation.
class AnthropicAiProvider implements AiProvider {
  /// Creates an [AnthropicAiProvider].
  const AnthropicAiProvider();

  @override
  String get name => 'anthropic';

  @override
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  }) async {
    return '[Anthropic Claude Generated Copy] $prompt';
  }
}

/// OpenRouter provider implementation.
class OpenRouterAiProvider implements AiProvider {
  /// Creates an [OpenRouterAiProvider].
  const OpenRouterAiProvider();

  @override
  String get name => 'openrouter';

  @override
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  }) async {
    return '[OpenRouter Generated Copy] $prompt';
  }
}

/// Ollama local LLM provider implementation.
class OllamaAiProvider implements AiProvider {
  /// Creates an [OllamaAiProvider].
  const OllamaAiProvider();

  @override
  String get name => 'ollama';

  @override
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  }) async {
    return '[Ollama Local Generated Copy] $prompt';
  }
}

/// LM Studio local LLM provider implementation.
class LmStudioAiProvider implements AiProvider {
  /// Creates an [LmStudioAiProvider].
  const LmStudioAiProvider();

  @override
  String get name => 'lmstudio';

  @override
  Future<String> generateText({
    required String prompt,
    String? apiKey,
  }) async {
    return '[LM Studio Local Generated Copy] $prompt';
  }
}
