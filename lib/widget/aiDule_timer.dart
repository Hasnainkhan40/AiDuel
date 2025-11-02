import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedTimer extends StatefulWidget {
  final bool stopTimer;
  final VoidCallback onTimeUp; // 🔥 Callback when 29 seconds reached

  const AnimatedTimer({
    super.key,
    required this.stopTimer,
    required this.onTimeUp,
  });

  @override
  State<AnimatedTimer> createState() => _AnimatedTimerState();
}

class _AnimatedTimerState extends State<AnimatedTimer> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant AnimatedTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🛑 Stop timer when parent says stopTimer = true
    if (widget.stopTimer && _timer != null) {
      _stopTimer();
    } else if (!widget.stopTimer && _timer == null) {
      _resetTimer();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds < 29) {
        setState(() => _seconds++);
      } else {
        _stopTimer();
        widget.onTimeUp(); // ⏰ Notify parent
      }
    });
  }

  void _resetTimer() {
    setState(() => _seconds = 0);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [Colors.cyanAccent.shade100, Colors.blueAccent.shade400],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Text(_formattedTime),
      ),
    );
  }
}
