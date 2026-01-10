import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Colors.purple.withValues(alpha: 0.1),
              Colors.blue.withValues(alpha: 0.1),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 20),

                // App Icon & Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.watch_later_outlined,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'My Stand Clock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'v1.0.0',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // About Section
                _buildSection(
                  title: '✨ Tentang Aplikasi',
                  content:
                      'Halo! Ini adalah aplikasi jam stand yang keren banget buat nemenin aktivitas kamu. '
                      'Bisa buat display di meja kerja, stand phone, atau monitor kedua. '
                      'Gak cuma jam biasa, tapi ada banyak widget seru yang bisa kamu custom sesuka hati!',
                ),

                const SizedBox(height: 24),

                // Features
                _buildSection(title: '🎯 Fitur Unggulan', content: null),
                const SizedBox(height: 12),
                _buildFeatureItem('Jam Analog & Digital yang customizable'),
                _buildFeatureItem('Cuaca real-time (biar gak salah pake baju)'),
                _buildFeatureItem('Now Playing - tau lagi dengerin lagu apa'),
                _buildFeatureItem('Countdown & Stopwatch buat produktivitas'),
                _buildFeatureItem('Quote inspiratif buat motivasi harian'),
                _buildFeatureItem('Calendar & Notes buat reminder'),
                _buildFeatureItem('Photo Frame - pajang foto kesayangan'),
                _buildFeatureItem('GIF Player buat hiburan'),
                _buildFeatureItem('Burn-in protection buat OLED'),

                const SizedBox(height: 32),

                // Fun fact
                _buildSection(
                  title: '💡 Fun Fact',
                  content:
                      'Aplikasi ini dibuat dengan cinta dan kopi (lots of coffee ☕). '
                      'Perfect buat yang suka multitasking sambil kerja atau study. '
                      'Jadiin HP lama kamu berguna lagi sebagai jam meja yang aesthetic!',
                ),

                const SizedBox(height: 32),

                // Developer info
                _buildSection(
                  title: '👨‍💻 Developer',
                  content:
                      'Dibuat oleh developer yang hobi ngoding sambil dengerin music dan ngopi. '
                      'Kalau ada bug atau saran, feel free to reach out!',
                ),

                const SizedBox(height: 24),

                // Contact buttons
                Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildContactButton(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () => _launchUrl('mailto:yudddev@gmail.com'),
                      ),
                      _buildContactButton(
                        icon: Icons.code,
                        label: 'GitHub',
                        onTap: () => _launchUrl('https://github.com/SeyYudd'),
                      ),
                      _buildContactButton(
                        icon: Icons.star_outline,
                        label: 'Rate App',
                        onTap: () {
                          // TODO: Add play store link
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Coming soon to Play Store!'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Credits
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Made with ❤️ in Indonesia',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '© 2026 My Stand Clock',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, String? content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (content != null) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
