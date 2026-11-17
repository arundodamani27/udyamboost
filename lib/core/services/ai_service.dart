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

  /// Rules added to every prompt so the reply is plain text that can be
  /// pasted straight into Instagram or WhatsApp.
  static const String _styleRules =
      'Use simple, friendly English. Do not use markdown. Do not use asterisks. '
      'Reply with only the text itself, with no title and no extra explanation.';

  static String _productDetails(String name, String category, [double? price]) {
    final buffer = StringBuffer()
      ..writeln('Product name: $name')
      ..writeln('Category: $category');
    if (price != null) {
      buffer.writeln('Price: ₹${price.toStringAsFixed(2)}');
    }
    return buffer.toString();
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
Do not use bullet points.
$_styleRules

${_productDetails(name, category, price)}''';
    return generate(prompt);
  }

  /// Writes an Instagram caption: 2-3 short lines, a few emojis,
  /// ending with a call to action. No hashtags.
  static Future<String> instagramCaption(
    String name,
    String category,
    double price,
  ) {
    final prompt = '''
You are a social media marketer for small Indian businesses.
Write a catchy Instagram caption for this product.
It must be 2-3 short lines and use a few emojis.
End with a clear call to action, such as "DM us to order" or "Tap the link to shop".
Do not include any hashtags.
$_styleRules

${_productDetails(name, category, price)}''';
    return generate(prompt);
  }

  /// Writes 10-12 hashtags on one line, separated by spaces.
  static Future<String> hashtags(String name, String category) {
    final prompt = '''
You are a social media marketer for small Indian businesses.
Suggest 10 to 12 relevant Instagram hashtags for this product.
Mix popular hashtags with niche ones that suit Indian small businesses and local shoppers.
Put every hashtag on one single line, separated by single spaces.
Each hashtag must start with # and contain no spaces.
Do not number them and do not add any other text.
$_styleRules

${_productDetails(name, category)}''';
    return generate(prompt);
  }

  /// Writes a friendly WhatsApp promo message under 60 words,
  /// with 1-2 emojis and a "reply to order" call to action.
  static Future<String> whatsappMessage(
    String name,
    String category,
    double price,
  ) {
    final prompt = '''
You are a marketing assistant for small Indian businesses.
Write a friendly promotional WhatsApp message that a shop owner can send to their customers about this product.
Keep it under 60 words and use only 1 or 2 emojis.
End by asking the customer to reply to this message to place an order.
$_styleRules

${_productDetails(name, category, price)}''';
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
