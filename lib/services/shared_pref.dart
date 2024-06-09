import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{
  static String userIdKey = 'USERIDKEY';
  static String userNameKey = 'USERNAMEKEY';
  static String userUsernameKey = 'USERUSERNAMEKEY';
  static String userEmailKey = 'USEREMAILKEY';

// Save user details
  Future<bool> saveUserId(String userId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, userId);
  }

  Future<bool> saveUserName(String userName)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, userName);
  }
  Future<bool> saveUserUsername(String userUsername)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userUsernameKey, userUsername);
  }
  
  Future<bool> saveUserEmail(String userEmail) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, userEmail);
  }

// Get user details
Future<String?> getUserId()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userIdKey);
}
Future<String?> getUserName()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userNameKey);
}
Future<String?> getUserUsername()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userUsernameKey);
}
Future<String?> getUserEmail()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(userEmailKey);
}
}