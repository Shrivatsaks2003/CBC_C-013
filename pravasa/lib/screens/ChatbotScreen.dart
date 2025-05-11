import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final WebViewController _controller;
  final String chatbotUrl = 'https://fever-ln-named-simultaneously.trycloudflare.com/';

  void _launchInBrowser() async {
    final Uri url = Uri.parse(chatbotUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch browser')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(chatbotUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Buddy"),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black.withOpacity(0.03),
            child: Column(
              children: [
                const Text(
                  "Having trouble using voice input?",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: _launchInBrowser,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text("Open in External Browser"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
