import 'package:flutter/material.dart';
import 'package:scribble_clone/create_room_screen.dart';
import 'package:scribble_clone/join_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Create/Join a room to play',
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          SizedBox(height: size.height * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateRoomScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
                  minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width / 2.5, 50)),
                ),
                child: const Text("Create", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JoinRoomScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
                  minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width / 2.5, 50)),
                ),
                child: const Text("Join", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
