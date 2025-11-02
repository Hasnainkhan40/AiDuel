import 'dart:math';
import 'package:aiduel/widget/aiDule_timer.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIDuelScreen extends StatefulWidget {
  const AIDuelScreen({super.key});

  @override
  State<AIDuelScreen> createState() => _AIDuelScreenState();
}

class _AIDuelScreenState extends State<AIDuelScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  late AnimationController _micPulseController;
  late AnimationController _sendController;
  bool _stopTimer = false;

  int _player1Score = 0;
  int _player2Score = 0;
  bool _isPlayer1Turn = true;

  //  List of Hinglish → English pairs
  final List<Map<String, String>> _wordPairs = [
    {"hinglish": "alvida", "english": "goodbye"},
    {"hinglish": "namaste", "english": "hello"},
    {"hinglish": "pyaar", "english": "love"},
    {"hinglish": "shukriya", "english": "thank you"},
    {"hinglish": "dost", "english": "friend"},
    {"hinglish": "khushi", "english": "happiness"},
    {"hinglish": "zindagi", "english": "life"},
    {"hinglish": "bhook", "english": "hunger"},
    {"hinglish": "paise", "english": "money"},
    {"hinglish": "ghar", "english": "home"},
    {"hinglish": "dil", "english": "heart"},
    {"hinglish": "mohabbat", "english": "affection"},
    {"hinglish": "samay", "english": "time"},
    {"hinglish": "raat", "english": "night"},
    {"hinglish": "din", "english": "day"},
    {"hinglish": "suraj", "english": "sun"},
    {"hinglish": "chand", "english": "moon"},
    {"hinglish": "taare", "english": "stars"},
    {"hinglish": "paani", "english": "water"},
    {"hinglish": "aag", "english": "fire"},
    {"hinglish": "hawaa", "english": "air"},
    {"hinglish": "mitti", "english": "soil"},
    {"hinglish": "roti", "english": "bread"},
    {"hinglish": "chai", "english": "tea"},
    {"hinglish": "bacha", "english": "child"},
    {"hinglish": "ladka", "english": "boy"},
    {"hinglish": "ladki", "english": "girl"},
    {"hinglish": "maa", "english": "mother"},
    {"hinglish": "baap", "english": "father"},
    {"hinglish": "bhai", "english": "brother"},
    {"hinglish": "behen", "english": "sister"},
    {"hinglish": "padhai", "english": "study"},
    {"hinglish": "kaam", "english": "work"},
    {"hinglish": "neend", "english": "sleep"},
    {"hinglish": "sapna", "english": "dream"},
    {"hinglish": "muskaan", "english": "smile"},
    {"hinglish": "dard", "english": "pain"},
    {"hinglish": "aansoo", "english": "tears"},
    {"hinglish": "shaanti", "english": "peace"},
    {"hinglish": "jung", "english": "war"},
    {"hinglish": "jeet", "english": "victory"},
    {"hinglish": "haar", "english": "defeat"},
    {"hinglish": "jaldi", "english": "hurry"},
    {"hinglish": "aaj", "english": "today"},
    {"hinglish": "kal", "english": "tomorrow"},
    {"hinglish": "parso", "english": "day after tomorrow"},
    {"hinglish": "bahar", "english": "outside"},
    {"hinglish": "andar", "english": "inside"},
    {"hinglish": "upar", "english": "up"},
    {"hinglish": "neeche", "english": "down"},
    {"hinglish": "haath", "english": "hand"},
    {"hinglish": "pair", "english": "foot"},
    {"hinglish": "aankh", "english": "eye"},
    {"hinglish": "kaana", "english": "ear"},
    {"hinglish": "muh", "english": "mouth"},
    {"hinglish": "naak", "english": "nose"},
  ];

  late Map<String, String> _currentWord;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _currentWord = _getRandomWord();

    _micPulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
          lowerBound: 0.9,
          upperBound: 1.1,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _micPulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _micPulseController.forward();
          }
        });

    _sendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.8,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _sendController.dispose();
    _textController.dispose();
    super.dispose();
  }

  //  Random Hinglish → English word picker
  Map<String, String> _getRandomWord() {
    final random = Random();
    return _wordPairs[random.nextInt(_wordPairs.length)];
  }

  //  Called when timer ends
  void _handleTimeUp() {
    setState(() {
      if (_isPlayer1Turn) {
        _player1Score -= 10;
      } else {
        _player2Score -= 10;
      }
      _stopTimer = true;
    });

    _showResultPopup(false, isTimeout: true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isPlayer1Turn = !_isPlayer1Turn;
        _stopTimer = false;
        _currentWord = _getRandomWord(); // New word each turn
      });
    });
  }

  void _showResultPopup(bool isCorrect, {bool isTimeout = false}) {
    final playerImage = _isPlayer1Turn
        ? "assets/images/avatar1.png"
        : "assets/images/avatar2.png";
    final message = isTimeout
        ? "⏰ Time's up! -10 Points"
        : (isCorrect ? "+10 Points 🎉" : "-10 Points ❌");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            _isPlayer1Turn ? "Player 1" : "Player 2",
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(backgroundImage: AssetImage(playerImage), radius: 40),
            const SizedBox(height: 15),
            Text(
              message,
              style: TextStyle(
                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isPlayer1Turn = !_isPlayer1Turn;
                _stopTimer = false;
                _currentWord = _getRandomWord(); //  Load next word
              });
            },
            child: const Text(
              "Next Turn →",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final inputText = _textController.text.trim();
    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please type or speak something before sending!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    _stopListening();

    final correctAnswer = _currentWord["english"]!;
    final isCorrect = inputText.toLowerCase() == correctAnswer.toLowerCase();

    setState(() {
      if (_isPlayer1Turn) {
        _player1Score += isCorrect ? 10 : -10;
      } else {
        _player2Score += isCorrect ? 10 : -10;
      }
      _stopTimer = true;
      _voiceText = '';
    });

    _textController.clear();
    _sendController
      ..reset()
      ..forward();

    _showResultPopup(isCorrect);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _micPulseController.forward();

        _speech.listen(
          onResult: (val) {
            setState(() {
              _voiceText = val.recognizedWords;
              _textController.text = _voiceText;
            });

            //  Stop mic automatically when speech ends
            if (val.finalResult) {
              _stopListening();
            }
          },
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    _micPulseController.stop();
    _micPulseController.reset();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                _buildTitle(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAvatar(
                      "assets/images/avatar1.png",
                      active: _isPlayer1Turn,
                    ),
                    AnimatedTimer(
                      stopTimer: _stopTimer,
                      onTimeUp: _handleTimeUp,
                    ),
                    _buildAvatar(
                      "assets/images/avatar2.png",
                      active: !_isPlayer1Turn,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreCard("Player 1", _player1Score),
                    _buildScoreCard("Player 2", _player2Score),
                  ],
                ),
                const SizedBox(height: 80),

                //  Show Hinglish Question
                _buildWordBubble(_currentWord["hinglish"] ?? ""),
                const SizedBox(height: 60),
                _buildMicButton(),
                const SizedBox(height: 60),
                _buildTextInput(),
                const SizedBox(height: 30),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI components ---
  Widget _buildTitle() => ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Colors.cyanAccent, Colors.blueAccent],
    ).createShader(bounds),
    child: const Text(
      "AI DUEL",
      style: TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildAvatar(String path, {bool active = false}) {
    return CircleAvatar(
      radius: active ? 38 : 30,
      backgroundColor: active
          ? Colors.cyanAccent
          : Colors.white.withOpacity(0.1),
      child: CircleAvatar(
        radius: active ? 35 : 28,
        backgroundImage: AssetImage(path),
      ),
    );
  }

  Widget _buildScoreCard(String name, int score) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "$score",
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMicButton() => GestureDetector(
    onTap: _listen,
    child: ScaleTransition(
      scale: _isListening
          ? _micPulseController
          : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 95,
        height: 95,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isListening ? Colors.greenAccent : Colors.cyanAccent,
            width: 2.5,
          ),
        ),
        child: Icon(
          _isListening ? Icons.mic_none : Icons.mic,
          size: 42,
          color: _isListening ? Colors.greenAccent : Colors.white,
        ),
      ),
    ),
  );

  Widget _buildTextInput() => Container(
    width: 230,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
    ),
    child: TextField(
      controller: _textController,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.cyanAccent,
      decoration: const InputDecoration(
        hintText: "Type your answer...",
        hintStyle: TextStyle(color: Colors.white60),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      onChanged: (text) {
        //  Stop mic & pulse when user starts typing
        if (_isListening) {
          _stopListening();
        }
      },
    ),
  );

  Widget _buildSendButton() => ScaleTransition(
    scale: _sendController,
    child: GestureDetector(
      onTap: _handleSend,
      child: Container(
        width: 85,
        height: 65,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.cyanAccent, Colors.blueAccent],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Icon(Icons.send_rounded, color: Colors.black, size: 30),
      ),
    ),
  );
}
