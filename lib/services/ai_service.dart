import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AIService {
  static const String _apiKey = ApiConfig.groqApiKey;
  static const String _baseUrl =
    'https://api.groq.com/openai/v1/chat/completions';

  Future<String> _generate(String prompt) async {
  try {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    debugPrint('Groq status: ${response.statusCode}');
    debugPrint('Groq body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Groq API failed: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    debugPrint('Groq error: $e');
    rethrow;
  }
}
  // ─── CHAT SUPPORT ─────────────────────────────────────
  Future<String> getChatResponse({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
  }) async {
    try {
      final history = conversationHistory
          .map((m) =>
              '${m['role'] == 'user' ? 'User' : 'Assistant'}: ${m['content']}')
          .join('\n');

      final prompt =
          '''You are GoJobs Assistant, a helpful AI support agent for the GoJobs app — a job finding platform in Jordan.
You help users with:
- Finding jobs and internships in Jordan
- How to apply for jobs
- How to create a good profile
- How to post jobs (for companies)
- App navigation and features
- Career advice for the Jordanian job market

Keep responses concise, friendly and helpful. Always respond in the same language the user writes in (Arabic or English).

${history.isNotEmpty ? 'Conversation history:\n$history\n' : ''}User: $userMessage
Assistant:''';

      return await _generate(prompt);
    } catch (e) {
      debugPrint('Chat error: $e');
      return 'Sorry, I am having trouble connecting right now. Please try again!';
    }
  }

  // ─── JOB MATCH SCORE ──────────────────────────────────
  Future<Map<String, dynamic>> getJobMatchScore({
    required String jobTitle,
    required String jobDescription,
    required String jobLocation,
    required String jobType,
    required List<String> userSkills,
    required String userLocation,
    required String userExperience,
  }) async {
    try {
      final prompt =
          '''You are a job matching AI. Analyze this job match and return a JSON object with these exact fields:
{
  "score": <number 0-100>,
  "level": <"Excellent Match" | "Good Match" | "Fair Match" | "Low Match">,
  "reasons": [<list of 3 short reasons why this is a good or bad match>],
  "tip": <one short tip to improve the match>
}

Job:
- Title: $jobTitle
- Description: $jobDescription
- Location: $jobLocation
- Type: $jobType

User Profile:
- Skills: ${userSkills.join(', ')}
- Location: $userLocation
- Experience: $userExperience

Return ONLY the JSON object, no markdown, no extra text.''';

      final text = await _generate(prompt);
      final cleaned =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleaned);
    } catch (e) {
      debugPrint('Match score error: $e');
      return {
        'score': 70,
        'level': 'Good Match',
        'reasons': [
          'Skills align with job requirements',
          'Location is compatible',
          'Experience level matches'
        ],
        'tip': 'Add more skills to your profile to improve your match score',
      };
    }
  }

  // ─── JOB DESCRIPTION GENERATOR ────────────────────────
  Future<String> generateJobDescription({
    required String jobTitle,
    required String companyName,
    required String location,
    required String jobType,
  }) async {
    try {
      final prompt =
          '''You are a professional HR writer. Write a concise, realistic job description for a Jordanian company.

Job Title: $jobTitle
Company: $companyName
Location: $location
Type: $jobType

Keep it under 150 words. Include: brief role overview, 3-4 key responsibilities, 2-3 requirements. No headers, just clean paragraph text.''';

      return await _generate(prompt);
    } catch (e) {
      debugPrint('Job description error: $e');
      return 'Failed to generate description. Please write one manually.';
    }
  }

  // ─── INTERVIEW PREP ───────────────────────────────────
  // Generates 25 questions and returns a random selection of 7
  Future<List<String>> getInterviewQuestions({
    required String jobTitle,
    required String jobDescription,
    int count = 7,
  }) async {
    try {
      final prompt =
          '''You are an interview coach. Generate 25 varied and realistic interview questions for this job in Jordan.
Mix technical, behavioral, and situational questions.

Job Title: $jobTitle
Description: $jobDescription

Return ONLY a JSON array of exactly 25 question strings, no markdown, no extra text.
Example: ["Question 1?", "Question 2?", ...]''';

      final text = await _generate(prompt);
      final cleaned =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> allQuestions = jsonDecode(cleaned);
      final List<String> questions = allQuestions.cast<String>();

      // Shuffle and return random selection
      questions.shuffle();
      return questions.take(count).toList();
    } catch (e) {
      debugPrint('Interview prep error: $e');
      // Return random selection from fallback questions
      final fallback = [
        'Tell me about yourself and your experience.',
        'Why do you want to work at our company?',
        'What are your greatest strengths?',
        'Where do you see yourself in 5 years?',
        'How do you handle pressure and deadlines?',
        'What is your expected salary?',
        'Do you have any questions for us?',
        'Describe a challenging situation and how you handled it.',
        'What motivates you in your work?',
        'How do you work in a team environment?',
        'What are your weaknesses?',
        'Why are you leaving your current job?',
        'What do you know about our company?',
        'How do you prioritize your tasks?',
        'Describe your ideal work environment.',
        'What are your long-term career goals?',
        'How do you handle criticism?',
        'What makes you the best candidate for this role?',
        'Describe a time you showed leadership.',
        'How do you stay updated in your field?',
        'What are your hobbies outside of work?',
        'How do you manage work-life balance?',
        'Describe a time you failed and what you learned.',
        'What skills do you want to develop further?',
        'How do you handle conflicts with coworkers?',
      ];
      fallback.shuffle();
      return fallback.take(count).toList();
    }
  }
}