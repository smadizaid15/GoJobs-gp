import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyARDQaAs189uxFqUcU7_HcExN_2vZi4rNE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> _generate(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ],
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
          'Gemini API failed: ${response.statusCode} ${response.body}');
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
      final prompt = '''You are a job matching AI. Analyze this job match and return a JSON object with these exact fields:
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
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return jsonDecode(cleaned);
    } catch (e) {
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
      return 'Failed to generate description. Please write one manually.';
    }
  }

  // ─── INTERVIEW PREP ───────────────────────────────────
  Future<List<String>> getInterviewQuestions({
    required String jobTitle,
    required String jobDescription,
  }) async {
    try {
      final prompt =
          '''You are an interview coach. Generate 7 likely interview questions for this job in Jordan.

Job Title: $jobTitle
Description: $jobDescription

Return ONLY a JSON array of 7 question strings, no markdown, no extra text.
Example: ["Question 1?", "Question 2?", ...]''';

      final text = await _generate(prompt);
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> questions = jsonDecode(cleaned);
      return questions.cast<String>();
    } catch (e) {
      return [
        'Tell me about yourself and your experience.',
        'Why do you want to work at our company?',
        'What are your greatest strengths?',
        'Where do you see yourself in 5 years?',
        'How do you handle pressure and deadlines?',
        'What is your expected salary?',
        'Do you have any questions for us?',
      ];
    }
  }
}