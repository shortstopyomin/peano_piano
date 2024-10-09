import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peano_piano/global/coloors.dart';
import 'package:peano_piano/global/constants.dart';
import 'package:peano_piano/services/autio_player.dart';
import 'package:peano_piano/widgets/piano.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> pressedKeys = [];

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        final key = event.logicalKey.keyLabel.toLowerCase();
        if (event is RawKeyDownEvent &&
            !pressedKeys.contains(key) &&
            keyToNote.keys.contains(key)) {
          setState(() => pressedKeys.add(key));
          AudioPlayerService.instance.play(keyToNote[key]!);
        } else if (event is RawKeyUpEvent) {
          setState(() => pressedKeys.remove(key));
        }
      },
      child: Scaffold(
        backgroundColor: Coloors.backgroundColor,
        // backgroundColor: Coloors.bgColor,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: Image(
                image: const AssetImage('assets/keyboard_border.png'),
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height - 24,
                fit: BoxFit.fill,
              ),
            ),
            Center(child: Piano(pressedKeys: pressedKeys)),
          ],
        ),
      ),
    );
  }
}
