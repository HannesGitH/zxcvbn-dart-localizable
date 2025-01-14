import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zxcvbn/zxcvbn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Password Checker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  final bool showSuggestions = false;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final zxcvbn = Zxcvbn();

  Result? _result;

  _evaluatePassword(String password) {
    setState(() {
      if (password.length <= 1) {
        _result = null;
        return;
      }
      _result = zxcvbn.evaluate(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoTextField(
                onChanged: _evaluatePassword,
                placeholder: 'Password',
              ),
              const SizedBox(height: 10),
              if (_result != null) ...[
                ScoreVisualizer(score: _result!.score!.toInt()),
                const SizedBox(height: 20),
                if (_result!.feedback.warning?.isNotEmpty ?? false)
                  Warning(
                    warning: _result!.feedback.warning!,
                  ),
                const SizedBox(height: 10),
                if (widget.showSuggestions &&
                    (_result!.feedback.suggestions?.isNotEmpty ?? false))
                  Suggestions(
                    suggestions: _result!.feedback.suggestions!,
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class Warning extends StatelessWidget {
  const Warning({
    super.key,
    required this.warning,
  });

  final String warning;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_rounded, color: Colors.orangeAccent),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            warning,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class Suggestions extends StatelessWidget {
  const Suggestions({
    super.key,
    required this.suggestions,
  });

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var suggestion in suggestions) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_rounded, color: Colors.grey),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  suggestion,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ],
    );
  }
}

class ScoreVisualizer extends StatelessWidget {
  const ScoreVisualizer({
    super.key,
    required this.score,
    this.guessesLog10,
  });

  final int score;

  /// if given, the color will be continuous, and based on this score
  final double? guessesLog10;

  Color get color => switch (score) {
        0 => Colors.red,
        1 => Colors.orange,
        2 => Colors.yellow,
        3 => Colors.lime,
        4 => Colors.green,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(width: 5),
        for (var i = 0; i < 5; i++) ...[
          Expanded(
            child: AnimatedContainer(
              height: 3,
              decoration: BoxDecoration(
                color: i <= score ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ],
    );
  }
}
