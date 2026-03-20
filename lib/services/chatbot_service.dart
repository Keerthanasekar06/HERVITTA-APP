import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/models/expense_model.dart';
import 'package:flutter/foundation.dart';

class ChatbotService {
  final String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; 
  GenerativeModel? _model;
  ChatSession? _chat;

  ChatbotService() {
    if (_apiKey.isNotEmpty && !_apiKey.contains('YOUR_GEMINI')) {
      try {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
          systemInstruction: Content.system(
            '''You are a supportive, empowering financial mentor specifically for women.
            You support English and Tamil. Auto-detect language. Keep responses concise and practical. 
            Avoid technical jargon.''',
          ),
        );
        _chat = _model?.startChat();
      } catch (e) {
        debugPrint("Chatbot Service Initialization Error: $e");
      }
    }
  }

  Future<String> sendMessage(String message, List<Expense> currentExpenses) async {
    try {
      if (_chat == null) {
         await Future.delayed(const Duration(seconds: 2));
         return "Hi Aisha! Since the demo API key isn't configured, I am operating in offline simulation mode.\n\nRegarding your question: '$message', a great rule of thumb is the 50/30/20 budget. Try saving 20% of your income to reach your goals safely!";
      }

      final total = currentExpenses.fold(0.0, (sum, exp) => sum + exp.amount);
      final contextMsg = "Context: The user has spent ₹$total recently. User asks: $message";

      final response = await _chat!.sendMessage(Content.text(contextMsg)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );
      
      if (response.text == null || response.text!.isEmpty) {
         return "I received a blank response from the system. Please feel free to rephrase your question!";
      }
      return response.text!;
    } catch (e) {
      if (e.toString().contains('timeout')) {
         return "It seems the network is a bit slow right now and my request timed out. Please try again.";
      } else if (e.toString().contains('quota') || e.toString().contains('429')) {
         return "I've reached my current usage limit for the Gemini API. Please take a quick break and try again later!";
      }
      return "I'm having trouble connecting to my servers. Please verify your internet connection and API key.\nError: $e";
    }
  }
}
