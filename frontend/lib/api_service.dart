import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert'; 

class ApiService {
  static String _baseUrl = 'YOUR_AWS_API_URL_HERE'; // Replace with your API base URL from SAM deploy

  static Future<Map<String, dynamic>> uploadFile(
      String endpoint, File file, String userMedicalAilments) async {
    
    if (_baseUrl == 'YOUR_AWS_API_URL_HERE') {
       throw Exception('Please set your AWS API URL in api_service.dart');
    }

    String? mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    String ext = mimeType.split('/').last;

    try {
      // 1. Get Presigned URL
      var urlResponse = await http.post(
        Uri.parse('$_baseUrl/upload-url'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'extension': ext}),
      );
      
      if (urlResponse.statusCode != 200) throw Exception('Failed to get upload URL');
      var urlData = jsonDecode(urlResponse.body);
      String uploadUrl = urlData['uploadUrl'];
      String imageKey = urlData['imageKey'];

      // 2. Upload to S3
      var s3Response = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': mimeType},
        body: file.readAsBytesSync(),
      );
      
      if (s3Response.statusCode != 200 && s3Response.statusCode != 201) throw Exception('Failed to upload image to S3');

      // 3. Analyze Image
      var analyzeResponse = await http.post(
        Uri.parse('$_baseUrl/analyses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mode': endpoint.contains('eco') ? 'shop' : 'dispose',
          'imageKey': imageKey,
          'details': userMedicalAilments,
        }),
      );

      if (analyzeResponse.statusCode == 200 || analyzeResponse.statusCode == 201) {
         Map<String, dynamic> responseData = jsonDecode(analyzeResponse.body);
         return responseData['result'] ?? responseData;
      } else {
         throw Exception('Analysis failed');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error uploading file: $e');
    }
  }
}