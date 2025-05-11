import 'package:flutter/material.dart';
import '/screens/ChatbotScreen.dart';
class ChatbotFAB extends StatelessWidget {
  const ChatbotFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 30,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        tooltip: 'Chat with Buddy',
        onPressed: () {
          // Navigate to ChatbotScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        child: Icon(Icons.chat_bubble, color: Colors.teal.shade700),
      ),
    );
  }
}
