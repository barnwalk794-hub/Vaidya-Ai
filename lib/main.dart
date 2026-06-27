import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VaidyaApp());
}

class VaidyaApp extends StatelessWidget {
  const VaidyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaidyaAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _loading = false;

  Future<void> _submit() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _loading = true;
      _response = "";
    });

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY_HERE',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'nvidia/nemotron-3-ultra-550b-a55b:free',
          'messages': [
            {
              'role': 'system',
              'content': 'You are VaidyaAI, a helpful health assistant for rural Indian users. Always respond in the same language the user writes in. If they write in Hindi, respond in Hindi. If they write in English, respond in English. When a user describes symptoms, explain what the issue might be in simple language, suggest basic home remedies if appropriate, and always recommend consulting a doctor for confirmation. Never give a definitive diagnosis. Always add a disclaimer at the end.'
            },
            {'role': 'user', 'content': _controller.text}
          ]
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _response = data['choices'] != null
            ? data['choices'][0]['message']['content']
            : "API Error: ${response.body}";
      });
    } catch (e) {
      setState(() {
        _response = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VaidyaAI'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Describe your health problem',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g. I have fever and headache',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Analyze', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            if (_response.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(_response, style: const TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}

