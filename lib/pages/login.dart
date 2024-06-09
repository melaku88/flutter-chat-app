import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwmm/pages/forgot_pass.dart';
import 'package:cwmm/pages/home.dart';
import 'package:cwmm/pages/register.dart';
import 'package:cwmm/services/database.dart';
import 'package:cwmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================================================
  bool isPassVisible = false;
  String id = '', name = '', username = '', email = '', password = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  login()async{
    showDialog(context: context, builder: (context) => Center(
      child: CircularProgressIndicator(color: Colors.lightBlue,),
    ));

    if(email.isNotEmpty && password.isNotEmpty){
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

        QuerySnapshot querySnapshot = await DatabaseMethods().getUserByEmail(email);
        id = querySnapshot.docs[0].id;
        name = '${querySnapshot.docs[0]['name']}';
        username = '${querySnapshot.docs[0]['username']}';
        email = '${querySnapshot.docs[0]['email']}';

        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserName(name);
        await SharedPreferenceHelper().saveUserUsername(username);
        await SharedPreferenceHelper().saveUserEmail(email);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green.shade800,
          content: Center(child: Text('Login Successfully!', style: TextStyle(color: Colors.white),))
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));

      }on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange.shade800,
          content: Center(child: Text(e.code, style: TextStyle(color: Colors.white),))
        ));
      }
    }else{
      Navigator.pop(context);
    }
  }

  // ============================================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 8, 150, 221),
        toolbarHeight: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0, top: 30.0),
                width: MediaQuery.of(context).size.width,
                height: 150.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 8, 150, 221), Color.fromARGB(255, 5, 103, 152)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(MediaQuery.of(context).size.width, 100)),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 40.0, left: 25.0, right: 25.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w700
                      ),
                    ),
                    Container(
                      height: 2.0,
                      width: 40.0,
                      color: Colors.grey.shade400,
                      margin: EdgeInsets.only(top: 3.0, bottom: 15.0),
                    ),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white54, fontSize: 16.0, fontWeight: FontWeight.w400
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 32.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: 20.0,),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if(value==null || value.isEmpty){
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.0, fontWeight: FontWeight.w300),
                                  contentPadding: EdgeInsets.all(0.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black45),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                                  ),
                                  prefixIcon: Icon(Icons.email, size: 18.0,)
                                ),
                              ),
                                          
                              SizedBox(height: 20.0,),
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if(value==null || value.isEmpty){
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                obscureText: isPassVisible ? false : true,
                                decoration: InputDecoration(
                                  hintText: 'Enter Password',
                                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.0, fontWeight: FontWeight.w300),
                                  contentPadding: EdgeInsets.all(0.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black45),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                                  ),
                                  prefixIcon: Icon(Icons.password, size: 20.0,),
                                  suffixIcon: GestureDetector(
                                    onTap:() {
                                      setState(() {
                                        isPassVisible = !isPassVisible;
                                      });
                                    },
                                    child: Icon(
                                      isPassVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                                      size: 18.0, color: Colors.grey.shade800,)
                                  ),
                                ),
                              ),
                      
                              SizedBox(height: 20.0,),
                              GestureDetector(
                                onTap: () {
                                  if(_formKey.currentState!.validate()){
                                    setState(() {
                                      email = _emailController.text;
                                      password = _passwordController.text;
                                    });
                                  }
                                  login();
                                },
                                child: Material(
                                  elevation: 3.0,
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(7.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color.fromARGB(255, 8, 150, 221), Color.fromARGB(255, 5, 103, 152)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter
                                      ),
                                      borderRadius: BorderRadius.circular(5.0)
                                    ),
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ForgotPassPage()));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2.0)
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(color: const Color.fromARGB(255, 151, 39, 31)),
                                        )
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade500, fontSize: 14.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage())),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                      ),
                                      child: Text(
                                        'CREATE NEW ',
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 5, 103, 152), fontSize: 12.0, fontWeight: FontWeight.w700
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}