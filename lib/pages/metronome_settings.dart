import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:metronome/metronome.dart';

class MetronomeSettings extends StatefulWidget {
  const MetronomeSettings({super.key});

  @override
  State<MetronomeSettings> createState() => _MetronomeSettingsState();
}

class _MetronomeSettingsState extends State<MetronomeSettings> {
  final _metronomePlugin = Metronome();
  bool isplaying = false;
  int bpm = 120;
  int vol = 50;
  String metronomeIcon = 'assets/metronome-left.png';
  String metronomeIconRight = 'assets/metronome-right.png';
  String metronomeIconLeft = 'assets/metronome-left.png';
  // final List wavs = [
  //   'base',
  //   'claves',
  //   'hihat',
  //   'snare',
  //   'sticks',
  //   'woodblock_high'
  // ];
  @override
  void initState() {
    super.initState();
    _metronomePlugin.init(
      'assets/audio/woodblock_high44_wav.wav',
      bpm: bpm,
      volume: vol,
      enableSession: true,
      enableTickCallback: true,
    );
    _metronomePlugin.onListenTick((_) {
      if (kDebugMode) {
        print('tick');
      }
      setState(() {
        if (metronomeIcon == metronomeIconRight) {
          metronomeIcon = metronomeIconLeft;
        } else {
          metronomeIcon = metronomeIconRight;
        }
      });
    });
  }

  @override
  void dispose() {
    _metronomePlugin.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metronome example'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: ListView(
            children: [
              Image.asset(
                metronomeIcon,
                height: 100,
                gaplessPlayback: true,
              ),
              Text(
                'BPM:$bpm',
                style: const TextStyle(fontSize: 20),
              ),
              Slider(
                value: bpm.toDouble(),
                min: 30,
                max: 300,
                divisions: 270,
                onChangeEnd: (val) {
                  _metronomePlugin.setBPM(bpm);
                },
                onChanged: (val) {
                  bpm = val.toInt();
                  setState(() {});
                },
              ),
              // Text(
              //   'Volume:$vol%',
              //   style: const TextStyle(fontSize: 20),
              // ),
              // Slider(
              //   value: vol.toDouble(),
              //   min: 0,
              //   max: 100,
              //   divisions: 100,
              //   onChangeEnd: (val) {
              //     _metronomePlugin.setVolume(vol);
              //   },
              //   onChanged: (val) {
              //     vol = val.toInt();
              //     setState(() {});
              //   },
              // ),
              // SizedBox(
              //   width: 200,
              //   height: 350,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: wavs
              //         .map(
              //           (wav) => ElevatedButton(
              //             child: Text(wav),
              //             onPressed: () {
              //               _metronomePlugin.setAudioAssets(
              //                   'assets/audio/${wav}44_wav.wav');
              //             },
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isplaying) {
            _metronomePlugin.pause();
            isplaying = false;
          } else {
            _metronomePlugin.setVolume(vol);
            _metronomePlugin.play(bpm);
            isplaying = true;
          }
          setState(() {});
        },
        child: Icon(isplaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
