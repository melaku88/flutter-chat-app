import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwmm/pages/chat_page.dart';
import 'package:cwmm/services/database.dart';
import 'package:cwmm/services/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // =========================================================================================================
  bool search = false;
  String? myName, myUsername , myEmail;

  getMyDetails()async{
    myName = await SharedPreferenceHelper().getUserName();
    myUsername = await SharedPreferenceHelper().getUserUsername();
    myEmail = await SharedPreferenceHelper().getUserEmail();
  }
  onLoading()async{
    await getMyDetails();
  }
  @override
  void initState() {
    onLoading();
    super.initState();
  }
  
  var queryResultSet = [];
  var tempSearchStorage = [];

  initiateSearch(value){
    if(value.length == 0){
      setState(() {
        queryResultSet = [];
        tempSearchStorage = [];
      });
    }
    setState(() {
      search = true;
    });

    if(queryResultSet.isEmpty && value.length == 1){
      DatabaseMethods().searchUser(value).then((QuerySnapshot snapshot){
        for(int i = 0; i < snapshot.docs.length; i++ ){
          queryResultSet.add(snapshot.docs[i].data());
        }
        queryResultSet.forEach((element) {
          if(element['username'].startsWith(value)){
            setState(() {
              tempSearchStorage.add(element);
            });
          }
      });
      });
    }else{
      tempSearchStorage = [];
      queryResultSet.forEach((element) {
        if(element['username'].startsWith(value)){
          setState(() {
            tempSearchStorage.add(element);
          });
        }
      });
    }
  }

  chatRoomIdByUsername(String user1, String user2){
    List<String> roomId = [user1, user2];
    roomId.sort();
    return roomId.join('_');
  }

  // =========================================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 3, 118, 175),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 118, 175),
        toolbarHeight: 0.0,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
               padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  search ? Expanded(
                    child: CupertinoTextField(
                      autofocus: true,
                      onChanged: (value) {
                        initiateSearch(value.toLowerCase());
                      },
                      placeholder: 'Search users',
                      placeholderStyle: TextStyle(fontSize: 13.0, color: Colors.grey.shade500, letterSpacing: .8),
                      style: TextStyle(fontSize: 14.0),
                      cursorWidth: 1.2,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefix: Container(
                        margin: EdgeInsets.only(left: 5.0), child: Icon(Icons.search, size: 20.0, color: Colors.grey.shade500,)
                      ),
                    ),
                  )
                  :
                  Text(
                    'ChatUp',
                    style: TextStyle(color: Colors.white70, fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10.0,),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        search = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: search ? GestureDetector(
                        onTap: () {
                          setState(() {
                            search = false;
                            queryResultSet = [];
                            tempSearchStorage = [];
                          });
                        },
                        child: Icon(Icons.close, size: 20.0, color: Colors.grey.shade800),
                      ) 
                      : Icon(Icons.search, size: 20.0, color: Colors.grey.shade800),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height/2,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  )
                ),
                child: search ? ListView(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0),
                  primary: false,
                  shrinkWrap: true,
                  children: tempSearchStorage.map((element){
                    return _buildResultCard(element);
                  }).toList(),
                )

                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.asset('images/chatlogo.png', width: 90, height: 90.0,)
                    ),
                    Text('Search a User\n        &\n Chat More!', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600, color: Colors.black12),)

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildResultCard(data) {
  return GestureDetector(
    onTap: () async{
      showDialog(context: context, builder: (context) => Center(
        child: CircularProgressIndicator(color: Colors.lightBlue,),
      ));
      var chatRoomId = chatRoomIdByUsername(myUsername!, data['username']);
      Map<String, dynamic> chatRoomInfoMap = {
        'users': [myUsername, data['username']]
      };
      await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatPage(
        name: data['name'], username: data['username'], email: data['email']))
      );
      setState(() {
        search = false;
      });
    },
    child: data['username'] == myUsername ? Container() : Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Icon(Icons.person, size: 35.0, color: Colors.grey.shade600,)
                ),
              SizedBox(width: 20.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name']),
                  SizedBox(height: 3.0,),
                  Text('@'+data['username'],
                    style: TextStyle(color: Colors.lightBlue.shade700, fontSize: 12.0),
                )
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}
}
