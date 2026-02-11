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
  final FocusNode _focusNode = FocusNode();
  StreamSubscription<KeyboardMetrics>? _subscription;
  
  bool _showStickerPanel = false;
  double _lastKeyboardHeight = 300; // Default height for sticker panel

  // Dummy messages for demonstration
  final List<String> _messages = [
    'Hey! How are you?',
    'I\'m doing great, thanks for asking!',
    'Did you see the new Flutter update?',
    'Yes! The keyboard handling is so much better now.',
    'This plugin makes it even easier.',
    'Totally agree! No more manual calculations.',
    'The animation is smooth too.',
    'Try the sticker button! 👇',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the stream listener to start receiving keyboard updates
    _subscription = SmartKeyboardInsets.instance.metricsStream.listen((metrics) {
      // Store keyboard height for sticker panel sizing
      if (metrics.isKeyboardVisible && metrics.keyboardHeight > 0) {
        setState(() {
          _lastKeyboardHeight = metrics.keyboardHeight;
          _showStickerPanel = false; // Hide sticker panel when keyboard opens
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage([String? emoji]) {
    final text = emoji ?? _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(text);
      });
      if (emoji == null) _textController.clear();
    }
  }

  void _toggleStickerPanel() {
    if (_showStickerPanel) {
      setState(() => _showStickerPanel = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showStickerPanel = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Chat Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildDebugOverlay(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final actualIndex = _messages.length - 1 - index;
                final isMe = actualIndex % 2 == 1;
                return _buildMessageBubble(_messages[actualIndex], isMe);
              },
            ),
          ),
          // Composer + Sticker Panel
          _buildBottomArea(),
        ],
      ),
    );
  }

  Widget _buildBottomArea() {
    return ValueListenableBuilder<KeyboardMetrics>(
      valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
      builder: (context, metrics, child) {
        // Calculate bottom padding
        double bottomPadding = 0;
        if (metrics.isKeyboardVisible) {
          bottomPadding = metrics.keyboardHeight;
        } else if (_showStickerPanel) {
          bottomPadding = 0; // Sticker panel handles its own height
        } else {
          bottomPadding = metrics.safeAreaBottom;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Composer
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Sticker/Emoji button
                  IconButton(
                    onPressed: _toggleStickerPanel,
                    icon: Icon(
                      _showStickerPanel ? Icons.keyboard : Icons.emoji_emotions_outlined,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
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
                      onTap: () {
                        if (_showStickerPanel) {
                          setState(() => _showStickerPanel = false);
                        }
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            // Sticker Panel - uses keyboard height!
            if (_showStickerPanel) _buildStickerPanel(),
            // Bottom padding for keyboard or safe area
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: bottomPadding,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStickerPanel() {
    // Use the last known keyboard height for consistent UX
    final panelHeight = _lastKeyboardHeight > 0 ? _lastKeyboardHeight : 300.0;
    
    return Container(
      height: panelHeight,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Sticker Panel (height: ${panelHeight.toStringAsFixed(0)})',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendMessage(_emojis[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _emojis[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _emojis = [
    '😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊',
    '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘',
    '😗', '😙', '😚', '😋', '😛', '😜', '🤪', '😝',
    '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐',
    '😑', '😶', '😏', '😒', '🙄', '😬', '🤥', '😌',
    '👍', '👎', '👏', '🙌', '🤝', '🙏', '❤️', '🔥',
  ];

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
