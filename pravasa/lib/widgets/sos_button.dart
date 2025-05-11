import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:hive/hive.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  void _askForNumber(BuildContext context) {
    final box = Hive.box('settings');
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Emergency Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Enter emergency number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final number = controller.text.trim();
              if (number.isNotEmpty) {
                box.put('emergency_number', number);
                Navigator.pop(context);
                _showOptions(context); // Show options again
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editNumber(BuildContext context) {
    final box = Hive.box('settings');
    final current = box.get('emergency_number', defaultValue: '');
    final TextEditingController controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Emergency Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Enter new emergency number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newNumber = controller.text.trim();
              if (newNumber.isNotEmpty) {
                box.put('emergency_number', newNumber);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Emergency number updated.")),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) async {
    final box = Hive.box('settings');
    final String emergencyNumber = box.get('emergency_number', defaultValue: '');

    if (emergencyNumber.isEmpty) {
      _askForNumber(context);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.web),
              label: const Text('Open Website'),
              onPressed: () async {
                Navigator.pop(context);
                await launchUrl(Uri.parse('https://pravasa.netlify.app/'));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text('Call Emergency'),
              onPressed: () async {
                Navigator.pop(context);
                await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
              },
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Number'),
              onPressed: () {
                Navigator.pop(context);
                _editNumber(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 30,
      child: FloatingActionButton(
        onPressed: () => _showOptions(context),
        backgroundColor: Colors.red,
        tooltip: 'Emergency SOS',
        child: const Icon(Icons.warning),
      ),
    );
  }
}
