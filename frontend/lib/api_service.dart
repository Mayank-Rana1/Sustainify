import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

/// AWS Configuration — Fill these after running `sam deploy`
class AwsConfig {
  // API Gateway endpoint (from SAM output "ApiUrl")
  static const String apiUrl = 'YOUR_API_URL_HERE';

  // Cognito (from SAM outputs "UserPoolId" and "UserPoolClientId")
  static const String userPoolId = 'YOUR_USER_POOL_ID';
  static const String clientId = 'YOUR_CLIENT_ID';
  static const String region = 'ap-south-1'; // Change to your AWS region
}

/// ---------- Cognito Auth Service (AWS Cognito) ----------
class AuthService {
  static String? _idToken;
  static String? _accessToken;
  static String? _refreshToken;
  static String? _username;

  static bool get isLoggedIn => _idToken != null;
  static String? get username => _username;
  static String? get idToken => _idToken;

  /// Sign Up with email & password using AWS Cognito
  static Future<Map<String, dynamic>> signUp(String email, String password) async {
    final url = 'https://cognito-idp.${AwsConfig.region}.amazonaws.com/';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.SignUp',
      },
      body: jsonEncode({
        'ClientId': AwsConfig.clientId,
        'Username': email,
        'Password': password,
        'UserAttributes': [
          {'Name': 'email', 'Value': email},
        ],
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Sign up successful! Please check your email for verification.'};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Sign up failed'};
    }
  }

  /// Confirm Sign Up with verification code
  static Future<Map<String, dynamic>> confirmSignUp(String email, String code) async {
    final url = 'https://cognito-idp.${AwsConfig.region}.amazonaws.com/';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.ConfirmSignUp',
      },
      body: jsonEncode({
        'ClientId': AwsConfig.clientId,
        'Username': email,
        'ConfirmationCode': code,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Email verified successfully!'};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Verification failed'};
    }
  }

  /// Sign In with email & password
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    final url = 'https://cognito-idp.${AwsConfig.region}.amazonaws.com/';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
      },
      body: jsonEncode({
        'AuthFlow': 'USER_PASSWORD_AUTH',
        'ClientId': AwsConfig.clientId,
        'AuthParameters': {
          'USERNAME': email,
          'PASSWORD': password,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['AuthenticationResult'];
      _idToken = result['IdToken'];
      _accessToken = result['AccessToken'];
      _refreshToken = result['RefreshToken'];
      _username = email;
      return {'success': true, 'message': 'Login successful!'};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message'] ?? 'Login failed'};
    }
  }

  /// Sign Out
  static void signOut() {
    _idToken = null;
    _accessToken = null;
    _refreshToken = null;
    _username = null;
  }
}

/// ---------- API Service (S3 + Lambda + Rekognition + DynamoDB) ----------
class ApiService {
  static Future<Map<String, dynamic>> uploadFile(
      String endpoint, File file, String userDetails) async {

    if (AwsConfig.apiUrl == 'YOUR_API_URL_HERE') {
      throw Exception('Please set your AWS API URL in api_service.dart');
    }

    String? mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    String ext = mimeType.split('/').last;

    // Build auth headers if logged in
    Map<String, String> authHeaders = {'Content-Type': 'application/json'};
    if (AuthService.isLoggedIn) {
      authHeaders['Authorization'] = 'Bearer ${AuthService.idToken}';
    }

    try {
      // Step 1: Get Presigned URL from Lambda → S3
      var urlResponse = await http.post(
        Uri.parse('${AwsConfig.apiUrl}/upload-url'),
        headers: authHeaders,
        body: jsonEncode({'extension': ext}),
      );

      if (urlResponse.statusCode != 200) throw Exception('Failed to get upload URL');
      var urlData = jsonDecode(urlResponse.body);
      String uploadUrl = urlData['uploadUrl'];
      String imageKey = urlData['imageKey'];

      // Step 2: Upload image directly to S3
      var s3Response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': mimeType},
        body: file.readAsBytesSync(),
      );

      if (s3Response.statusCode != 200 && s3Response.statusCode != 201) {
        throw Exception('Failed to upload image to S3');
      }

      // Step 3: Trigger Lambda → Rekognition analysis → DynamoDB save
      var analyzeResponse = await http.post(
        Uri.parse('${AwsConfig.apiUrl}/analyses'),
        headers: authHeaders,
        body: jsonEncode({
          'mode': endpoint.contains('eco') ? 'shop' : 'dispose',
          'imageKey': imageKey,
          'name': '',
          'details': userDetails,
          'condition': '',
        }),
      );

      if (analyzeResponse.statusCode == 200 || analyzeResponse.statusCode == 201) {
        Map<String, dynamic> responseData = jsonDecode(analyzeResponse.body);
        return responseData['result'] ?? responseData;
      } else {
        throw Exception('Analysis failed: ${analyzeResponse.body}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  /// Get analysis history from DynamoDB
  static Future<List<dynamic>> getHistory() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (AuthService.isLoggedIn) {
      headers['Authorization'] = 'Bearer ${AuthService.idToken}';
    }

    var response = await http.get(
      Uri.parse('${AwsConfig.apiUrl}/analyses'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['items'] ?? [];
    }
    return [];
  }

  /// Health check
  static Future<bool> healthCheck() async {
    try {
      var response = await http.get(Uri.parse('${AwsConfig.apiUrl}/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}