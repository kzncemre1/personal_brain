import 'package:flutter/material.dart';
import 'summary_model.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final SummaryModel model;

  const DetailPage({super.key, required this.data, required this.model});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  Future<void> _speak(String text) async {
    if (isSpeaking) return; // tekrar tekrar tetiklenmesin

    setState(() {
      isSpeaking = true;
    });

    if (widget.model == SummaryModel.english) {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setVoice({
        "name": "en-us-x-sfg#male_1-local",
        "locale": "en-US",
      });
    } else {
      await flutterTts.setLanguage("tr-TR");
      await flutterTts.setVoice({
        "name": "tr-tr-x-efe#male_1-local",
        "locale": "tr-TR",
      });
    }

    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.speak(text);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Widget _buildTextCard(
    String title,
    String content, {
    required bool isSummary,
  }) {
    return Card(
      color: isSummary ? Colors.amber[100] : Colors.amber[50],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.brown[700],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(content, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _speak(content),
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Oku"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSummary
                        ? Colors.brown[400]
                        : Colors.amber[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop),
                  label: const Text("Durdur"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text(
          'Detay',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextCard(
              "Gerçek Metin:",
              widget.data['text'] ?? '',
              isSummary: false,
            ),
            const SizedBox(height: 20),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.amber[100],
                hoverColor: Colors.amber[100],
              ),
              child: Card(
                color: Colors.amber[100],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Özeti Görüntüle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildTextCard(
                        "Özet:",
                        widget.data['summary'] ?? '',
                        isSummary: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
