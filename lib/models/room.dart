// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Room {
  int id;
  String word;
  String name;
  int occupancy;
  int maxRounds;
  int currentRound;
  bool isJoin;
  int? turn;
  int turnIndex;

  Room({
    required this.id,
    required this.word,
    required this.name,
    required this.occupancy,
    required this.maxRounds,
    required this.currentRound,
    required this.isJoin,
    this.turn,
    required this.turnIndex,
  });

  Room copyWith({
    int? id,
    String? word,
    String? name,
    int? occupancy,
    int? maxRounds,
    int? currentRound,
    bool? isJoin,
    int? turn,
    int? turnIndex,
  }) {
    return Room(
      id: id ?? this.id,
      word: word ?? this.word,
      name: name ?? this.name,
      occupancy: occupancy ?? this.occupancy,
      maxRounds: maxRounds ?? this.maxRounds,
      currentRound: currentRound ?? this.currentRound,
      isJoin: isJoin ?? this.isJoin,
      turn: turn ?? this.turn,
      turnIndex: turnIndex ?? this.turnIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'word': word,
      'name': name,
      'occupancy': occupancy,
      'maxRounds': maxRounds,
      'currentRound': currentRound,
      'isJoin': isJoin,
      'turn': turn,
      'turnIndex': turnIndex,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as int,
      word: map['word'] as String,
      name: map['name'] as String,
      occupancy: map['occupancy'] as int,
      maxRounds: map['maxRounds'] as int,
      currentRound: map['currentRound'] as int,
      isJoin: map['isJoin'] as bool,
      turn: map['turn'] != null ? map['turn'] as int : null,
      turnIndex: map['turnIndex'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) => Room.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Room(id: $id, word: $word, name: $name, occupancy: $occupancy, maxRounds: $maxRounds, currentRound: $currentRound, isJoin: $isJoin, turn: $turn, turnIndex: $turnIndex)';
  }

  @override
  bool operator ==(covariant Room other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.word == word &&
        other.name == name &&
        other.occupancy == occupancy &&
        other.maxRounds == maxRounds &&
        other.currentRound == currentRound &&
        other.isJoin == isJoin &&
        other.turn == turn &&
        other.turnIndex == turnIndex;
  }

  @override
  int get hashCode {
    return id.hashCode ^ word.hashCode ^ name.hashCode ^ occupancy.hashCode ^ maxRounds.hashCode ^ currentRound.hashCode ^ isJoin.hashCode ^ turn.hashCode ^ turnIndex.hashCode;
  }
}
