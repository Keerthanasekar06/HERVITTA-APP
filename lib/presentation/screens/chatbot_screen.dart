import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chatbot_provider.dart';
import '../../core/theme/app_colors.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;
  bool _voiceEnabled = true;

  final List<String> _suggestedPrompts = [
    "How can I save more this month?",
    "Can I afford a small loan?",
    "How do I reduce household expenses?",
    "Give me a simple savings tip",
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _msgController.clear();
    _scrollToBottom();
  }

  Future<void> _toggleListen() async {
    final stt = ref.read(speechToTextProvider);
    if (!_isListening) {
      bool available = await stt.initialize();
      if (available) {
        setState(() => _isListening = true);
        stt.listen(
          onResult: (val) {
            setState(() {
              _msgController.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      stt.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isTyping = ref.watch(chatIsTypingProvider);
    
    _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.palePurple.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.grapePurple, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('AI Financial Mentor', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: AppColors.indigo,
            ),
            onPressed: () {
              setState(() => _voiceEnabled = !_voiceEnabled);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_voiceEnabled ? 'Voice output enabled' : 'Voice output disabled')));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.length <= 1 
                ? _buildEmptyState() // Show chips if only the invisible welcome message is tracked logic-wise
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      // we can hide the artificial backend welcome message or show it gracefully
                      if (index == 0) return const SizedBox.shrink(); 
                      return _ChatBubble(message: msg);
                    },
                  ),
          ),
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.grapePurple),
                    ),
                    const SizedBox(width: 12),
                    Text("Mentor is analyzing...", style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.palePurple,
            child: Icon(Icons.auto_awesome_rounded, size: 40, color: AppColors.grapePurple),
          ),
          const SizedBox(height: 24),
          const Text(
            "Hello, Aisha! 👋",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.indigo),
          ),
          const SizedBox(height: 8),
          const Text(
            "I'm your personal financial mentor. I can help you plan your budget, find savings, or explain complex financial terms. How can I assist you today?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 48),
          const Text(
            "Suggested topics:",
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.indigo, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _suggestedPrompts.map((prompt) {
              return ActionChip(
                label: Text(prompt, style: const TextStyle(color: AppColors.grapePurple, fontWeight: FontWeight.w600, fontSize: 13)),
                backgroundColor: AppColors.palePurple.withOpacity(0.3),
                side: const BorderSide(color: AppColors.palePurple),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _sendMessage(prompt),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.palePurple.withOpacity(0.4), shape: BoxShape.circle),
              child: IconButton(
                onPressed: _toggleListen,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                  color: _isListening ? Colors.redAccent : AppColors.grapePurple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _msgController,
                style: const TextStyle(fontSize: 15, color: AppColors.indigo),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (val) => _sendMessage(val),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(color: AppColors.grapePurple, shape: BoxShape.circle),
              child: IconButton(
                onPressed: () => _sendMessage(_msgController.text),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.grapePurple : Colors.white,
          border: message.isUser ? null : Border.all(color: AppColors.palePurple.withOpacity(0.5)),
          boxShadow: [
             BoxShadow(
              color: message.isUser ? AppColors.grapePurple.withOpacity(0.2) : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: message.isUser ? const Radius.circular(24) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(24),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : AppColors.indigo,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
