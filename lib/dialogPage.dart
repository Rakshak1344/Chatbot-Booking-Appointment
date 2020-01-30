import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class HomePageDialogflow extends StatefulWidget {
  final String title;
  HomePageDialogflow({Key key, this.title}) : super(key: key);

  @override
  _HomePageDialogflowState createState() => _HomePageDialogflowState();
}

class _HomePageDialogflowState extends State<HomePageDialogflow> {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(hintText: 'Send a message'),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  void response(query)async{
    _textController.clear();
    AuthGoogle authGoogle = await AuthGoogle(
      fileJson: "assets/credentials.json"
    ).build();
    Dialogflow dialogflow = Dialogflow(authGoogle: authGoogle,language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    ChatMessage message = ChatMessage(
      text: response.getMessage()?? CardDialogflow(response.getListMessage()[0]).title,
      name: "Bot",
      type: false,
    );
    setState(() {
     _messages.insert(0,message); 
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
      text: text,
      name: "Rakshith",
      type: true,
    );
    setState(() {
     _messages.insert(0,message); 
    });
    response(text);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Book Appointment"),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_,int index)=>_messages[index],
              itemCount: _messages.length,
            ),
          ),
          Divider(),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          )
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});
  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      Container(
        margin: EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage("assets/chatbot.jpg"),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              this.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0),
              child: Text(text),
            )
          ],
        ),
      )
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              this.name,
              style: Theme.of(context).textTheme.subhead,
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0),
              child: Text(text),
            )
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage("assets/me.jpg")
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context): otherMessage(context)
      ),
    );
  }
}
