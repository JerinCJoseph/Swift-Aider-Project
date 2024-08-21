import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_aid_project/screens/firstaider_map_screen.dart';
import 'package:first_aid_project/screens/forgot_password_screen.dart';
import 'package:first_aid_project/screens/security_dashboard_screen.dart';
import 'package:first_aid_project/services/authenticator.dart';
import 'package:first_aid_project/widgets/dialog_customised.dart';
import 'package:first_aid_project/widgets/scaffold_customised.dart';
import 'package:flutter/material.dart';
import 'package:first_aid_project/theme/theme_style.dart';
import 'package:first_aid_project/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formLogInKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController(); 
  bool isInfoSaved = true;
  final AuthenticationServices _firebaseService = AuthenticationServices();
  final faRoute = MaterialPageRoute(builder: (context) => const FirstaiderMapScreen(),);
  final secRoute = MaterialPageRoute(builder: (context) => const SecurityDashboardScreen(),);


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //for validating email textfield
    String? validateEmailTextField(String? value) {
      const emailpattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
          r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
          r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
          r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
          r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
          r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
          r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
      final regex = RegExp(emailpattern);
      return value!.isEmpty || !regex.hasMatch(value)
          ? 'Please enter a valid email address.'
          : null;
    }
    //for validation of password field
    String? validatePasswordTextField(String? value) {
      const passwordpattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
      final regex = RegExp(passwordpattern);
      return value!.isEmpty || !regex.hasMatch(value) 
          ? 'Please enter a valid password.'
          : null;
    } 
    return ScaffoldCustomised(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 15,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formLogInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 35.0,
                      ),
                      //email field
                      TextFormField(
                        controller: _emailController, 
                        validator: validateEmailTextField,  
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email Id',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, 
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, 
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      //password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: validatePasswordTextField,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, 
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, 
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isInfoSaved,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isInfoSaved = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                'Forget password?',
                                style: TextStyle(                                
                                  fontWeight: FontWeight.bold,
                                  color: lightColorScheme.primary,
                                ),
                              ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _logIn();
                          },
                          child: const Text('Log In'),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      //navigating to register screen if user has no account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Register here', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

void _logIn() async {
  final String emailId = _emailController.text;
  final String password = _passwordController.text;

  if (_formLogInKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging In'),
      ),
    );
    try {
      User? user = await _firebaseService.logIn(emailId, password);
      if (user != null) {
        String? role = await _firebaseService.getUserRole(user);
        if (role != null) {
          if (role == 'First Aider') {
            //Navigate to first aider screen
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(context, faRoute, (route) => false);         
          } else if (role == 'Security Staff') {
            //Navigate to security screen
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(context, secRoute, (route) => false);           
          }
        }
      }
    } catch (e) {
      String errorMsg = e.toString();
      // ignore: use_build_context_synchronously
      DialogCustomised.showCustomErrorDialog(context, "Error", errorMsg);
    }
  }
}
}