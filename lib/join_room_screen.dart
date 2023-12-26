import 'package:flutter/material.dart';
import 'package:scribble_clone/paint_screen.dart';
import 'package:scribble_clone/widgets/custom_text_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  void joinRoom() {
    if (_nameController.text.trim().isNotEmpty && _roomNameController.text.trim().isNotEmpty) {
      //
      Map<String, dynamic> data = {
        "nickname": _nameController.text.trim(),
        "name": _roomNameController.text.trim(),
      };
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaintScreen(data: data, screenFrom: 'joinRoom')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Join Room",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _nameController,
              hintText: "Enter your name",
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: _roomNameController,
              hintText: "Enter Room Name",
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: joinRoom,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
              minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width / 2.5, 50)),
            ),
            child: const Text("Join", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
