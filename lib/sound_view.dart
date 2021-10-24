import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'article_model.dart';

class SoundView extends StatefulWidget {
  static const String id = 'SoundView';

  @override
  _SoundViewState createState() => _SoundViewState();
}

enum TtsState { playing, stopped, paused, continued }

class _SoundViewState extends State<SoundView> {
  FlutterTts flutterTts;
  String language;
  String engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }


  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String selectedEngine) {
    flutterTts.setEngine(selectedEngine);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(
          DropdownMenuItem(value: type as String, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  ArticleModel article = DataModel.articles[0];
  double sliderValue = 10.0;
  bool isPlay = false;
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Now Playing',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        centerTitle: true,
        leading: BuildDefaultIconButton(
          icon: Icons.menu,
          onClick: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: BuildDefaultIconButton(
              icon: Icons.search,
              onClick: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BuildDefaultIconButton(
                  icon: Icons.add_circle_outline,
                  onClick: () {},
                ),
                BuildDefaultIconButton(
                  icon: Icons.send,
                  onClick: () {},
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
          Container(
            width: 220.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundImage: NetworkImage(DataModel.articles[currentIndex].image),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DataModel.articles[currentIndex].name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            DataModel.articles[currentIndex].title,
                            style: Theme.of(context).textTheme.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 5.0,
                  ),
                  Text(
                    DataModel.articles[currentIndex].description,
                    textAlign: TextAlign.justify,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        height: 2),
                  ),
                ],
              ),
            ),
          ),
            Expanded(child: SizedBox()),
            const SizedBox(
              height: 30.0,
            ),
            Text(
              'You Are Free',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Bailey Wonger',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(fontSize: 14.0, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Text(
                  (sliderValue.floorToDouble()).toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontSize: 11.0, fontWeight: FontWeight.normal),
                ),
                Expanded(
                  child: SliderTheme(
                    data: Theme.of(context).sliderTheme,
                    child: Slider(
                      key: UniqueKey(),
                      min: 0,
                      max: 100,
                      value: sliderValue,
                      onChanged: (currentValue) {
                        setState(() {
                          sliderValue = currentValue;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  '100.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontSize: 11.0, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuildDefaultIconButton(
                  icon: Icons.arrow_back_ios_rounded,
                  iconSize: 25.0,
                  onClick: () {
                    if(currentIndex > 0){
                      setState(() {
                        currentIndex--;
                        isPlay = false;
                        _stop();
                      });
                    }
                  },
                ),
                const SizedBox(
                  width: 50.0,
                ),
                BuildDefaultIconButton(
                  icon: isPlay == false ? Icons.play_circle_outline : Icons.adjust,
                  iconSize: 30.0,
                  onClick: () {
                    setState(() {
                      isPlay = !isPlay;
                      _newVoiceText = DataModel.articles[currentIndex].description;
                    });
                    if (isPlay) {
                      _speak();
                    } else {
                      _stop();
                    }
                    // _speak();
                  },
                ),
                const SizedBox(
                  width: 50.0,
                ),
                BuildDefaultIconButton(
                  icon: Icons.arrow_forward_ios_outlined,
                  iconSize: 25.0,
                  onClick: () {
                    if(currentIndex <= 3){
                      setState(() {
                        currentIndex++;
                        isPlay = false;
                        _stop();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}

class BuildDefaultIconButton extends StatelessWidget {
  final IconData icon;
  final Function onClick;
  final double iconSize;

  const BuildDefaultIconButton({this.icon, this.onClick, this.iconSize = 20.0});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onClick,
      iconSize: iconSize,
      color: Colors.white,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
    );
  }
}
