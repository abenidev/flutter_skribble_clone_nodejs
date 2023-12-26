import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scribble_clone/components/my_custom_painter.dart';
import 'package:scribble_clone/constants/constants.dart';
import 'package:scribble_clone/models/room.dart';
import 'package:scribble_clone/models/touch_point.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key, required this.data, required this.screenFrom});
  final Map data;
  final String screenFrom;

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late io.Socket _socket;
  late Room dataOfRoom;
  List<dynamic> playersData = [];
  List<TouchPoint> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1.0;
  double strokeWidth = 2.0;
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  late TextEditingController _guessController;
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
    socketIoConnect();
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        _socket.emit('change:turn', dataOfRoom.id);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  void socketIoConnect() {
    _socket = io.io('http://192.168.8.188:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create:game', widget.data);
    } else {
      //joinRoom
      _socket.emit('join:game', widget.data);
    }

    //
    _socket.onConnect((data) {
      debugPrint('connected');
      debugPrint('socket on connect data: ${data}');

      //
      _socket.on('update:room', (data) {
        debugPrint('update:room:: data: ${data}');
        var roomData = data['updatedRoom'];
        var players = data['players'];
        debugPrint('update:room | roomData: ${roomData}');
        setState(() {
          dataOfRoom = Room.fromMap(roomData);
          playersData.clear();
          playersData.addAll(players);
          renderTextBlank(dataOfRoom.word);
        });
        if (!dataOfRoom.isJoin) {
          //* start the timer
          startTimer();
        }
      });

      //
      _socket.on('points', (point) {
        if (point['details'] != null) {
          Paint paint = Paint();
          paint.strokeCap = strokeType;
          paint.isAntiAlias = true;
          paint.color = selectedColor.withOpacity(opacity);
          paint.strokeWidth = strokeWidth;

          setState(() {
            points.add(
              TouchPoint(
                points: Offset((point['details']['dx']).toDouble(), (point['details']['dy']).toDouble()),
                paint: paint,
              ),
            );
          });
          //
        }
      });

      //color:change:server
      _socket.on('color:change:server', (colorString) {
        int colVal = int.parse(colorString, radix: 16);
        Color newColor = Color(colVal);
        setState(() => selectedColor = newColor);
      });

      //stroke:width:server
      _socket.on('stroke:width:server', (width) {
        setState(() => strokeWidth = width);
      });

      //clean:screen:server
      _socket.on('clean:screen:server', (data) {
        setState(() => points.clear());
      });

      //guess:server
      _socket.on('guess:server', (guessData) {
        setState(() {
          messages.add(guessData);
          guessedUserCtr = guessData['guessedUserCtr'];
        });
        if (guessedUserCtr == playersData.length - 1) {
          _socket.emit('change:turn', dataOfRoom.id);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: const Duration(microseconds: 300),
          curve: Curves.easeInOut,
        );
      });

      //change:turn:server
      _socket.on('change:turn:server', (data) {
        String oldWord = dataOfRoom.word;
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                dataOfRoom = Room.fromMap(data);
                renderTextBlank(dataOfRoom.word);
                guessedUserCtr = 0;
                _start = 60;
                points.clear();
              });
              Navigator.pop(context);
              _timer.cancel();
              //start timer
              startTimer();
            });

            return AlertDialog(
              title: Center(child: Text('Word was ${oldWord}')),
            );
          },
        );
      });

      //
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //select color
    void selectColor() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                String colorString = color.toString();
                String valueString = colorString.split('(0x')[1].split(')')[0];
                debugPrint("colorString: $colorString");
                debugPrint("valueString: $valueString");

                Map<String, dynamic> colorData = {
                  'color': valueString,
                  'roomId': dataOfRoom.id,
                };

                _socket.emit('color:change', colorData);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '${_start}',
            style: const TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    //*Painter container
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      width: size.width > paintBoxWidth ? paintBoxWidth : size.width,
                      height: size.height * 0.55,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          //*local position is relative to its parent container
                          //*global position is relative to the device screen
                          debugPrint(details.localPosition.dx.toString());
                          _socket.emit('paint', {
                            'details': {
                              'dx': details.localPosition.dx,
                              'dy': details.localPosition.dy,
                            },
                            'roomId': dataOfRoom.id,
                          });
                        },
                        onPanStart: (details) {
                          debugPrint(details.localPosition.dx.toString());
                          _socket.emit('paint', {
                            'details': {
                              'dx': details.localPosition.dx,
                              'dy': details.localPosition.dy,
                            },
                            'roomId': dataOfRoom.id,
                          });
                        },
                        onPanEnd: (details) {
                          _socket.emit('paint', {
                            'details': null,
                            'roomId': dataOfRoom.id,
                          });
                        },
                        child: SizedBox.expand(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            child: RepaintBoundary(
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: MyCustomPainter(pointsList: points),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    //stroke width slider
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.color_lens, color: selectedColor),
                          onPressed: () {
                            selectColor();
                          },
                        ),
                        Expanded(
                          child: Slider(
                            min: 1.0,
                            max: 10,
                            label: "Strokewidth $strokeWidth",
                            activeColor: selectedColor,
                            value: strokeWidth,
                            onChanged: (double value) {
                              Map<String, dynamic> map = {
                                'width': value,
                                'roomId': dataOfRoom.id,
                              };
                              _socket.emit('stroke:width', map);
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.layers_clear, color: selectedColor),
                          onPressed: () {
                            _socket.emit('clean:screen', dataOfRoom.id);
                          },
                        ),
                      ],
                    ),

                    //
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: textBlankWidget,
                    ),

                    //guesses display
                    Container(
                      decoration: const BoxDecoration(),
                      height: size.height * 0.22,
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index].values;
                          // {
                          //   'name': '',
                          //   'msg': ''
                          // }
                          return ListTile(
                            title: Text(
                              msg.elementAt(0),
                              style: const TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              msg.elementAt(1),
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //guess input field
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  // readOnly: isTextInputReadOnly,
                  controller: _guessController,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Map<String, dynamic> guessData = {
                        'username': widget.data['nickname'],
                        'guess': value.trim(),
                        'word': dataOfRoom.word,
                        'roomId': dataOfRoom.id,
                        'guessedUserCtr': guessedUserCtr,
                        'socketId': _socket.id,
                        'totalTime': 60,
                        'timeTaken': 60 - _start,
                      };
                      _socket.emit('guess:client', guessData);
                      _guessController.clear();
                    }
                  },
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.transparent)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xffF5F5FA),
                    hintText: 'Enter Your Guess',
                    hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}
