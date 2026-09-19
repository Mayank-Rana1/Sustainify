import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'api_service.dart';

class SignupPage extends StatefulWidget {
  final CameraDescription camera;

  const SignupPage({Key? key, required this.camera}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _needsVerification = false;
  String? _error;
  String? _success;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final result = await AuthService.signUp(email, password);
      if (result['success'] == true) {
        setState(() {
          _needsVerification = true;
          _success = 'Check your email for the verification code!';
        });
      } else {
        setState(() => _error = result['message']);
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verify() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _error = 'Please enter the verification code');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final result = await AuthService.confirmSignUp(email, code);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email verified! You can now log in.'), backgroundColor: Color(0xFF4A9A4A)),
        );
        Navigator.pop(context);
      } else {
        setState(() => _error = result['message']);
      }
    } catch (e) {
      setState(() => _error = 'Verification failed. Please try again.');
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
            image: AssetImage('assets/images/signup.png'),
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
                  SizedBox(height: 60),
                  Text(
                    _needsVerification
                        ? 'Verify your\nemail!'
                        : 'Sign up to get a\nstep closer to\nmaking your-self\nSustainable!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF3B8132),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 40),
                  if (!_needsVerification) ...[
                    _buildTextField(Icons.mail_outline, 'email address', _emailController),
                    SizedBox(height: 20),
                    _buildTextField(Icons.lock_outline, 'create password', _passwordController, obscureText: true),
                    SizedBox(height: 20),
                    _buildTextField(Icons.lock_outline, 'confirm password', _confirmController, obscureText: true),
                  ] else ...[
                    if (_success != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(_success!, style: TextStyle(color: Color(0xFF3B8132), fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    _buildTextField(Icons.confirmation_number_outlined, 'verification code', _codeController),
                  ],
                  SizedBox(height: 10),
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(_error!, style: TextStyle(color: Colors.red[800], fontSize: 13)),
                    ),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: Color(0xFF4A9A4A)))
                      : ElevatedButton(
                          onPressed: _needsVerification ? _verify : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A9A4A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _needsVerification ? 'Verify ' : 'Sign Up ',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
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
