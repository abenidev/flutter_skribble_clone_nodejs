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
  List<TouchPoint> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1.0;
  double strokeWidth = 2.0;

  @override
  void initState() {
    super.initState();
    socketIoConnect();
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
      _socket.on('update:room', (roomData) {
        debugPrint('update:room | roomData: ${roomData}');
        setState(() => dataOfRoom = Room.fromMap(roomData));
        if (!dataOfRoom.isJoin) {
          //* start the timer
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
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
