import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:peano_piano/global/coloors.dart';
import 'package:peano_piano/global/constants.dart';
import 'package:peano_piano/services/autio_player.dart';
import 'package:peano_piano/widgets/piano.dart';

typedef _Fn = void Function();
const theSource = AudioSource.microphone;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> pressedKeys = [];

  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

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
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
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
              top: 14,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Icon(
                      size: 30,
                        Icons.mic, color: Colors.white), // icon of the button
                    style: ElevatedButton.styleFrom( // styling the button
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(6),
                      backgroundColor: Colors.red, // Button color
                      foregroundColor: Colors.cyan, // Splash color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: getRecorderFn(),
                    //color: Colors.white,
                    //disabledColor: Colors.grey,
                    child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(_mRecorder!.isRecording
                      ? 'YOYO Recording in progress'
                      : 'Recorder is stopped'),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: getPlaybackFn(),
                    //color: Colors.white,
                    //disabledColor: Colors.grey,
                    child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(_mPlayer!.isPlaying
                      ? 'Playback in progress'
                      : 'Player is stopped'),
                ],
              ),
            ),
            Center(child: Piano(pressedKeys: pressedKeys)),
          ],
        ),
      ),
    );
  }

  Future<void> openTheRecorder() async {
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

  void record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
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
        fromURI: _mPath,
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
