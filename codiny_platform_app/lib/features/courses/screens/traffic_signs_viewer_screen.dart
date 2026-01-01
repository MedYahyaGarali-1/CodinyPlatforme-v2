import 'package:flutter/material.dart';
import '../../../data/models/traffic_sign.dart';

class TrafficSignsViewerScreen extends StatefulWidget {
  const TrafficSignsViewerScreen({super.key});

  @override
  State<TrafficSignsViewerScreen> createState() => _TrafficSignsViewerScreenState();
}

class _TrafficSignsViewerScreenState extends State<TrafficSignsViewerScreen> {
  String _selectedCategory = 'الكل';
  List<TrafficSign> _filteredSigns = [];
  TrafficSign? _selectedSign;

  @override
  void initState() {
    super.initState();
    _filteredSigns = TrafficSignsData.getAllSigns();
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'الكل') {
        _filteredSigns = TrafficSignsData.getAllSigns();
      } else {
        final categoryKey = TrafficSignsData.getCategoryInEnglish(category);
        _filteredSigns = TrafficSignsData.getAllSigns()
            .where((sign) => sign.category == categoryKey)
            .toList();
      }
    });
  }

  void _showSignDetail(TrafficSign sign) {
    setState(() {
      _selectedSign = sign;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text(
          'إشارات المرور',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1D1E33),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: TrafficSignsData.getCategories().length,
              itemBuilder: (context, index) {
                final category = TrafficSignsData.getCategories()[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _filterByCategory(category),
                    backgroundColor: const Color(0xFF0A0E21),
                    selectedColor: const Color(0xFF6C63FF),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                    ),
                  ),
                );
              },
            ),
          ),

          // Signs grid
          Expanded(
            child: _selectedSign != null
                ? _buildSignDetail()
                : _buildSignsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSignsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredSigns.length,
      itemBuilder: (context, index) {
        final sign = _filteredSigns[index];
        return _buildSignCard(sign);
      },
    );
  }

  Widget _buildSignCard(TrafficSign sign) {
    return InkWell(
      onTap: () => _showSignDetail(sign),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  sign.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.white38,
                    );
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                sign.arabicName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignDetail() {
    final sign = _selectedSign!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedSign = null;
                });
              },
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6C63FF)),
              label: const Text(
                'رجوع للقائمة',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign image - large
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(40),
            child: Image.asset(
              sign.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Sign info card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF),
                  const Color(0xFF6C63FF).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arabic name
                Text(
                  sign.arabicName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // English name
                Text(
                  sign.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),

                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getCategoryNameInArabic(sign.category),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sign.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryNameInArabic(String category) {
    switch (category) {
      case 'speed':
        return 'إشارات السرعة';
      case 'warning':
        return 'إشارات تحذيرية';
      case 'prohibition':
        return 'إشارات منع';
      case 'mandatory':
        return 'إشارات إلزامية';
      case 'priority':
        return 'إشارات أولوية';
      case 'information':
        return 'إشارات معلوماتية';
      default:
        return category;
    }
  }
}
