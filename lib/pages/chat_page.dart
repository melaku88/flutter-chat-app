import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwmm/pages/home.dart';
import 'package:cwmm/pages/login.dart';
import 'package:cwmm/services/database.dart';
import 'package:cwmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final name;
  final username;
  final email;
  const ChatPage({
    super.key,
    required this.name,
    required this.username,
    required this.email
    });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ===================================================================================================
  final TextEditingController _messageController = TextEditingController();
    String? myName, myUsername , myEmail, messageId, chatRoomId;

    
  chatRoomIdByUsername(String user1, String user2){
    List<String> roomId = [user1, user2];
    roomId.sort();
    return roomId.join('_');
  }

  getMyDetails()async{
    myName = await SharedPreferenceHelper().getUserName();
    myUsername = await SharedPreferenceHelper().getUserUsername();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    chatRoomId = await chatRoomIdByUsername(widget.username, myUsername!);
  }
  onLoading()async{
    await getMyDetails();
    await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).collection('Messages').orderBy('serverTime', descending: true).snapshots();
    setState(() {
      
    });
  }
  @override
  void initState() {
    onLoading();
    super.initState();
  }

  sendMessage(bool sendClicked) async{
    if(_messageController.text != ''){
      String message = _messageController.text;
      _messageController.text = '';

      DateTime now = DateTime.now();
      String formatedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        'message': message,
        'sendBy': myUsername,
        'sendTo': widget.username,
        'timeStamp': formatedDate,
        'serverTime': FieldValue.serverTimestamp(),
      };
      messageId ??= randomAlphaNumeric(10);
      await DatabaseMethods().addMessag(chatRoomId!, messageId!, messageInfoMap).then((value) async{
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': message,
          'lastMessageSendBy': myUsername,
          'lastMessageSendTo': widget.username,
          'lastMessageTimeStamp': formatedDate,
          'lastMessageServerTime': FieldValue.serverTimestamp(),
        };
        await DatabaseMethods().updateLastMessag(chatRoomId!, lastMessageInfoMap);
        if(sendClicked){
          messageId = null;
        }
      });
    }
  }
  // ===================================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 3, 118, 175),
      //  color: Colors.lightBlue.shade600,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 118, 175),
        toolbarHeight: 0.0,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
               padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 25.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap:() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage())),
                        child: Icon(Icons.arrow_back_ios_new_outlined, size: 20.0, color: Colors.white70,),
                      ),
                      SizedBox(width: 30.0,),
                      Text(
                        widget.name,
                        style: TextStyle(color: Colors.white70, fontSize: 17.0, fontWeight: FontWeight.w600),
                        )
                    ],
                  ),
                  GestureDetector(
                    onTap: () async{
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: .8)
                      ),
                      child: Text('Logout', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w400),)
                    )
                  )
                ],
              ),
            ),
            SizedBox(height: 5.0,),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 0.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  )
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).collection('Messages').orderBy('serverTime', descending: true).snapshots(), 
                  builder: (context, snapshot){
                    if(snapshot.hasError) return Text('Something went wrong!', style: TextStyle(color: Colors.red));
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(color: Colors.lightBlue,),);
                    }
                    return ListView(
                      reverse: true,
                      children: snapshot.data!.docs.map((document){
                        final data = document.data() as Map<String, dynamic>;
                        return data['sendBy'] == myUsername ?  Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.topRight,
                              width: MediaQuery.of(context).size.width/1.4,
                              margin: EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                        bottomRight: Radius.circular(20.0)
                                      )
                                    ),
                                    child: Text(
                                      data['message'],
                                      style: TextStyle(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: Text(data['timeStamp'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0))
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ):  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            width: MediaQuery.of(context).size.width/1.4,
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade500,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                      bottomLeft: Radius.circular(20.0)
                                    )
                                  ),
                                  child: Text(
                                    data['message'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(data['timeStamp'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0))
                                ),
                              ],
                            ),
                          ),

                        ],
                      );
                      }).toList(),
                    );
                  }
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(bottom: 7.0, left: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Material(
                      elevation: 15.0,
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: CupertinoTextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 30,
                          keyboardType: TextInputType.multiline,
                          padding: EdgeInsets.all(0.0),
                          placeholder: 'Write a Message',
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage(true);
                      setState(() {
                        
                      });
                    },
                    child: Material(
                      elevation: 5.0,
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        color: Colors.white,
                        child: Icon(Icons.send, size: 25.0, color: Colors.green.shade700,),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}