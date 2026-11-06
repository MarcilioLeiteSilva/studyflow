import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/models/flashcard_model.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Box<Flashcard> _box = Hive.box<Flashcard>('flashcards');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.flashcardsTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.flashcardsMyDecks),
            Tab(text: l10n.flashcardsReviewNow),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCardDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDecksList(isDark),
          _buildReviewSession(isDark),
        ],
      ),
    );
  }

  Widget _buildDecksList(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: _box.listenable(),
      builder: (context, Box<Flashcard> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.style_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n.flashcardsEmpty,
                  style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey),
                ),
                TextButton(
                  onPressed: () => _showAddCardDialog(context),
                  child: Text(l10n.flashcardsCreate),
                ),
              ],
            ),
          );
        }

        final cards = box.values.toList();
        // Group by subject
        final subjects = <String, List<Flashcard>>{};
        for (var card in cards) {
          if (!subjects.containsKey(card.subject)) {
            subjects[card.subject] = [];
          }
          subjects[card.subject]!.add(card);
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects.keys.elementAt(index);
              final subjectCards = subjects[subject]!;
              final dueCount = subjectCards.where((c) => c.nextReviewDate.isBefore(DateTime.now())).length;

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                          child: Text(
                            subject[0].toUpperCase(),
                            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          subject,
                          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(l10n.flashcardsCount(subjectCards.length)),
                        trailing: dueCount > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  l10n.flashcardsDue(dueCount),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              )
                            : const Icon(Icons.check_circle, color: Colors.green),
                        onTap: () {
                          // Navigate to detailed list or filter review
                          _tabController.animateTo(1);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReviewSession(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder(
      valueListenable: _box.listenable(),
      builder: (context, Box<Flashcard> box, _) {
        final dueCards = box.values
            .where((c) => c.nextReviewDate.isBefore(DateTime.now()))
            .toList()
          ..shuffle();

        if (dueCards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  l10n.flashcardsAllCaughtUp,
                  style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.flashcardsComeBackLater,
                  style: GoogleFonts.roboto(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return _FlashcardReviewer(cards: dueCards, onCardReviewed: _updateCardProgress);
      },
    );
  }

  void _updateCardProgress(Flashcard card, int quality) {
    // SM-2 Algorithm
    // quality: 0-5
    
    if (quality < 3) {
      card.repetitions = 0;
      card.interval = 1;
    } else {
      if (card.repetitions == 0) {
        card.interval = 1;
      } else if (card.repetitions == 1) {
        card.interval = 6;
      } else {
        card.interval = (card.interval * card.easeFactor).round();
      }
      card.repetitions += 1;
      card.easeFactor = card.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (card.easeFactor < 1.3) card.easeFactor = 1.3;
    }

    card.nextReviewDate = DateTime.now().add(Duration(days: card.interval));
    card.save();
  }

  void _showAddCardDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    final subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.flashcardsAddTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: l10n.flashcardsSubjectHint),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: InputDecoration(labelText: l10n.flashcardsQuestion),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: answerController,
              decoration: InputDecoration(labelText: l10n.flashcardsAnswer),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.btnCancel)),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                final newCard = Flashcard(
                  id: const Uuid().v4(),
                  question: questionController.text,
                  answer: answerController.text,
                  subject: subjectController.text.isEmpty ? 'General' : subjectController.text,
                  nextReviewDate: DateTime.now(),
                );
                _box.add(newCard);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.btnAdd),
          ),
        ],
      ),
    );
  }
}

class _FlashcardReviewer extends StatefulWidget {
  final List<Flashcard> cards;
  final Function(Flashcard, int) onCardReviewed;

  const _FlashcardReviewer({required this.cards, required this.onCardReviewed});

  @override
  State<_FlashcardReviewer> createState() => _FlashcardReviewerState();
}

class _FlashcardReviewerState extends State<_FlashcardReviewer> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_currentIndex >= widget.cards.length) {
      return const Center(child: CircularProgressIndicator()); // Should not happen due to parent rebuild
    }

    final card = widget.cards[_currentIndex];

    return Column(
      children: [
        LinearProgressIndicator(value: _currentIndex / widget.cards.length),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card.subject,
                          style: TextStyle(color: Colors.grey[600], letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          card.question,
                          style: GoogleFonts.merriweather(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_showAnswer) ...[
                          const Divider(height: 48, thickness: 2),
                          Text(
                            card.answer,
                            style: GoogleFonts.merriweather(
                              fontSize: 22,
                              color: Colors.blueAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          const SizedBox(height: 48),
                          Text(
                            l10n.flashcardsTapToShow,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showAnswer)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRatingButton(context, l10n.flashcardsHard, Colors.red, 1),
                _buildRatingButton(context, l10n.flashcardsGood, Colors.blue, 3),
                _buildRatingButton(context, l10n.flashcardsEasy, Colors.green, 5),
              ],
            ),
          )
        else
          const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRatingButton(BuildContext context, String label, Color color, int quality) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        widget.onCardReviewed(widget.cards[_currentIndex], quality);
        setState(() {
          _showAnswer = false;
          if (_currentIndex < widget.cards.length - 1) {
            _currentIndex++;
          }
        });
      },
      child: Text(label),
    );
  }
}
