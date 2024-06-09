import 'package:cwmm/pages/home.dart';
import 'package:cwmm/pages/login.dart';
import 'package:cwmm/services/database.dart';
import 'package:cwmm/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:random_string/random_string.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ============================================================================================
  bool isPassVisible = false;
  bool isConfiVissible = false;
  String name = '', email = '', password = '', confirmPassword = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  registration() async{
    showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(color: Colors.lightBlue,)));

    if(password != '' && password == confirmPassword){
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

        String id = randomAlphaNumeric(10);

        Map<String, dynamic> userInfo = {
          'id': id,
          'name': _nameController.text,
          'username': _emailController.text.split('@')[0].toLowerCase(),
          'email': _emailController.text,
          'searchKey':  _emailController.text.split('@')[0].substring(0,1).toLowerCase(),
        };

        await DatabaseMethods().registerUser(userInfo, id);

        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserName(_nameController.text);
         await SharedPreferenceHelper().saveUserName( _emailController.text.split('@')[0].toLowerCase());
        await SharedPreferenceHelper().saveUserEmail(_emailController.text);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green.shade800,
          content: Center(child: Text('Registered Successfully!', style: TextStyle(color: Colors.white),))
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        
      }on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange.shade800,
          content: Center(child: Text(e.code, style: TextStyle(color: Colors.white),))
        ));
      }
    }else if(password.isNotEmpty && confirmPassword.isNotEmpty && password != confirmPassword){
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.deepOrange.shade800,
        content: Center(child: Text('Password is not mached!', style: TextStyle(color: Colors.white),))
      ));
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
                height: 130.0,
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
                margin: EdgeInsets.only(top: 20.0, left: 25.0, right: 25.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sign Up',
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
                      'Create a New Account!',
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if(value==null || value.isEmpty){
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.0, fontWeight: FontWeight.w300),
                                  contentPadding: EdgeInsets.all(0.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black45),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                                  ),
                                  prefixIcon: Icon(Icons.person, size: 22.0,)
                                ),
                              ),
                              
                              SizedBox(height: 20.0,),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if(value==null || value.isEmpty){
                                    return 'Please enter your valid email';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'A Valid Email',
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
                              TextFormField(
                                controller: _confirmPasswordController,
                                validator: (value) {
                                  if(value==null || value.isEmpty){
                                    return 'Please confirm your password';
                                  }
                                  return null;
                                },
                                obscureText: isConfiVissible ? false : true,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
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
                                    onTap: () {
                                      setState(() {
                                        isConfiVissible = !isConfiVissible;
                                      });
                                    },
                                    child: Icon(
                                      isConfiVissible ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                                      size: 18.0, color: Colors.grey.shade800,)
                                  )
                                ),
                              ),
                      
                              SizedBox(height: 20.0,),
                              GestureDetector(
                                onTap: () {
                                  if(_formKey.currentState!.validate()){
                                    setState(() {
                                      name = _nameController.text;
                                      email = _emailController.text;
                                      password = _passwordController.text;
                                      confirmPassword = _confirmPasswordController.text;
                                    });
                                  }
                                  registration();
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
                                      'REGISTER',
                                      style: TextStyle(
                                        color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade500, fontSize: 14.0,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                      ),
                                      child: Text(
                                        'LOGIN NOW',
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