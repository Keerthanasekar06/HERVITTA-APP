import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/chatbot_service.dart';
import 'expense_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

final chatbotServiceProvider = Provider((ref) => ChatbotService());

// Global typing status to ensure widgets can reload when it changes securely.
final chatIsTypingProvider = StateProvider<bool>((ref) => false);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;

  ChatNotifier(this.ref) : super([
    ChatMessage(
      text: "Hello! I am your financial companion. How can I help you save or track expenses today? (வணக்கம்! நான் எப்படி உதவலாம்?)", 
      isUser: false
    )
  ]);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message immediately
    state = [...state, ChatMessage(text: text, isUser: true)];
    
    // Trigger global isTyping
    ref.read(chatIsTypingProvider.notifier).state = true;
    
    try {
      final expensesAsyncValue = ref.read(expensesProvider);
      final expenses = expensesAsyncValue.value ?? [];
      
      final service = ref.read(chatbotServiceProvider);
      // Wait for reply safely
      final reply = await service.sendMessage(text, expenses);

      state = [...state, ChatMessage(text: reply, isUser: false)];
    } catch (e) {
      state = [...state, ChatMessage(text: "An error occurred: $e", isUser: false)];
    } finally {
      // Guaranteed to turn off typing indicator on both success, failure, timeout
      ref.read(chatIsTypingProvider.notifier).state = false;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

final speechToTextProvider = Provider((ref) => SpeechToText());
final textToSpeechProvider = Provider((ref) {
  final tts = FlutterTts();
  tts.setLanguage("en-US");
  tts.setSpeechRate(0.5);
  return tts;
});
