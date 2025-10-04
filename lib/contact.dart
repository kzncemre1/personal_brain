import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text(
          "İletişim",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ContactCard(
                icon: Icons.email,
                title: "E-posta",
                content: "mmf@gmail.com",
              ),
              const SizedBox(height: 12),
              ContactCard(
                icon: Icons.phone,
                title: "Telefon",
                content: "+90 555 555 55 55",
              ),
              const SizedBox(height: 12),
              ContactCard(
                icon: Icons.location_on,
                title: "Adres",
                content:
                    "Kastamonu Üniversitesi, Mühendislik ve Mimarlık Fakültesi",
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(41.43820419069961, 33.763691432385656),
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("kastamonu_uni"),
                        position: const LatLng(
                          41.43820419069961,
                          33.763691432385656,
                        ),
                        infoWindow: const InfoWindow(
                          title: "Kastamonu Üniversitesi",
                          snippet:
                              "Kuzeykent, 37210 Sarıömer/Kastamonu Merkez/Kastamonu",
                        ),
                      ),
                    },
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const ContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[100],
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }
}
