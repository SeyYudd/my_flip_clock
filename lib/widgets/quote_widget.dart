import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  String _quote = "Kalau bercanda jangan kelewatan, muter baliknya jauh.";
  Color _backgroundColor = const Color(0xFF4A148C); // deepPurple.shade900
  Color _textColor = Colors.white;
  bool _showEditButton = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quote =
          prefs.getString('quote_text') ??
          "Kalau bercanda jangan kelewatan, muter baliknya jauh.";
      _backgroundColor = Color(
        prefs.getInt('quote_bg_color') ?? const Color(0xFF4A148C).value,
      );
      _textColor = Color(
        prefs.getInt('quote_text_color') ?? Colors.white.value,
      );
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quote_text', _quote);
    await prefs.setInt('quote_bg_color', _backgroundColor.value);
    await prefs.setInt('quote_text_color', _textColor.value);
  }

  void _showEditDialog() {
    final textController = TextEditingController(text: _quote);
    Color tempBgColor = _backgroundColor;
    Color tempTextColor = _textColor;

    final colors = [
      const Color(0xFF4A148C), // deepPurple.shade900
      const Color(0xFF1A237E), // indigo.shade900
      const Color(0xFF0D47A1), // blue.shade900
      const Color(0xFF004D40), // teal.shade900
      const Color(0xFF1B5E20), // green.shade900
      const Color(0xFFFF6F00), // amber.shade900
      const Color(0xFFE65100), // orange.shade900
      const Color(0xFFB71C1C), // red.shade900
      const Color(0xFF880E4F), // pink.shade900
      const Color(0xFF212121), // grey.shade900
      const Color(0xFF263238), // blueGrey.shade900
      const Color(0xFF3E2723), // brown.shade900
      Colors.black,
    ];

    final textColors = [
      Colors.white,
      const Color(0xB3FFFFFF), // white70
      Colors.amber,
      Colors.cyan,
      Colors.lightGreen,
      const Color(0xFFF48FB1), // pink.shade200
      const Color(0xFFFFCC80), // orange.shade200
      const Color(0xFFE0E0E0), // grey.shade300
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Edit Quote',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote text field
                TextField(
                  controller: textController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Masukkan quote...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Background color
                const Text(
                  'Background',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) {
                    final isSelected = tempBgColor.value == color.value;
                    return GestureDetector(
                      onTap: () => setDialogState(() => tempBgColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Text color
                const Text(
                  'Warna Teks',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: textColors.map((color) {
                    final isSelected = tempTextColor.value == color.value;
                    return GestureDetector(
                      onTap: () => setDialogState(() => tempTextColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade700,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: color == Colors.white
                                    ? Colors.black
                                    : Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Preview
                const Text(
                  'Preview',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tempBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    textController.text.isEmpty
                        ? 'Preview quote...'
                        : textController.text,
                    style: TextStyle(
                      color: tempTextColor,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                setState(() {
                  _quote = textController.text.trim().isEmpty
                      ? "Kalau bercanda jangan kelewatan, muter baliknya jauh."
                      : textController.text.trim();
                  _backgroundColor = tempBgColor;
                  _textColor = tempTextColor;
                });
                _saveSettings();
                Navigator.pop(ctx);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showEditButton = !_showEditButton),
      child: Stack(
        children: [
          // Background with gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundColor,
                  _backgroundColor.withOpacity(0.7),
                  Colors.black,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Quote icon
                  Icon(
                    Icons.format_quote,
                    size: 32,
                    color: _textColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  // Quote text
                  Text(
                    _quote,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Edit button
          if (_showEditButton)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _showEditDialog,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
