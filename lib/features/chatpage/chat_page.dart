import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt/core/constants/const.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAi = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(receiveTimeout: Duration(seconds: 5)),
    enableLog: true,
  );
  final ChatUser _currentUser = ChatUser(
    id: "1",
    firstName: "Karthik",
    lastName: "S K",
  );
  final ChatUser _chatUser = ChatUser(
    id: "2",
    firstName: "Chat",
    lastName: "Gpt",
  );
  List<ChatMessage> _messages = <ChatMessage>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 166, 126, 1),
        title: Text('Chat GPT', style: TextStyle(color: Colors.white)),
      ),
      body: DashChat(
        currentUser: _currentUser,
        messageOptions: MessageOptions(
          currentUserContainerColor: Color.fromRGBO(0, 166, 126, 1),
          textColor: Colors.white,
        ),
        onSend: (ChatMessage m) {
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });
    List<Map<String, dynamic>> _messagesHistory =
        _messages.reversed.map((m) {
          return {
            "role": m.user.id == _currentUser.id ? "user" : "assistant",
            "content": m.text,
          };
        }).toList();

    final request = ChatCompleteText(
      model: gpt, // ✅ Updated model
      messages: _messagesHistory,
      maxToken: 100,
    );

    final response = await _openAi.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _chatUser,
              createdAt: DateTime.now(),
              text: element.message!.content,
            ),
          );
        });
      }
    }
  }
}
