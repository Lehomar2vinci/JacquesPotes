import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

void main() {
  runApp(const BanditManchotApp());
}

class BanditManchotApp extends StatelessWidget {
  const BanditManchotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Bandit Manchot')),
        body: const BanditManchot(),
      ),
    );
  }
}

class BanditManchot extends StatefulWidget {
  const BanditManchot({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BanditManchotState createState() => _BanditManchotState();
}

class _BanditManchotState extends State<BanditManchot> {
  late ConfettiController _confettiController;
  List<String> icones = [
    'assets/images/bar.png',
    'assets/images/cerise.png',
    'assets/images/cloche.png',
    'assets/images/diamant.png',
    'assets/images/fer-a-cheval.png',
    'assets/images/pasteque.png',
    'assets/images/sept.png',
  ];
  bool boutonBloque = false;

  bool isLightVisible = false;

  List<String> resultat = ['', '', ''];
  String message = '';
  bool jackpot = false;

  void jouer() async {
    setState(() {
      resultat =
          List.generate(3, (index) => icones[Random().nextInt(icones.length)]);
      if (resultat[0] == resultat[1] && resultat[1] == resultat[2]) {
        message = 'Jackpot !!!';
        if (resultat[0] == 'assets/images/sept.png') {
          message += ' avec le symbole 7!';
          jackpot = true;
          _confettiController.play();
        }
      } else {
        message = 'Perdu, essayez encore !!';
        jackpot = false;
      }
      isLightVisible = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      isLightVisible = false;
    });

    //bloque le bouton pendant 5 secondes
    Timer(const Duration(seconds: 5), () {
      setState(() {
        boutonBloque = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 15));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> playButtonSound() async {
    AudioCache audioCache = AudioCache();
    await audioCache.load('sounds/beep.mp3');
    // await audioCache.('assets/sounds/beep.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          maxBlastForce: 7,
          minBlastForce: 2,
          emissionFrequency: 0.05,
          numberOfParticles: 90,
          gravity: 0.8,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Color.fromARGB(255, 251, 255, 0),
            Colors.purple,
            Colors.orange
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: resultat.map((icone) {
            if (jackpot && icone == 'assets/images/sept.png') {
              return AnimatedSizeAndFade(
                fadeDuration: const Duration(milliseconds: 500),
                sizeDuration: const Duration(milliseconds: 500),
                child: Image.asset(icone, width: 100, height: 100),
              );
            } else {
              return Image.asset(icone, width: 100, height: 100);
            }
          }).toList(),
        ),
        const SizedBox(height: 40),
        Text(message, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 50),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                jouer();
                Vibration.vibrate(
                  pattern: [10, 50, 0, 1000], //pattern de vibration
                );
                playButtonSound();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Jouer'),
            ),
          ),
        ),
        Visibility(
          visible: isLightVisible,
          child:
              Image.asset('assets/images/francs.jpeg', height: 350, width: 350),
          //source : https://www.ekonomico.fr/wp-content/uploads/2012/02/183480_des-billets-en-francs.jpeg
        ),
      ],
    );
  }
}
