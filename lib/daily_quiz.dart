import 'package:flutter/material.dart';
import 'config.dart';

class DailyMoodQuiz extends StatefulWidget {
  final String lang; // 'en' or 'hi'
  final void Function(String result, int score) onComplete;

  const DailyMoodQuiz({
    super.key,
    required this.lang,
    required this.onComplete,
  });

  @override
  State<DailyMoodQuiz> createState() => _DailyMoodQuizState();
}

class _DailyMoodQuizState extends State<DailyMoodQuiz> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;

  bool get _isHindi => widget.lang == 'hi';

  // Mood questions in EN + HI
  final List<Map<String, dynamic>> _questions = [
    {
      'question_en': 'How are you feeling right now?',
      'question_hi': 'आप अभी कैसा महसूस कर रहे हैं?',
      'options_en': ['Happy 😀', 'Okay 🙂', 'Sad 😔'],
      'options_hi': ['खुश 😀', 'ठीक-ठाक 🙂', 'उदास 😔'],
      'scores': [2, 1, 0],
    },
    {
      'question_en': 'How was your energy today?',
      'question_hi': 'आज आपकी ऊर्जा कैसी रही?',
      'options_en': ['High ⚡', 'Normal 🙂', 'Low 😴'],
      'options_hi': ['ज़्यादा ⚡', 'सामान्य 🙂', 'कम 😴'],
      'scores': [2, 1, 0],
    },
    {
      'question_en': 'How stressed do you feel?',
      'question_hi': 'आप कितना तनाव महसूस कर रहे हैं?',
      'options_en': ['Not at all 😌', 'A bit 😕', 'Very 😣'],
      'options_hi': ['बिलकुल नहीं 😌', 'थोड़ा सा 😕', 'बहुत ज़्यादा 😣'],
      'scores': [2, 1, 0],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_currentIndex];
    final total = _questions.length;
    final progress = (_currentIndex + 1) / total;

    final String questionText = _isHindi
        ? question['question_hi'] as String
        : question['question_en'] as String;
    final List<String> options = (_isHindi
            ? question['options_hi']
            : question['options_en']) as List<String>;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          _isHindi
              ? 'प्रश्न ${_currentIndex + 1} / $total'
              : 'Question ${_currentIndex + 1}/$total',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress label
              Text(
                _isHindi ? 'प्रगति' : 'Progress',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Question text
              Text(
                questionText,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Answer options
              ...List.generate(
                options.length,
                (index) {
                  final option = options[index];
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : theme.colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : theme.dividerColor.withOpacity(0.4),
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Next / Finish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex == null ? null : _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex == total - 1
                        ? (_isHindi ? 'समाप्त करें' : 'Finish')
                        : (_isHindi ? 'आगे बढ़ें' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNextPressed() async {
    final question = _questions[_currentIndex];
    final scores = question['scores'] as List<int>;
    _score += scores[_selectedIndex ?? 0];

    final bool isLast = _currentIndex == _questions.length - 1;

    if (!isLast) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
      return;
    }

    // ----- Last question: compute overall label (EN for storage) -----
    final String label;
    if (_score >= 5) {
      label = 'Positive';
    } else if (_score >= 3) {
      label = 'Neutral';
    } else {
      label = 'Low';
    }

    // Let parent save to Firestore with English label
    widget.onComplete(label, _score);

    // Build localized AI-style message
    final message = _buildAISummaryForMood(label, _score);

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            _isHindi ? 'आपका मूड सारांश' : 'Your mood summary',
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_isHindi ? 'ठीक है' : 'OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // close quiz screen
  }

  String _buildAISummaryForMood(String label, int score) {
    if (_isHindi) {
      // HINDI VERSIONS
      if (label == 'Positive') {
        return '''
आप अभी काफ़ी पॉज़िटिव और हल्का महसूस कर रहे हैं 🔆
आपके जवाब दिखाते हैं कि आपका मूड और ऊर्जा अभी अच्छी स्थिति में हैं।

कुछ छोटे, प्यारे सुझाव:
• आज के अच्छे पलों को याद करें और खुद को शाबाशी दें।
• अपनी यह पॉज़िटिव एनर्जी किसी अपने के साथ शेयर करें।
• रात को सोने से पहले 2–3 चीज़ें लिखें, जिनके लिए आप शुक्रगुज़ार हैं।

फील-गुड फ़िल्में:
• Zindagi Na Milegi Dobara
• Yeh Jawaani Hai Deewani
• The Pursuit of Happyness

आरामदायक किताबें:
• "The Alchemist" – Paulo Coelho
• "Ikigai"
• कोई भी हल्की-फुल्की स्टोरी/नोवेल जो आपको पसंद हो
''';
      } else if (label == 'Neutral') {
        return '''
आज आप ना बहुत अच्छे मूड में हैं, ना बहुत बुरे – बस "ठीक-ठाक" 🙂 
यह बहुत सामान्य और इंसानी अनुभव है।

थोड़ी सी self-care जो मदद कर सकती है:
• 10–15 मिनट टहलें या हल्का स्ट्रेच करें।
• किसी दोस्त/परिवार वाले से casually बात करें।
• अपने लिए एक छोटा सा "me time" रखें – म्यूज़िक, स्केचिंग, या बस चुपचाप बैठना।

हल्की, पॉज़िटिव फ़िल्में:
• Chhichhore
• The Intern
• Wake Up Sid

आसान और अच्छा पढ़ने के लिए:
• "Tuesdays with Morrie"
• "The Little Prince"
• कोई छोटी स्टोरी बुक या ब्लॉग जो आपको अच्छा महसूस कराए
''';
      } else {
        // Low – Hindi
        return '''
लगता है आज आपका मूड थोड़ा भारी या उदास है 💙
यह महसूस करना कि आप अभी ठीक नहीं हैं, अपने आप में एक साहसिक कदम है।

कुछ छोटे, gentle कदम:
• किसी भरोसेमंद व्यक्ति (दोस्त, परिवार, टीचर) से खुलकर बात करने की कोशिश करें।
• थोड़ा पानी पिएं, हल्का-सा कुछ खाएँ, और अगर हो सके तो थोड़ी नींद पूरी करें।
• खुद को कोसने के बजाय अपने आप से ऐसे बात करें जैसे किसी अच्छे दोस्त से करते हैं।
• अगर कई दिनों से ऐसा ही महसूस हो रहा है, तो किसी counselor/therapist से बात करना बहुत मददगार हो सकता है।

सुकून देने वाली फ़िल्में:
• Taare Zameen Par
• Dear Zindagi
• Good Will Hunting

दिल को छूने वाली किताबें:
• "Man’s Search for Meaning"
• "Tuesdays with Morrie"
• कोई भी ऐसी किताब/शायरी जो आपको समझे जाने का एहसास दिलाए
''';
      }
    } else {
      // ENGLISH VERSIONS (same idea as before)
      if (label == 'Positive') {
        return '''
You seem to be in a bright and positive space today 🔆
Your answers suggest that your mood and energy are generally uplifted.

Here are a few gentle suggestions:
• Celebrate small wins from your day.
• Share your good energy with someone you care about.
• Keep a short journal entry about what went well today.

Feel-good movies:
• Inside Out
• The Secret Life of Walter Mitty
• The Pursuit of Happyness

Comforting books:
• "The Little Prince" – Antoine de Saint-Exupéry
• "The Alchemist" – Paulo Coelho
• "Ikigai" – Héctor García & Francesc Miralles
''';
      } else if (label == 'Neutral') {
        return '''
You seem to be somewhere in the middle today – not bad, not amazing, just okay 🙂
That’s a very normal and human place to be.

Some gentle ideas that might lift your day:
• Take a short walk or stretch for a few minutes.
• Message a friend and check in with them.
• Do one small thing you enjoy (music, art, a short video).

Light movies:
• The Intern
• Chef
• Zindagi Na Milegi Dobara

Easy, warm reads:
• "The Midnight Library" – Matt Haig
• "Tuesdays with Morrie" – Mitch Albom
• Any short story collection you enjoy
''';
      } else {
        // Low – English
        return '''
You might be feeling low or weighed down today 💙
That’s okay, and it’s important that you noticed and checked in with yourself.

Small, kind steps you can try:
• Talk to someone you trust about how you feel.
• Drink some water and have a simple meal or snack.
• Do one very small, gentle activity: slow music, journaling, deep breathing.
• If these feelings stay heavy for many days, consider talking to a counselor or professional.

Comfort movies:
• Taare Zameen Par
• Good Will Hunting
• Dear Zindagi

Soothing books:
• "Tuesdays with Morrie" – Mitch Albom
• "Man’s Search for Meaning" – Viktor Frankl
• A simple poetry or quote book you like
''';
      }
    }
  }
}
