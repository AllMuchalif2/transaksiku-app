import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chatbot_provider.dart';
import '../providers/transaksi_provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text;
    _controller.clear();

    // Scroll ke bawah agar user melihat pesan barunya
    _scrollToBottom();

    final chatProvider = context.read<ChatBotProvider>();
    final trxProvider = context.read<TransaksiProvider>();

    await chatProvider.sendMessage(message, trxProvider);

    // Scroll ke bawah lagi setelah balasan bot muncul
    _scrollToBottom();
  }

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

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk listen perubahan pada ChatBotProvider
    return Consumer<ChatBotProvider>(
      builder: (context, botProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Asisten Keuangan'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => botProvider.clearChat(),
                tooltip: 'Hapus Riwayat Chat',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: botProvider.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Mulai chat dengan AI...\nCoba: "Bagaimana kondisi keuanganku?"\nGunakan /input untuk input otomatis',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: botProvider.messages.length,
                        itemBuilder: (context, index) {
                          final msg = botProvider.messages[index];
                          final isUser = msg['role'] == 'user';

                          // Konfigurasi visual untuk bubble chat
                          Color bubbleColor;
                          if (isUser) {
                            bubbleColor = Colors.teal;
                          } else if (msg['type'] == 'success') {
                            bubbleColor = Colors.green.shade100;
                          } else if (msg['type'] == 'error') {
                            bubbleColor = Colors.red.shade100;
                          } else {
                            bubbleColor = Colors.grey.shade200;
                          }

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              child: Text(
                                msg['text'],
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (botProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan atau /input...',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal.shade100),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                        enabled: !botProvider.isLoading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: botProvider.isLoading ? null : _handleSend,
                      icon: const Icon(Icons.send),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
