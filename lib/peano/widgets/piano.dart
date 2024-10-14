import 'package:flutter/material.dart';
import 'package:peano_piano/peano/global/constants.dart';
import 'package:peano_piano/peano/widgets/piano_key.dart';

class Piano extends StatelessWidget {
  const Piano({super.key, required this.pressedKeys});

  final List<String> pressedKeys;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 88.0, bottom: 14),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: notes
                .map(
                  (note) => note.length == 2
                      ? const SizedBox.shrink()
                      : PianoKey(
                          note: note,
                          pressed: pressedKeys.contains(noteToKey[note]),
                        ),
                )
                .toList(),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: notes.map(
              (note) {
                if (note.length == 1) {
                  return const SizedBox.shrink();
                }
                double leftPadding = keyWidth * 0.18;
                if (note == "df") leftPadding = keyWidth * 0.6;
                if (note == "gf") leftPadding = keyWidth * 1.4;
                return Padding(
                  padding: EdgeInsets.only(left: leftPadding),
                  child: BlackPianoKey(
                    note: note,
                    pressed: pressedKeys.contains(noteToKey[note]),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
