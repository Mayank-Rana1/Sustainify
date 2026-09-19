import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'signup_page.dart';
import 'main_navigation.dart';
import 'api_service.dart';

class LoginPage extends StatefulWidget {
  final CameraDescription camera;

  const LoginPage({Key? key, required this.camera}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final result = await AuthService.signIn(email, password);
      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation(camera: widget.camera)),
        );
      } else {
        setState(() => _error = result['message']);
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF3B8132),
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildTextField(Icons.mail_outline, 'email address', _emailController),
                  SizedBox(height: 20),
                  _buildTextField(Icons.lock_outline, 'password', _passwordController, obscureText: true),
                  SizedBox(height: 10),
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: TextStyle(color: Colors.red[800], fontSize: 13)),
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: _isLoading
                        ? CircularProgressIndicator(color: Color(0xFF4A9A4A))
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A9A4A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Log in ', style: TextStyle(fontSize: 18, color: Colors.white)),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage(camera: widget.camera)),
                        );
                      },
                      child: Text(
                        '"Sustainability starts with you."\n(Tap here to Sign Up)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF904040),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, TextEditingController controller, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF8DC97E).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Color(0xFF265022)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Color(0xFF4A8043),
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: Icon(icon, color: Color(0xFF3B8132)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
