import 'package:bds/common/customcolors.dart';
import 'package:bds/common/strings.dart';
import 'package:bds/common/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final Firestore _firestore = Firestore.instance;

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  String currentUser;

  _MessagePageState() {
    getCurrentUser().then((user) {
      return currentUser = user;
    });
  }

  Future<String> getCurrentUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString("userID");
  }

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await _firestore.collection('messages').add({
        'text': messageController.text,
        'from': currentUser,
        'createdAt': FieldValue.serverTimestamp(),
      });
      messageController.clear();
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          curve: Curves.easeOut, duration: Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection(Strings.FIREBASE_MESSAGE)
                      .orderBy("createdAt",descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());

                    List<DocumentSnapshot> docs = snapshot.data.documents;

                    List<Widget> messages = docs
                        .map((doc) => Message(
                              from: doc.data['from'],
                              text: doc.data['text'],
                              me: currentUser == doc.data['from'],
                            ))
                        .toList();
                    return ListView(
                        controller: scrollController, children: messages);
                  },
                ),
              ),
            ),
            Container(
                child: Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 15),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        controller: messageController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: CustomColors.appBarColor, width: 3.0),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: CustomColors.appBarColor, width: 2.0),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          hintText: 'Enter your message',
                          alignLabelWithHint: true,
                          contentPadding:
                              EdgeInsets.fromLTRB(15, 15.0, 15.0, 15.0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: SendButton(text: "Send", callback: callback))
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10, bottom: 30, top: 10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: callback,
        padding: EdgeInsets.all(10),
        color: CustomColors.buttonColor,
        child: Row(
          children: <Widget>[
            Icon(Icons.send),
            Expanded(
              child: Text(text,
                  textAlign: TextAlign.center, style: Style.button(context)),
            )
          ],
        ),
      ),
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(from),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Material(
              color: me ? CustomColors.appBarColor : CustomColors.cardColor,
              borderRadius: BorderRadius.circular(10.0),
              elevation: 6.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: Text(text),
              ),
            ),
          )
        ],
      ),
    );
  }
}
