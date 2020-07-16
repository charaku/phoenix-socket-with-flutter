import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
// import 'package:phoenix_wings/src/phoenix_push.dart';
// import 'package:phoenix_wings/src/phoenix_socket.dart';

void main() => runApp(MyApp());
bool connected = false;
String message = "";
String user = "";
String channelId = "";
String token = "";
final socket = new PhoenixSocket("ws://localhost:4000/socket/websocket");
var chatChannel;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Phoenix Socket"),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  // @override
  // _MyHomePageState createState() => _MyHomePageState();
  @override
  MyHomePageState createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  
  void doConnectionToPhoenix(user, channelId, token) async {
    await socket.connect();
    print("jadi ke ni? $user, $channelId, $token");

    chatChannel = socket.channel("room:$channelId", {"user": user, "token": token});

    chatChannel.on("room:$channelId:new_message", (Map payload, String _ref, String _joinRef) {
        print(payload);
    });

    chatChannel.join();
    connected = true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              hintText: "Username"
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              else {
                user = value;
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Channel ID"
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              else {
                channelId = value;
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Token"
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              else {
                token = value;
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false
                // otherwise.
                if (_formKey.currentState.validate()) {
                  // If the form is valid, display a Snackbar.
                  doConnectionToPhoenix(user, channelId, token);
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("username: $user\nchannel ID: $channelId\ntoken: $token")));
                }
              },
              child: Text('Connect'),
            ),
          ),
          MessageForm(),
        ],
      ),
    );
  }
}

class MessageForm extends StatelessWidget {
  final _messageFormKey = GlobalKey<FormState>();
  void sendMessage(message) {
    print("sending message ~> cid: $channelId, user: $user, token: $token");
    chatChannel.push(event: "message:add", payload: {"message": message});
  }

  @override
  Widget build(BuildContext context) {
    if (!connected) {
      return Form(
        key: _messageFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                hintText: "Message"
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                else {
                  message = value;
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  if (_messageFormKey.currentState.validate()) {
                    sendMessage(message);
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text("Message sent!")));
                  }
                },
                child: Text('Send Message'),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        child: Text("Please connect to the websocket first"),
      );
    }
  }
}