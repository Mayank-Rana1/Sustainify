import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'widgets.dart';
import 'scanning_page.dart';
import 'main_navigation.dart';
import 'api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: MainNavigation(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  const MyHomePage({Key? key, required this.camera}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _appBarVisible = true;
  VideoPlayerController? _controller;
  bool _videoInitialized = false;
  late Future<void> _loadingFuture;
  File? _recordedVideo;

  int _scannedEcoScore = 78;
  List<String> _scannedTypes = ['Eco Certified', 'Consumer Good'];
  String _scannedLocation = 'Verified by AWS';

  // Default response data with environment impact data
  Map<String, dynamic> response = {
  "message": "File uploaded successfully",
  "data": {
    "product details": {
      "brand name": "Celsius",
      "product name": "Live Fit Peach Vibe Sparkling White Peach Edition",
      "product description": "Celsius Live Fit Peach Vibe Sparkling White Peach Edition is an energy drink that is made with green tea extract, taurine, guarana, and ginseng. It has 10 calories and is free of sugar, fat, and aspartame. The drink is designed to help you accelerate your metabolism, burn fat, and live fit.",
      "Packaging description": "The product is in a silver aluminum can with a green and pink label. The can is labeled Celsius Live Fit Peach Vibe Sparkling White Peach Edition.",
      "calorie count": [
        ["serving size in grams", "Not specified"],
        ["energy in kCal", 10]
      ],
      "ingredients": [
        "Carbonated water",
        "Green tea extract",
        "Citric acid",
        "Natural flavors",
        "Taurine",
        "Sucralose",
        "Panax ginseng",
        "Guarana extract",
        "Caffeine",
        "L-tyrosine",
        "Inositol",
        "Niacinamide",
        "Vitamin B12",
        "Calcium pantothenate",
        "Vitamin B6",
        "Sodium chloride",
        "Sodium citrate",
        "Potassium chloride",
        "Calcium chloride",
        "Magnesium citrate",
        "Sodium bicarbonate",
        "Natural colors"
      ],
      "nutritional content": [
        ["Total Fat", "0"],
        ["Sodium", "140"],
        ["Total Carbohydrate", "2"],
        ["Sugars", "2"],
        ["Protein", "0"],
        ["Vitamin B12", "25"],
        ["Niacin", "8"],
        ["Vitamin B6", "1"],
        ["Calcium Pantothenate", "2"],
        ["Taurine", "1000"],
        ["Ginseng", "100"],
        ["Guarana", "150"]
      ],
      "Allergen Information": [
        "Contains 5% juice",
        "Natural flavors",
        "Color added",
        "Green tea extract"
      ],
      "Cautions and Warnings": [
        "Do not consume if you are sensitive to caffeine or stimulants"
      ],
      "Manufacturing Location": "Made in USA",
      "FSSAI license": "Not applicable (US product)"
    },
    "good-bad-ingridients": {
      "good": [
        "Green tea extract",
        "Taurine",
        "Panax ginseng",
        "Guarana extract",
        "Vitamins (B12, B6, Niacinamide, Calcium pantothenate)"
      ],
      "bad": [
        "Sucralose",
        "Caffeine (in high amounts)",
        "Artificial flavors"
      ]
    },
    "tips": {
      "health": [
        "The drink contains caffeine and stimulants, which may not be suitable for everyone.",
        "While sugar-free, it contains artificial sweeteners which some people prefer to avoid.",
        "The high caffeine content (200mg per serving) can lead to health issues if consumed excessively."
      ],
      "environment": [
        "The aluminum can used for packaging requires energy-intensive mining and manufacturing processes.",
        "The transportation of the product from the manufacturing facility to retailers contributes to carbon emissions.",
        "The extensive use of plastic in the product's packaging, including the shrink wrap, can contribute to plastic pollution."
      ],
      "eco-tips": [
        "Consider homemade infused water with fruit and herbs for a natural and refreshing alternative.",
        "Opt for naturally caffeinated beverages like green tea or black coffee.",
        "Explore energy drinks with fewer artificial ingredients and lower caffeine content.",
        "Consider protein shakes or smoothies for a more nutritious energy boost.",
        "Prioritize a balanced diet and regular physical activity for sustained energy levels."
      ]
    },
    "environment_impact": {
      "carbon_footprint": "Not specified",
      "water_usage": "Not specified",
      "packaging_material": "Aluminum can with plastic shrink wrap",
      "recyclability": "Aluminum can is recyclable"
    }
  }
};

  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();

    _loadingFuture = Future.delayed(Duration(seconds: 0));

    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        setState(() {
          _videoInitialized = true;
        });
        _controller?.play();
        _controller?.setLooping(true);
      });

    _tabController = TabController(length: 3, vsync: this); 
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 56 && _appBarVisible) {
        setState(() {
          _appBarVisible = false;
        });
      } else if (_scrollController.position.pixels <= 56 && !_appBarVisible) {
        setState(() {
          _appBarVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  File? _recordedImage;

  Future<void> _navigateToScanningPage([String mode = 'shop']) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanningPage(
          camera: widget.camera,
          mode: mode,
        ),
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        _recordedImage = result['file'];
        _recordedVideo = null;
        _controller?.pause();
        
        final aiData = result['result'];
        if (aiData != null) {
          final detectedLabels = (aiData['detected_labels'] as List?)
              ?.map((l) => l['name']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ?? [];

          final itemName = aiData['name'] ?? (detectedLabels.isNotEmpty ? detectedLabels.first : "Scanned Item");
          
          if (aiData['score'] != null) {
            _scannedEcoScore = (aiData['score'] is num) ? (aiData['score'] as num).toInt() : 75;
          }
          
          if (aiData['types'] is List && (aiData['types'] as List).isNotEmpty) {
            _scannedTypes = (aiData['types'] as List).map((e) => e.toString()).toList();
          } else if (detectedLabels.isNotEmpty) {
            _scannedTypes = detectedLabels.take(3).toList();
          }

          _scannedLocation = "AWS Rekognition Analysis";

          response['data']['product details']['brand name'] = "Detected:";
          response['data']['product details']['product name'] = itemName;
          
          if (aiData['action'] != null) {
            response['data']['product details']['product description'] = "Disposal Action: ${aiData['action']}\nPrimary Material: ${aiData['material'] ?? 'Mixed'}\n\nRecommended Action Steps:\n${(aiData['steps'] as List?)?.map((s) => '• $s').join('\n') ?? 'Follow local recycling guidelines'}";
          } else {
            response['data']['product details']['product description'] = "Eco Score: $_scannedEcoScore/100 (${aiData['rating'] ?? 'Average'})\n\n${aiData['better'] ?? 'Consider eco-friendly alternatives with minimal packaging.'}";
          }
          
          response['data']['product details']['Packaging description'] = aiData['packaging'] ?? (detectedLabels.isNotEmpty ? "Identified features: ${detectedLabels.join(', ')}" : "No packaging details detected");

          response['data']['product details']['calorie count'] = [
            ["Confidence", "${((aiData['confidence'] ?? 0.85)*100).toInt()}%"],
            ["Eco Rating", "${aiData['rating'] ?? 'Good'}"]
          ];

          if (detectedLabels.isNotEmpty) {
            response['data']['product details']['ingredients'] = detectedLabels;
          }

          if (aiData['positives'] != null && (aiData['positives'] as List).isNotEmpty) {
            response['data']['good-bad-ingridients']['good'] = List<String>.from(aiData['positives']);
          } else if (detectedLabels.isNotEmpty) {
            response['data']['good-bad-ingridients']['good'] = detectedLabels.take(3).map((l) => "$l detected").toList();
          }

          if (aiData['concerns'] != null && (aiData['concerns'] as List).isNotEmpty) {
            response['data']['good-bad-ingridients']['bad'] = List<String>.from(aiData['concerns']);
          } else {
            response['data']['good-bad-ingridients']['bad'] = ["Standard environmental footprint"];
          }
          
          if (aiData['breakdown'] != null) {
            response['data']['environment_impact']['carbon_footprint'] = "Packaging: ${aiData['breakdown']['Packaging']}/25";
            response['data']['environment_impact']['water_usage'] = "Material: ${aiData['breakdown']['Material']}/25";
            response['data']['environment_impact']['packaging_material'] = aiData['recyclability'] ?? "Recyclable materials detected";
            response['data']['environment_impact']['recyclability'] = "Score: ${aiData['breakdown']['Recyclability']}/20";
          } else if (aiData['action'] != null) {
            response['data']['environment_impact']['carbon_footprint'] = "Action: ${aiData['action']}";
            response['data']['environment_impact']['packaging_material'] = aiData['material'] ?? 'Household material';
            response['data']['environment_impact']['recyclability'] = aiData['diy'] ?? 'Follow local guidelines';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToScanningPage,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 6,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
        label: const Text(
          'Scan Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(
              loadingText: 'Analyzing with AWS AI...',
              indicatorColor: Color(0xFF2E7D32),
            )
          : Stack(
              children: [
                // Background visual: captured photo or looping nature video
                Positioned.fill(
                  child: _recordedImage != null
                      ? Image.file(_recordedImage!, fit: BoxFit.cover)
                      : _videoInitialized
                          ? AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            )
                          : Container(
                              color: const Color(0xFF1B5E20),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                ),

                // Subtle gradient overlay for readability and smooth sheet blend
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 280,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Header Overlay
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco,
                                  color: Color(0xFF81C784), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Sustainify AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_done_outlined,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'AWS Cloud',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sliding content bottom sheet
                SafeArea(
                  child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          expandedHeight:
                              MediaQuery.of(context).size.height * 0.26,
                          pinned: false,
                          automaticallyImplyLeading: false,
                          flexibleSpace: const FlexibleSpaceBar(
                            centerTitle: true,
                          ),
                        ),
                      ];
                    },
                    body: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FBF9),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Drag handle indicator
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[350],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(child: _buildTabBarView()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabBarView() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: const TabBar(
              isScrollable: true,
              indicatorColor: Color(0xFF2E7D32),
              indicatorWeight: 3.0,
              labelColor: Color(0xFF1B5E20),
              unselectedLabelColor: Colors.grey,
              labelStyle:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle:
                  TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: [
                Tab(
                  icon: Icon(Icons.info_outline, size: 18),
                  text: 'Product Details',
                ),
                Tab(
                  icon: Icon(Icons.eco_outlined, size: 18),
                  text: 'Environment',
                ),
                Tab(
                  icon: Icon(Icons.health_and_safety_outlined, size: 18),
                  text: 'Health Impact',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Product Details Tab
                _buildProductDetailsTab(),
                // Environment Impact Tab
                _buildEnvironmentImpactTab(),
                // Health Impact Tab
                _buildHealthImpactTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsTab() {
    final productDetails = response['data']?['product details'];
    return AboutTab(
      title: productDetails != null
          ? '${productDetails['brand name'] ?? ''} ${productDetails['product name'] ?? ''}'
              .trim()
          : 'Unknown Product',
      types: _scannedTypes,
      description: productDetails != null
          ? '${productDetails['product description'] ?? 'No Description Available'}\n\n${productDetails['Packaging description'] ?? ''}'
              .trim()
          : 'No Description Available',
      quantity: productDetails != null &&
              productDetails['calorie count'] != null &&
              productDetails['calorie count'].isNotEmpty
          ? '${productDetails['calorie count'][0][1]}'
          : 'Standard',
      price: productDetails != null &&
              productDetails['calorie count'] != null &&
              productDetails['calorie count'].length > 1
          ? '${productDetails['calorie count'][1][1]}'
          : 'Verified',
      facts: 'Evaluated using Amazon Rekognition object and label analytics.',
      locationText: _scannedLocation,
      ecoscoreStatName: 'Ecoscore',
      ecoscoreStatValue: _scannedEcoScore,
    );
  }

  // Widget for Environment Impact Tab
  Widget _buildEnvironmentImpactTab() {
    final env = response['data']?['environment_impact'] ?? {};
    final tips = response['data']?['tips'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Environmental Footprint',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 12),

          // Carbon Footprint Card
          _buildEnvironmentImpactRow(
            icon: Icons.cloud_outlined,
            title: "Carbon Footprint",
            value: env['carbon_footprint']?.toString() ?? 'Low Emission',
            color: const Color(0xFF1976D2),
            bgColor: const Color(0xFFE3F2FD),
          ),

          // Water Usage Card
          _buildEnvironmentImpactRow(
            icon: Icons.water_drop_outlined,
            title: "Water Footprint",
            value: env['water_usage']?.toString() ?? 'Standard Usage',
            color: const Color(0xFF0097A7),
            bgColor: const Color(0xFFE0F7FA),
          ),

          // Packaging Material Card
          _buildEnvironmentImpactRow(
            icon: Icons.inventory_2_outlined,
            title: "Packaging Material",
            value: env['packaging_material']?.toString() ??
                'Recyclable Aluminum & Paper',
            color: Colors.amber[800]!,
            bgColor: const Color(0xFFFFF8E1),
          ),

          // Recyclability Card
          _buildEnvironmentImpactRow(
            icon: Icons.recycling_outlined,
            title: "Recyclability",
            value: env['recyclability']?.toString() ?? '100% Recyclable Material',
            color: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
          ),

          const SizedBox(height: 20),

          // Environmental Tips
          const Text(
            "Environmental Suggestions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 10),
          _buildTipsList(
            (tips['environment'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            color: const Color(0xFF2E7D32),
            icon: Icons.eco_outlined,
          ),

          const SizedBox(height: 16),

          // Eco Tips
          const Text(
            "Eco-Smart Actions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 10),
          _buildTipsList(
            (tips['eco-tips'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            color: Colors.amber[900]!,
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget for Health Impact Tab
  Widget _buildHealthImpactTab() {
    final productDetails = response['data']?['product details'] ?? {};
    final goodBad = response['data']?['good-bad-ingridients'] ?? {};
    final tips = response['data']?['tips'] ?? {};

    List<StatRowData> stats = [];
    List<ChartData> chart = [];

    if (productDetails['nutritional content'] != null) {
      for (var nutrient in productDetails['nutritional content']) {
        try {
          String cleanVal = nutrient[1].toString().replaceAll('%', '').trim();
          double val = double.tryParse(cleanVal) ?? 0.0;
          stats.add(StatRowData(nutrient[0].toString(), val.toInt()));
          chart.add(ChartData(nutrient[0].toString(), val));
        } catch (_) {}
      }
    }

    String ingredientsText = productDetails['ingredients'] != null
        ? (productDetails['ingredients'] as List).join(', ')
        : 'Ingredients verified by product label';

    List<String> goodList = [];
    if (goodBad['good'] != null) {
      goodList = (goodBad['good'] as List).map((e) => e.toString()).toList();
    }

    List<String> badList = [];
    if (goodBad['bad'] != null) {
      badList = (goodBad['bad'] as List).map((e) => e.toString()).toList();
    }

    List<String> healthTipsList = [];
    if (tips['health'] != null) {
      healthTipsList = (tips['health'] as List).map((e) => e.toString()).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutrition & Ingredients stats
          BaseStatsTab(
            nutritionStats: stats,
            ingredientsDescription: ingredientsText,
            typeDefenseChips: const [],
            chartData: chart,
          ),
          const SizedBox(height: 8),

          // Beneficial & Notable Ingredients
          GoodBadIngredientsTab(
            goodIngredients: goodList,
            badIngredients: badList,
          ),
          const SizedBox(height: 12),

          // Health tips
          const Text(
            "Health Guidelines",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 10),
          _buildTipsList(
            healthTipsList,
            color: Colors.red[700]!,
            icon: Icons.health_and_safety_outlined,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper widget to build environment metric cards
  Widget _buildEnvironmentImpactRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build styled tips
  Widget _buildTipsList(
    List<String> tips, {
    Color color = const Color(0xFF2E7D32),
    IconData icon = Icons.eco_outlined,
  }) {
    if (tips.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'No specific recommendations listed for this item.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: tips.map((tip) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[850],
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}