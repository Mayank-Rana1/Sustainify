import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Loading Indicator Widget
class LoadingIndicator extends StatelessWidget {
  final String loadingText;
  final Color indicatorColor;

  const LoadingIndicator({
    Key? key,
    this.loadingText = 'Loading...',
    this.indicatorColor = const Color(0xFF2E7D32),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          Text(
            loadingText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}

// Type Chip Widget
class TypeChip extends StatelessWidget {
  final String type;
  final Color? backgroundColor;

  const TypeChip({Key? key, required this.type, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color chipBackgroundColor = backgroundColor ?? const Color(0xFFE8F5E9);
    Color chipTextColor = const Color(0xFF2E7D32);
    IconData icon = Icons.eco_outlined;

    switch (type.toLowerCase()) {
      case 'dairy':
        chipBackgroundColor = const Color(0xFFE3F2FD);
        chipTextColor = const Color(0xFF1976D2);
        icon = Icons.local_drink_outlined;
        break;
      case 'ready-to-eat':
        chipBackgroundColor = const Color(0xFFE8F5E9);
        chipTextColor = const Color(0xFF2E7D32);
        icon = Icons.restaurant_outlined;
        break;
      case 'beverage':
      case 'drink':
        chipBackgroundColor = const Color(0xFFE0F7FA);
        chipTextColor = const Color(0xFF00838F);
        icon = Icons.coffee_outlined;
        break;
      case 'organic':
        chipBackgroundColor = const Color(0xFFF1F8E9);
        chipTextColor = const Color(0xFF558B2F);
        icon = Icons.spa_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipTextColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipTextColor),
          const SizedBox(width: 5),
          Text(
            type,
            style: TextStyle(
              color: chipTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// About Tab Widget
class AboutTab extends StatelessWidget {
  final String title;
  final List<String> types;
  final String description;
  final String quantity;
  final String price;
  final String facts;
  final String locationText;
  final String ecoscoreStatName;
  final int ecoscoreStatValue;

  const AboutTab({
    Key? key,
    required this.title,
    required this.types,
    required this.description,
    required this.quantity,
    required this.price,
    required this.facts,
    required this.locationText,
    required this.ecoscoreStatName,
    required this.ecoscoreStatValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color ecoColor = ecoscoreStatValue >= 70
        ? const Color(0xFF2E7D32)
        : ecoscoreStatValue >= 40
            ? Colors.orange[800]!
            : Colors.red[700]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Category Chips
          Center(
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: types.map((type) => TypeChip(type: type)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Ecoscore Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ecoColor.withOpacity(0.12),
                  const Color(0xFFF1F8E9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ecoColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ecoColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ecoColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$ecoscoreStatValue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ecoscoreStatName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ecoColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              ecoscoreStatValue >= 70
                                  ? 'Eco-Friendly'
                                  : ecoscoreStatValue >= 40
                                      ? 'Moderate Impact'
                                      : 'High Impact',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ecoColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (ecoscoreStatValue / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(ecoColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Two-column metric cards: Quantity and Price/Calories
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.scale_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quantity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt_outlined,
                              size: 16, color: Colors.amber[800]),
                          const SizedBox(width: 6),
                          Text(
                            'Energy / Value',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.article_outlined,
                        size: 18, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Product Overview',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Origin & Manufacturing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origin & Manufacturing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        locationText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Facts Highlight Card
          if (facts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sustainability Facts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facts,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Base Stats Tab Widget (Nutrition & Ingredients)
class BaseStatsTab extends StatelessWidget {
  final List<StatRowData> nutritionStats;
  final String ingredientsDescription;
  final List<TypeDefenseChipData> typeDefenseChips;
  final List<ChartData> chartData;

  const BaseStatsTab({
    Key? key,
    required this.nutritionStats,
    required this.ingredientsDescription,
    required this.typeDefenseChips,
    required this.chartData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutrition Header & Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart_outlined,
                        size: 20, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Nutritional Values',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (nutritionStats.isEmpty)
                  const Text('No nutritional details available',
                      style: TextStyle(color: Colors.grey))
                else
                  ...nutritionStats
                      .map((stat) =>
                          StatRow(statName: stat.name, statValue: stat.value))
                      .toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ingredients Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_list_bulleted_outlined,
                        size: 20, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ingredientsDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nutritional Breakdown Chart Card
          if (chartData.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart_outline,
                          size: 20, color: Color(0xFF2E7D32)),
                      SizedBox(width: 8),
                      Text(
                        'Nutritional Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 320,
                    child: SfCircularChart(
                      legend: const Legend(
                        isVisible: true,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.bottom,
                      ),
                      series: <PieSeries<ChartData, String>>[
                        PieSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.value,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          name: 'Nutrition',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Good/Bad Ingredients Tab Widget
class GoodBadIngredientsTab extends StatelessWidget {
  final List<String> goodIngredients;
  final List<String> badIngredients;

  const GoodBadIngredientsTab({
    Key? key,
    required this.goodIngredients,
    required this.badIngredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIngredientSection(
            title: 'Beneficial Ingredients',
            subtitle: 'Ingredients with healthy or eco-friendly properties',
            ingredients: goodIngredients,
            color: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),
          _buildIngredientSection(
            title: 'Ingredients to Note',
            subtitle: 'Ingredients to consume with awareness',
            ingredients: badIngredients,
            color: Colors.orange[800]!,
            bgColor: const Color(0xFFFFF3E0),
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIngredientSection({
    required String title,
    required String subtitle,
    required List<String> ingredients,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          if (ingredients.isEmpty)
            const Text('No ingredients listed in this category',
                style: TextStyle(color: Colors.grey, fontSize: 13))
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: ingredients.map((ingredient) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 6),
                      Text(
                        ingredient,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// Tips Tab Widget
class TipsTab extends StatelessWidget {
  final List<String> healthTips;
  final List<String> environmentTips;
  final List<String> ecoTips;

  const TipsTab({
    Key? key,
    required this.healthTips,
    required this.environmentTips,
    required this.ecoTips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipSection('Health Tips', healthTips, Icons.health_and_safety,
              Colors.red[700]!, const Color(0xFFFFEBEE)),
          const SizedBox(height: 16),
          _buildTipSection('Environment Tips', environmentTips, Icons.eco,
              const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
          const SizedBox(height: 16),
          _buildTipSection('Eco Tips', ecoTips, Icons.lightbulb,
              Colors.amber[800]!, const Color(0xFFFFF8E1)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTipSection(String title, List<String> tips, IconData icon,
      Color color, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// Chart Data Class
class ChartData {
  ChartData(this.category, this.value);
  final String category;
  final double value;
}

// Stat Row Data Class
class StatRowData {
  StatRowData(this.name, this.value);
  final String name;
  final int value;
}

// Type Defense Chip Data Class
class TypeDefenseChipData {
  TypeDefenseChipData(this.type, this.multiplier);
  final String type;
  final String multiplier;
}

// Stat Row Widget
class StatRow extends StatelessWidget {
  final String statName;
  final int statValue;

  const StatRow({Key? key, required this.statName, required this.statValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color barColor = statValue >= 70
        ? const Color(0xFF2E7D32)
        : statValue >= 40
            ? Colors.orange[800]!
            : Colors.red[700]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              statName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (statValue / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: barColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$statValue',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Type Defense Chip Widget
class TypeDefenseChip extends StatelessWidget {
  final String type;
  final String multiplier;
  final Color? backgroundColor;

  const TypeDefenseChip({
    Key? key,
    required this.type,
    required this.multiplier,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (backgroundColor ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$type $multiplier',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}