import 'dart:async';

import 'package:flutter/material.dart';

import '../api/chat_hub.dart';
import '../api/clientflow_api.dart';
import '../models/message.dart';
import '../theme/clientflow_palette.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.api,
    required this.hub,
    required this.conversationId,
    required this.clientName,
  });

  final ClientFlowApi api;
  final ChatHubClient hub;
  final String conversationId;
  final String clientName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Message> _messages = [];
  StreamSubscription<Message>? _subscription;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final data = await widget.api.fetchMessages(widget.conversationId);
      _messages
        ..clear()
        ..addAll(data);
    } finally {
      setState(() {
        _loading = false;
      });
      await widget.hub.connect();
      await widget.hub.joinConversation(widget.conversationId);
      _subscription = widget.hub.messages.listen((message) {
        if (message.conversationId != widget.conversationId) return;
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.hub.leaveConversation(widget.conversationId);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    await widget.api.sendMessage(
      conversationId: widget.conversationId,
      body: text,
      senderType: 'salon',
      senderName: 'Salao',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.clientName),
            const SizedBox(height: 2),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, color: Color(0xFFB8C8C6)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isSalon = message.isSalon;
    final alignment = isSalon ? Alignment.centerRight : Alignment.centerLeft;
    final color = isSalon
        ? ClientFlowPalette.accent.withOpacity(0.9)
        : ClientFlowPalette.surface;
    final textColor =
        isSalon ? ClientFlowPalette.deepest : ClientFlowPalette.deepest;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isSalon
              ? null
              : Border.all(color: ClientFlowPalette.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment:
              isSalon ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.body,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: ClientFlowPalette.deep),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
