import 'package:flutter/material.dart';
import 'config.dart';

class WellnessAssessment extends StatefulWidget {
  final String lang; // 'en' or 'hi'
  final void Function(String result, int score) onComplete;

  const WellnessAssessment({
    super.key,
    required this.lang,
    required this.onComplete,
  });

  @override
  State<WellnessAssessment> createState() => _WellnessAssessmentState();
}

class _WellnessAssessmentState extends State<WellnessAssessment> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;

  bool get _isHindi => widget.lang == 'hi';

  // 10 questions, EN + HI
  final List<Map<String, dynamic>> _questions = [
    {
      'question_en': 'I slept well last night.',
      'question_hi': 'मैंने पिछली रात अच्छी नींद ली।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I have had enough energy today.',
      'question_hi': 'आज मेरे पास पर्याप्त ऊर्जा रही।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I have been able to focus on tasks.',
      'question_hi': 'मैं अपने कामों पर ध्यान केंद्रित कर पाया/पाई हूँ।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I have taken at least one break for myself today.',
      'question_hi': 'मैंने आज अपने लिए कम से कम एक ब्रेक लिया है।',
      'options_en': [
        'Yes, definitely',
        'Yes, a little',
        'Not sure',
        'Not really',
        'Not at all',
      ],
      'options_hi': [
        'हाँ, जरूर',
        'हाँ, थोड़ा बहुत',
        'पक्का नहीं',
        'ज्यादा नहीं',
        'बिलकुल नहीं',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I have eaten regular meals today.',
      'question_hi': 'मैंने आज नियमित रूप से खाना खाया है।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I feel connected to at least one person I trust.',
      'question_hi':
          'मैं कम से कम एक भरोसेमंद व्यक्ति से जुड़ा/जुड़ी महसूस करता/करती हूँ।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'My stress level today feels manageable.',
      'question_hi': 'आज मेरा तनाव स्तर संभालने योग्य लग रहा है।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I did at least one thing that made me feel good.',
      'question_hi':
          'मैंने आज कम से कम एक ऐसा काम किया जिसने मुझे अच्छा महसूस कराया।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'I have been kind to myself today.',
      'question_hi': 'मैंने आज अपने प्रति दयालुता दिखाई है।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
    {
      'question_en': 'Overall, I feel balanced today.',
      'question_hi': 'कुल मिलाकर, आज मैं संतुलित महसूस कर रहा/रही हूँ।',
      'options_en': [
        'Strongly agree',
        'Agree',
        'Neutral',
        'Disagree',
        'Strongly disagree',
      ],
      'options_hi': [
        'पूरी तरह सहमत',
        'सहमत',
        'तटस्थ',
        'असहमत',
        'बिलकुल असहमत',
      ],
      'scores': [4, 3, 2, 1, 0],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _questions.length;
    final question = _questions[_currentIndex];
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
              Text(
                _isHindi ? 'प्रगति' : 'Progress',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
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

              Text(
                questionText,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              ...List.generate(options.length, (index) {
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
              }),

              const Spacer(),

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

    // ----- compute wellness level -----
    final int maxScore = _questions.length * 4; // 10 * 4 = 40
    final double ratio = _score / maxScore;

    String key;
    if (ratio >= 0.75) {
      key = 'good';
    } else if (ratio >= 0.5) {
      key = 'ok';
    } else {
      key = 'low';
    }

    final visibleTitle = _resultTitle(key);
    final body = _resultBodyWithRecommendations(key);

    // Save to Firestore via callback
    widget.onComplete(visibleTitle, _score);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(visibleTitle),
          content: SingleChildScrollView(
            child: Text(
              body,
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
    Navigator.of(context).pop(); // close assessment
  }

  String _resultTitle(String key) {
    if (_isHindi) {
      switch (key) {
        case 'good':
          return 'आपकी वेलनेस अच्छी दिख रही है';
        case 'ok':
          return 'आपकी वेलनेस ठीक-ठाक है';
        case 'low':
        default:
          return 'आपकी वेलनेस को ध्यान की ज़रूरत है';
      }
    } else {
      switch (key) {
        case 'good':
          return 'Your wellness looks good';
        case 'ok':
          return 'Your wellness is okay';
        case 'low':
        default:
          return 'Your wellness needs attention';
      }
    }
  }

  String _resultBodyWithRecommendations(String key) {
    if (_isHindi) {
      switch (key) {
        case 'good':
          return '''
आप अपनी देखभाल अच्छी तरह कर रहे हैं 🌿
आपकी नींद, ऊर्जा और रोज़मर्रा की आदतें overall संतुलित दिख रही हैं।

कुछ छोटे सुझाव:
• इन हेल्दी आदतों को बनाए रखें (नींद, भोजन, ब्रेक)।
• जब ज़रूरत हो तो खुद को आराम देने की अनुमति दें।
• अपने अच्छे दिनों के बारे में थोड़ा लिखें, ताकि मुश्किल दिनों में याद रहे।

फील-गुड फ़िल्में:
• Zindagi Na Milegi Dobara
• Wake Up Sid
• Yeh Jawaani Hai Deewani

आरामदायक किताबें:
• "Ikigai"
• "The Little Prince"
• "The Alchemist"
''';

        case 'ok':
          return '''
आप ठीक हैं, लेकिन थोड़ी और self-care मदद कर सकती है 🙂
कभी-कभी थकान, तनाव या कम नींद आपकी वेलनेस को हल्का सा नीचे कर देते हैं।

कुछ gentle कदम:
• दिन में 1–2 बार सच में आराम वाला ब्रेक लें।
• थोड़ा हल्का व्यायाम या walk शामिल करें।
• किसी भरोसेमंद व्यक्ति से खुले दिल से बात करें।

हल्की-फुल्की फ़िल्में:
• Chhichhore
• Barfi!
• The Intern

कम्फ़र्ट रीड्स:
• "Tuesdays with Morrie"
• "The Subtle Art of Not Giving a F*ck" (चुनिंदा अध्याय)
• कोई भी छोटा मोटिवेशनल/स्टोरी बुक जो आपको पसंद हो
''';

        case 'low':
        default:
          return '''
आप अभी थोड़ा मुश्किल समय से गुज़र रहे हो सकते हैं 💙
आपकी वेलनेस स्कोर बताती है कि शरीर और मन दोनों को थोड़ा extra ध्यान चाहिए।

कुछ छोटे, दयालु कदम:
• किसी भरोसेमंद दोस्त/परिवार के सदस्य से खुलकर बात करें।
• कम से कम 1 सही भोजन, पर्याप्त पानी और 7–8 घंटे की नींद की कोशिश करें।
• खुद को दोष देने के बजाय "आज मैं बस थोड़ा gentle रहूँगा/रहूँगी" वाला attitude अपनाएं।
• अगर यह feeling कई दिनों/हफ़्तों तक रहे, तो किसी counselor/therapist से बात करना बहुत मददगार हो सकता है।

सुकून देने वाली फ़िल्में:
• Taare Zameen Par
• Dear Zindagi
• Good Will Hunting

दिल को छूने वाली किताबें:
• "Man’s Search for Meaning"
• "Tuesdays with Morrie"
• कोई भी ऐसी किताब/शायरियाँ जो आपको समझे जाने का एहसास दिलाए
''';
      }
    } else {
      switch (key) {
        case 'good':
          return '''
You seem to be taking good care of yourself 🌿
Your sleep, energy and daily habits look fairly balanced.

Gentle ideas:
• Keep these healthy routines (sleep, meals, small breaks).
• Allow yourself proper rest when you feel tired.
• Note down a few things that are working well for you right now.

Feel-good movies:
• Zindagi Na Milegi Dobara
• The Secret Life of Walter Mitty
• The Intern

Comforting books:
• "Ikigai"
• "The Little Prince"
• "The Alchemist"
''';

        case 'ok':
          return '''
You’re doing okay, but there’s room for more self-care 🙂
Some days may feel a bit heavy, and that’s normal.

Small supportive steps:
• Take 1–2 real breaks in the day where you put your phone aside.
• Try a short walk, stretch or light exercise.
• Talk to someone you trust about how life has been lately.

Light movies:
• Chhichhore
• Chef
• Barfi!

Easy, warm reads:
• "Tuesdays with Morrie"
• "The Midnight Library"
• Any short, uplifting story collection you enjoy
''';

        case 'low':
        default:
          return '''
You might be going through a tougher time right now 💙
Your wellness score suggests both body and mind need extra kindness.

Some very small, realistic steps:
• Reach out to a trusted friend, family member, or mentor and share how you feel.
• Try to get one proper meal, enough water and as much sleep as you can.
• Be kind to yourself – you are not your bad days or your score.
• If you’ve been feeling this way for many days or weeks, speaking to a counselor or mental health professional can really help.

Soothing movies:
• Taare Zameen Par
• Dear Zindagi
• Good Will Hunting

Gentle books:
• "Man’s Search for Meaning"
• "Tuesdays with Morrie"
• A poetry/quote book that makes you feel understood
''';
      }
    }
  }
}
