import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuotesScreen extends StatelessWidget {
  final Widget Function({required Widget child, EdgeInsets? margin})
  buildGlassCard;

  QuotesScreen({super.key, required this.buildGlassCard});

  final List<Map<String, String>> quotes = [
    {
      "quote":
          "The greatest glory in living lies not in never falling, but in rising every time we fall.",
      "author": "Nelson Mandela",
    },
    {
      "quote":
          "Your time is limited, so don't waste it living someone else's life.",
      "author": "Steve Jobs",
    },
    {
      "quote":
          "If life were predictable it would cease to be life, and be without flavor.",
      "author": "Eleanor Roosevelt",
    },
    {
      "quote":
          "Spread love everywhere you go. Let no one ever come to you without leaving happier.",
      "author": "Mother Teresa",
    },
    {
      "quote": "The way to get started is to quit talking and begin doing.",
      "author": "Walt Disney",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inspiration",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: quotes.length,
          itemBuilder: (context, index) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: buildGlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        size: 40,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        quotes[index]["quote"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "- ${quotes[index]["author"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            icon: Icons.copy_rounded,
                            label: "Copy",
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      "${quotes[index]["quote"]} - ${quotes[index]["author"]}",
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Quote copied to clipboard!"),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          _ActionButton(
                            icon: Icons.favorite_border_rounded,
                            label: "Like",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent[700]),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
