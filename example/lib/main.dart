import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Keyboard Insets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<KeyboardMetrics>? _subscription;

  // Dummy messages for demonstration
  final List<String> _messages = [
    'Hey! How are you?',
    'I\'m doing great, thanks for asking!',
    'Did you see the new Flutter update?',
    'Yes! The keyboard handling is so much better now.',
    'This plugin makes it even easier.',
    'Totally agree! No more manual calculations.',
    'The animation is smooth too.',
    'Let me try typing something...',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the stream listener to start receiving keyboard updates
    _subscription = SmartKeyboardInsets.instance.metricsStream.listen((_) {
      // Stream subscription keeps the plugin active
      // With reverse: true, the list stays anchored at bottom automatically
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(_textController.text.trim());
      });
      _textController.clear();
      // Scroll to bottom after adding message
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Disable default keyboard avoidance - we handle it with AnimatedKeyboardPadding
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Chat Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Debug overlay showing live metrics
          _buildDebugOverlay(),
          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isMe = index % 2 == 1;
                return _buildMessageBubble(_messages[index], isMe);
              },
            ),
          ),
          // Bottom composer with AnimatedKeyboardPadding
          AnimatedKeyboardPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugOverlay() {
    return ValueListenableBuilder<KeyboardMetrics>(
      valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
      builder: (context, metrics, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Text(
            'keyboardHeight: ${metrics.keyboardHeight.toStringAsFixed(1)} | '
            'safeAreaBottom: ${metrics.safeAreaBottom.toStringAsFixed(1)} | '
            'visible: ${metrics.isKeyboardVisible}',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
