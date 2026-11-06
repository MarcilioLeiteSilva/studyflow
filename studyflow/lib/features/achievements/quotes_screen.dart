import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  static const List<Map<String, String>> _quotes = [
    {
      'text': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
    },
    {
      'text': 'It always seems impossible until it’s done.',
      'author': 'Nelson Mandela',
    },
    {
      'text': 'Don’t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson',
    },
    {
      'text': 'Believe you can and you’re halfway there.',
      'author': 'Theodore Roosevelt',
    },
    {
      'text': 'Success is the sum of small efforts, repeated day in and day out.',
      'author': 'Robert Collier',
    },
    {
      'text': 'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'Eleanor Roosevelt',
    },
    {
      'text': 'You don’t have to be great to start, but you have to start to be great.',
      'author': 'Zig Ziglar',
    },
  ];

  void _shareQuote(String text, String author) {
    Share.share('"$text" - $author #StudyPlannerPro');
  }

  void _copyQuote(BuildContext context, String text, String author) {
    Clipboard.setData(ClipboardData(text: '"$text" - $author'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Motivation')),
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _quotes.length,
          itemBuilder: (context, index) {
            final quote = _quotes[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote, size: 40, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            quote['text']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '- ${quote['author']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () => _copyQuote(context, quote['text']!, quote['author']!),
                                tooltip: 'Copy',
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, size: 20),
                                onPressed: () => _shareQuote(quote['text']!, quote['author']!),
                                tooltip: 'Share',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
