# Chat Bot API Integration Guide

## Current Setup
The chat bot currently uses mock responses for demonstration purposes.

## Integrating a Real AI API

### Option 1: OpenAI (ChatGPT)

1. Get your API key from: https://platform.openai.com/api-keys

2. In `lib/screens/chat_bot_screen.dart`, replace the `_getAIResponse` method with:

```dart
Future<String> _getAIResponse(String message) async {
  final apiKey = 'YOUR_OPENAI_API_KEY_HERE'; // Replace with your key
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a helpful job search assistant. Help users with job-related questions, career advice, and application tips.'
        },
        {'role': 'user', 'content': message}
      ],
      'max_tokens': 500,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Failed to get response');
  }
}
```

3. Add imports at the top of the file:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
```

### Option 2: Google Gemini (Free)

1. Get your API key from: https://makersuite.google.com/app/apikey

2. Add the package to `pubspec.yaml`:
```yaml
dependencies:
  google_generative_ai: ^0.2.0
```

3. Replace the `_getAIResponse` method:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

Future<String> _getAIResponse(String message) async {
  final apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
  );

  final prompt = '''
You are a helpful job search assistant in a job finding app. 
Help users with job-related questions, career advice, and application tips.

User question: $message
''';

  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  return response.text ?? 'Sorry, I could not generate a response.';
}
```

### Option 3: Hugging Face (Free)

1. Get your API token from: https://huggingface.co/settings/tokens

2. Use this code:

```dart
Future<String> _getAIResponse(String message) async {
  final apiKey = 'YOUR_HUGGINGFACE_TOKEN_HERE';
  final url = Uri.parse('https://api-inference.huggingface.co/models/meta-llama/Llama-2-7b-chat-hf');
  
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': 'You are a job search assistant. User asks: $message',
      'parameters': {
        'max_new_tokens': 250,
        'temperature': 0.7,
      }
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data[0]['generated_text'];
  } else {
    throw Exception('Failed to get response');
  }
}
```

## Security Best Practices

⚠️ **Never commit API keys to version control!**

Use environment variables or secure storage:

1. Create a `.env` file (add to .gitignore):
```
OPENAI_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
```

2. Use flutter_dotenv package:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

3. Load and use:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiKey = dotenv.env['OPENAI_API_KEY']!;
```

## Testing

The mock responses in the current implementation handle common queries:
- Job search questions
- Application process
- CV/Resume tips
- Interview preparation
- Salary questions
- Remote work queries

Test these scenarios before deploying with a real API.
