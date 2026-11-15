import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Talks to Google Gemini to generate marketing text.
///
/// The API key is read at runtime from the `.env` file
/// (`GEMINI_API_KEY=...`). It is never written in code.
class AiService {
  AiService._();

  static const String _defaultModel = 'gemini-2.5-flash';
  static const Duration _timeout = Duration(seconds: 30);

  /// Sends [prompt] to Gemini and returns the generated text.
  ///
  /// Throws an [AiServiceException] if the key is missing, the request
  /// fails, or the reply has no text.
  static Future<String> generate(String prompt) async {
    final apiKey = dotenv.maybeGet('GEMINI_API_KEY');
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiServiceException('GEMINI_API_KEY is missing from .env');
    }

    final model = dotenv.maybeGet('GEMINI_MODEL') ?? _defaultModel;
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
    );

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            // Sent as a header, not in the URL, so it doesn't end up in logs.
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AiServiceException(
        'Gemini request failed with status ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const AiServiceException('Gemini returned no candidates');
    }

    final content =
        (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts
        ?.map((part) => (part as Map<String, dynamic>)['text'] as String? ?? '')
        .join()
        .trim();

    if (text == null || text.isEmpty) {
      throw const AiServiceException('Gemini returned an empty reply');
    }
    return text;
  }

  /// Writes a short, catchy product description for a small business.
  static Future<String> productDescription(
    String name,
    String category,
    double price,
  ) {
    final prompt = '''
You are a marketing assistant for small Indian businesses.
Write a short, catchy product description (3-4 sentences) for this product.
Use simple, friendly English. Do not use markdown or bullet points.

Product name: $name
Category: $category
Price: ₹${price.toStringAsFixed(2)}
''';
    return generate(prompt);
  }
}

/// An error from [AiService]. The message is technical, so log it
/// rather than showing it to users.
class AiServiceException implements Exception {
  const AiServiceException(this.message);

  final String message;

  @override
  String toString() => 'AiServiceException: $message';
}
