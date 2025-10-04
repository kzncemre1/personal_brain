import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yeni_proje/about.dart';
import 'package:yeni_proje/contact.dart';
import 'package:yeni_proje/details.dart';
import 'package:yeni_proje/profile.dart';
import 'summary_model.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //AnimationController gibi animasyonları kullandığında, bu controller'ın düzgün çalışması için bir TickerProvider gerekir.SingleTickerProviderStateMixin, bunu sağlar.
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _menuController;
  late Animation<Offset> _offsetAnimation;
  bool isMenuOpen = false;
  SummaryModel _selectedModel = SummaryModel.ozcan;

  @override
  void initState() {
    //SOLDAN KAYAN MENÜNÜN İLKLENDİRİLMESİ
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
        );
  }

  void toggleMenu() {
    if (isMenuOpen) {
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  Future<Map<String, String>?> summarizeNote(String text) async {
    final uri = Uri.parse('http://10.61.23.171:5000/summarize');

    final modelString = {
      SummaryModel.ozcan: "ozcan",
      SummaryModel.mukayese: "mukayese",
      SummaryModel.english: "english",
    }[_selectedModel];

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"text": text, "model": modelString}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {"summary": data["summary"] ?? "", "title": data["title"] ?? ""};
      } else {
        print("Özetleme hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("Bağlantı hatası: $e");
    }
    return null;
  }

  void showCountdownSnackbar(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    int countdown = 5;
    late StateSetter stateSetter;

    final snackBar = SnackBar(
      duration: const Duration(seconds: 5),
      content: StatefulBuilder(
        builder: (context, setState) {
          stateSetter = setState;
          return Text("Notunuz kaydediliyor...  $countdown");
        },
      ),
    );

    scaffold.showSnackBar(snackBar);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 1) {
        timer.cancel();
        scaffold.hideCurrentSnackBar();
        scaffold.showSnackBar(
          const SnackBar(
            content: Text("Not başarıyla kaydedildi."),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        countdown--;
        stateSetter(() {});
      }
    });
  }

  Future<void> _saveNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen not yazın.")));
      return;
    }
    // 1️⃣ GÖNDERİLEN METİN UZUNLUĞU
    print("Gönderilen metin uzunluğu: ${text.length}");
    try {
      showCountdownSnackbar(context);
      _noteController.clear();
      final result = await summarizeNote(text);
      // 2️⃣ GELEN ÖZET
      print("Gelen özet: ${result?["summary"]}");

      await FirebaseFirestore.instance.collection("notes").add({
        "userId": FirebaseAuth.instance.currentUser?.uid,
        "text": text,
        "summary": result?["summary"] ?? "",
        "title": result?["title"] ?? "",
        "createdAt": Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kayıt hatası: ${e.toString()}")));
    }
  }

  Future<void> _deleteNote(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("notes").doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Silme hatası: ${e.toString()}")));
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Widget _buildRadioOption(SummaryModel value, String label) {
    return InkWell(
      //  dokunma (tap) etkisi veren bir widget’tır.
      onTap: () {
        setState(() {
          _selectedModel = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<SummaryModel>(
            // SummaryModel ile çalışılacağını ifade eder <>
            value: value,
            groupValue: _selectedModel,
            onChanged: (val) {
              setState(() {
                _selectedModel = val!;
              });
            },
            activeColor: Colors.brown,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 10 && !isMenuOpen) {
            toggleMenu();
          } else if (details.delta.dx < -10 && isMenuOpen) {
            toggleMenu();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFFFF8E1),
              appBar: AppBar(
                title: const Text(
                  "Personal Brain",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: Colors.amber[700],
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: toggleMenu,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MyHomePage(title: 'Firebase Giriş Ekranı'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Hoş geldiniz!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Model Seçiniz:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRadioOption(SummaryModel.ozcan, "mt5\n sts"),
                          _buildRadioOption(SummaryModel.mukayese, "mt5\n bst"),
                          _buildRadioOption(
                            SummaryModel.english,
                            "distilbart\n (ingilizce)",
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        minLines: 1,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: "Metin Giriniz",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[600],
                          ),
                          child: const Text(
                            "Özetimi Kaydet",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 250,
              child: SlideTransition(
                position: _offsetAnimation,
                child: Material(
                  color: const Color(0xFFFFECB3),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: toggleMenu,
                        ),
                      ),
                      const Text(
                        'Özetlerim',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('notes')
                              .where(
                                'userId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid,
                              )
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text("Hiç not bulunamadı."),
                              );
                            }

                            final notes = snapshot.data!.docs;
                            final groupedNotes =
                                <String, List<QueryDocumentSnapshot>>{};

                            for (var doc in notes) {
                              final timestamp = doc['createdAt'] as Timestamp;
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                timestamp.millisecondsSinceEpoch,
                              );
                              final formattedDate =
                                  "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
                              groupedNotes.putIfAbsent(formattedDate, () => []);
                              groupedNotes[formattedDate]!.add(doc);
                            }

                            final sortedDates = groupedNotes.keys.toList()
                              ..sort((a, b) => b.compareTo(a));

                            return ListView.builder(
                              itemCount: sortedDates.length,
                              itemBuilder: (context, index) {
                                final date = sortedDates[index];
                                final dayNotes = groupedNotes[date]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        date,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    ),
                                    ...dayNotes.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final timestamp =
                                          doc['createdAt'] as Timestamp;
                                      final time =
                                          DateTime.fromMillisecondsSinceEpoch(
                                            timestamp.millisecondsSinceEpoch,
                                          ).toLocal();
                                      final timeString =
                                          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Colors.brown.shade300,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            data['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text("Saat: $timeString"),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailPage(
                                                      data: data,
                                                      model: _selectedModel,
                                                    ),
                                              ),
                                            );
                                          },
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () =>
                                                _deleteNote(doc.id),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person),
                              onPressed: () {
                                toggleMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone),
                              onPressed: () {
                                toggleMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ContactPage(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                toggleMenu();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
