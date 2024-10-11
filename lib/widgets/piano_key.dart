import 'package:flutter/material.dart';
import 'package:peano_piano/global/coloors.dart';
import 'package:peano_piano/global/constants.dart';
import 'package:peano_piano/services/autio_player.dart';

class PianoKey extends StatelessWidget {
  const PianoKey({
    super.key,
    required this.note,
    required this.pressed,
  });

  final String note;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    bool isAccidental = note.length == 2;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: note == 'c'? const Radius.circular(16): const Radius.circular(0),
            topRight: note == 'b'? const Radius.circular(16): const Radius.circular(0),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16)),
      ),
      color: Coloors.keyColor,
      child: InkWell(
        highlightColor: Coloors.activeKeyColor,
        splashColor: Coloors.activeKeyColor,
        borderRadius: BorderRadius.circular(16.0),
        onTapDown: (_) => AudioPlayerService.instance.play(note),
        child: Container(
          height: keyHeight,
          width: keyWidth,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Coloors.borderColor, width: 2),
            borderRadius: BorderRadius.only(
                topLeft: note == 'c'? Radius.circular(16): Radius.circular(0),
                topRight: note == 'b'? Radius.circular(16): Radius.circular(0),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
          ),
          padding: const EdgeInsets.only(bottom: 24),
          child: Visibility(
            visible: !isAccidental,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                note.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlackPianoKey extends StatelessWidget {
  const BlackPianoKey({
    super.key,
    required this.note,
    required this.pressed,
  });

  final String note;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: pressed
          ? Coloors.activeKeyColor
          : Colors.transparent,
          // : Coloors.accidentalKeyColor,
      child: InkWell(
        highlightColor: Coloors.blackKeyActiveColor,
        splashColor: Coloors.blackKeyActiveColor,
        borderRadius: BorderRadius.circular(24.0),
        onTapDown: (_) {
          AudioPlayerService.instance.play(note);
        },
        child: const Image(
          image: AssetImage('assets/black_key.png'),
          width: 72,
          height: 100,
          fit: BoxFit.contain,
        ),
        // child: Container(
        //   height: keyHeight * 0.6,
        //   width: keyWidth / 2,
        //   decoration: BoxDecoration(
        //     color: Colors.transparent,
        //     border: Border.all(color: Coloors.borderColor, width: 2),
        //   ),
        // ),
      ),
    );
  }
}
