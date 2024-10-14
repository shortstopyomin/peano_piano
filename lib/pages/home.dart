import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:go_router/go_router.dart';
import 'package:metronome/metronome.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peano_piano/global/coloors.dart';
import 'package:peano_piano/global/constants.dart';
import 'package:peano_piano/router/route_constants.dart';
import 'package:peano_piano/services/autio_player.dart';
import 'package:peano_piano/widgets/piano.dart';
import 'package:permission_handler/permission_handler.dart';

enum MetronomeState {
  /// Metronome is stopped
  isStopped,

  /// Metronome is playing
  isPlaying,
}

typedef _Fn = void Function();
const theSource = AudioSource.microphone;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> pressedKeys = [];

  final Codec _codec = Codec.aacMP4;
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  File? _recordedFile;
  String? _filePath;
  MetronomeState _metronomeState = MetronomeState.isStopped;
  final _metronomePlugin = Metronome();
  bool isMetronomePlaying = false;
  int bpm = 120;
  int vol = 50;
  String metronomeIcon = 'assets/metronome-left.png';
  String metronomeIconRight = 'assets/metronome-right.png';
  String metronomeIconLeft = 'assets/metronome-left.png';

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
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
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    _metronomePlugin.destroy();
    super.dispose();
  }

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
            Positioned(
              left: 104,
              top: 10,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: getRecorderFn(), // icon of the button
                    style: ElevatedButton.styleFrom( // styling the button
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(2),
                      backgroundColor: _mRecorder!.isRecording ? Colors.red : Colors.grey, // Button color
                      foregroundColor: Colors.cyan, // Splash color
                    ),
                    child: Icon(
                      size: 30,
                      _mRecorder!.isRecording ? Icons.stop_rounded : Icons.mic,
                        color: Colors.white,
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: getPlaybackFn(),
                  //   //color: Colors.white,
                  //   //disabledColor: Colors.grey,
                  //   child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
                  // ),
                  // const SizedBox(
                  //   width: 20,
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      // final result = await context.pushNamed(RouteName.metronomeSettings);
                      if (isMetronomePlaying) {
                        _metronomePlugin.pause();
                        isMetronomePlaying = false;
                      } else {
                        _metronomePlugin.setVolume(vol);
                        _metronomePlugin.play(bpm);
                        isMetronomePlaying = true;
                      }
                      setState(() {});
                    }, // icon of the button
                    style: ElevatedButton.styleFrom( // styling the button
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(4),
                      backgroundColor: isMetronomePlaying ? Colors.red : Colors.transparent, // Button colorSplash color
                    ),
                    child: SizedBox(
                        width: 26,
                        height: 26,
                        child: Image.asset('assets/metronome.png'),
                    )
                  ),
                  if (isMetronomePlaying)...[
                    Text(
                      'BPM:$bpm',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18
                      ),
                    ),
                    Slider(
                      value: bpm.toDouble(),
                      min: 30,
                      max: 300,
                      divisions: 270,
                      activeColor: Colors.lightGreen,
                      onChangeEnd: (val) {
                        _metronomePlugin.setBPM(bpm);
                      },
                      onChanged: (val) {
                        bpm = val.toInt();
                        setState(() {});
                      },
                    ),
                  ]
                ],
              ),
            ),
            Positioned(
              right: 44,
              top: 18,
              child: isMetronomePlaying ? Image.asset(
                metronomeIcon,
                height: 48,
                gaplessPlayback: true,
                color: Colors.white70,
              ): const SizedBox.shrink(),
            ),
            Center(child: Piano(pressedKeys: pressedKeys)),
          ],
        ),
      ),
    );
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    var storageStatus = await Permission.storage.request();
    if (storageStatus != PermissionStatus.granted) {
      throw RecordingPermissionException('Storage permission not granted');
    }
    await _mRecorder!.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  Future<void> record() async {
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // final filePath =
    // '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}/recording.m4a';
    final directory = await getApplicationDocumentsDirectory();
    print('yoyo directory= $directory');
    print('yoyo directory= ${directory!.path}');
    print('yoyo directory= ${directory.absolute}');
    _recordedFile = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a');
    _mRecorder!
        .startRecorder(
      toFile: _recordedFile!.path,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
    print('_recordedFile = $_recordedFile');
    print('_recordedFile.path = ${_recordedFile!.path}');
    print('_recordedFile.absolute = ${_recordedFile!.absolute}');
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
        fromURI: _recordedFile!.path,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }
}
