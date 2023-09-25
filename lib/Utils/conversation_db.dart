import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:ucas_tools/Widgets/ChatMessageBox.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Conversation {
  String name;
  String uuid;
  Conversation({required this.name, required this.uuid});

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
    };
  }
}

class Message {
  int? id;
  String conversationId;
  Role role;
  String text;
  Message(
      {this.id,
      required this.conversationId,
      required this.role,
      required this.text});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': conversationId,
      'role': role.index,
      'text': text,
    };
  }

  Widget toChatMessage() {
    return ChatMessageBox(
      text: text,
      sender: role,
    );
  }

  @override
  String toString() {
    return "Message{id: $id, conversationId: $conversationId, role: $role, text: $text}";
  }
}

enum Role {
  system,
  user,
  assistant,
}

extension Convert on Role {
  OpenAIChatMessageRole get asOpenAIChatMessageRole {
    switch (this) {
      case Role.assistant:
        return OpenAIChatMessageRole.assistant;
      case Role.user:
        return OpenAIChatMessageRole.user;
      case Role.system:
        return OpenAIChatMessageRole.system;
    }
  }
}

class ConversationDB {
  static const String _tableConversationName = 'conversations';
  static const String _tableMessageName = 'messages';
  static const String _columnUuid = 'uuid';
  static const String _columnName = 'name';
  static const String _columnId = 'id';
  static const String _columnRole = 'role';
  static const String _columnText = 'text';
  static Database? _database;
  static ConversationDB? _instance;
  ConversationDB._internal();

  factory ConversationDB() {
    _instance ??= ConversationDB._internal();
    return _instance!;
  }

  Future<Database> _getDB() async {
    if (_database == null) {
      final String path = join(await getDatabasesPath(), 'chat.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE $_tableConversationName(
              $_columnUuid TEXT PRIMARY KEY,
              $_columnName TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE $_tableMessageName (
              $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
              $_columnUuid TEXT,
              $_columnRole INTEGER,
              $_columnText TEXT,
              FOREIGN KEY ($_columnUuid) REFERENCES conversations($_columnUuid)
            )
          ''');
        },
      );
    }
    return _database!;
  }

  Future<Conversation> getConversationByUuid(String uuid) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
        _tableConversationName,
        where: "$_columnUuid = ?",
        whereArgs: [uuid]);
    return Conversation(name: maps[0][_columnName], uuid: maps[0][_columnUuid]);
  }

  Future<List<Conversation>> getConversations() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps =
        await db.query(_tableConversationName);
    return List.generate(
      maps.length,
      (i) => Conversation(
        name: maps[i][_columnName],
        uuid: maps[i][_columnUuid],
      ),
    );
  }

  Future<void> addConversation(Conversation conversation) async {
    final db = await _getDB();
    await db.insert(
      _tableConversationName,
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateConversation(Conversation conversation) async {
    final db = await _getDB();
    await db.update(
      _tableConversationName,
      conversation.toMap(),
      where: '$_columnUuid = ?',
      whereArgs: [conversation.uuid],
    );
  }

  Future<void> deleteConversation(String uuid) async {
    final db = await _getDB();
    await db.transaction((txn) async {
      await txn.delete(
        _tableConversationName,
        where: "$_columnUuid = ?",
        whereArgs: [uuid],
      );
      await txn.delete(
        _tableMessageName,
        where: "$_columnUuid = ?",
        whereArgs: [uuid],
      );
    });
  }

  Future<List<Message>> getMessagesByConversationUUid(String uuid) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db
        .query(_tableMessageName, where: "$_columnUuid = ?", whereArgs: [uuid]);
    return List.generate(
      maps.length,
      (index) => Message(
        role: Role.values[maps[index][_columnRole]],
        text: maps[index][_columnText],
        conversationId: maps[index][_columnUuid],
      ),
    );
  }

  Future<void> addMessage(Message message) async {
    final db = await _getDB();
    await db.insert(
      _tableMessageName,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMessage(int id) async {
    final db = await _getDB();
    await db.delete(
      _tableMessageName,
      where: "$_columnId = ?",
      whereArgs: [id],
    );
  }
}
