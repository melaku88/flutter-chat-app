import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{

  Future registerUser(Map<String, dynamic> userInfo, String id)async{
    return await FirebaseFirestore.instance.collection('Users').doc(id).set(userInfo);
  }

  Future<QuerySnapshot> getUserByEmail(String email) async{
    return await FirebaseFirestore.instance.collection('Users').where('email', isEqualTo: email).get();
  }

  Future<QuerySnapshot> searchUser(String username)async{
    return await FirebaseFirestore.instance.collection('Users').where('searchKey', isEqualTo: username.substring(0,1).toLowerCase()).get();
  }

  Future createChatRoom(String chatRoomId, Map<String, dynamic> chatRoomInfoMap)async{
    final snapShot = await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).get();
    if(snapShot.exists){
      return true;
    }else{
      return await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).set(chatRoomInfoMap);
    }
  }

  Future addMessag(String chatRoomId, String messageId, Map<String, dynamic> messageInfoMap) async{
    return await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).collection('Messages').doc(messageId).set(messageInfoMap);
  }

  Future updateLastMessag(String chatRoomId, Map<String, dynamic> lastMessageInfoMap) async{
    return await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getMessages(String chatRoomId) async{
    return await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).collection('Messages').orderBy('serverTime').snapshots();
  }
  
}