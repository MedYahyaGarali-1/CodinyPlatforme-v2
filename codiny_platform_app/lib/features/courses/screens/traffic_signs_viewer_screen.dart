import 'package:flutter/material.dart';
import '../../../data/models/traffic_sign.dart';

class TrafficSignsViewerScreen extends StatefulWidget {
  const TrafficSignsViewerScreen({super.key});

  @override
  State<TrafficSignsViewerScreen> createState() => _TrafficSignsViewerScreenState();
}

class _TrafficSignsViewerScreenState extends State<TrafficSignsViewerScreen>
    with TickerProviderStateMixin {
  String _selectedCategory = 'الكل';
  List<TrafficSign> _filteredSigns = [];
  TrafficSign? _selectedSign;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _filteredSigns = TrafficSignsData.getAllSigns();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
    // Restart animation when filter changes
    _animationController?.reset();
    _animationController?.forward();
  }

  void _showSignDetail(TrafficSign sign) {
    setState(() {
      _selectedSign = sign;
    });
  }

  // Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'الكل':
        return Icons.apps_rounded;
      case 'السرعة':
        return Icons.speed_rounded;
      case 'تحذيرية':
        return Icons.warning_rounded;
      case 'منع':
        return Icons.block_rounded;
      case 'إلزامية':
        return Icons.check_circle_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  // Get color for category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'الكل':
        return const Color(0xFF6C63FF);
      case 'السرعة':
        return Colors.blue;
      case 'تحذيرية':
        return Colors.amber;
      case 'منع':
        return Colors.red;
      case 'إلزامية':
        return Colors.green;
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1D1E33) : Colors.white,
        title: Text(
          'إشارات المرور',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1E33),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1D1E33),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f0f1a),
                  ]
                : [
                    Colors.blue.shade50.withOpacity(0.5),
                    Colors.purple.shade50.withOpacity(0.3),
                    Colors.grey[50]!,
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Category filter
            _buildCategoryFilter(isDark),

            // Signs count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_filteredSigns.length} إشارة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.traffic_rounded,
                    size: 18,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Signs grid
            Expanded(
              child: _selectedSign != null
                  ? _buildSignDetail(isDark)
                  : _buildSignsGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    final categories = TrafficSignsData.getCategories();
    
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1E33).withOpacity(0.5) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL scroll
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          final categoryColor = _getCategoryColor(category);
          
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _filterByCategory(category),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                categoryColor,
                                categoryColor.withOpacity(0.7),
                              ],
                            )
                          : null,
                      color: isSelected 
                          ? null 
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.transparent 
                            : (isDark ? Colors.white24 : Colors.grey[300]!),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : (isDark ? Colors.white70 : Colors.grey[700]),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _getCategoryIcon(category),
                          size: 18,
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignsGrid(bool isDark) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: _filteredSigns.length,
      itemBuilder: (context, index) {
        final sign = _filteredSigns[index];
        
        // If animation controller is not ready, just show the card
        if (_animationController == null) {
          return _buildSignCard(sign, isDark);
        }
        
        // Limit stagger delay to first 15 items for performance
        final delay = (index < 15) ? index * 0.03 : 0.45;
        
        return AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            double animationValue = 0.0;
            if (_animationController!.value > delay) {
              animationValue = Curves.easeOut.transform(
                ((_animationController!.value - delay) / (1.0 - delay)).clamp(0.0, 1.0),
              );
            }
            
            return Transform.translate(
              offset: Offset(0, 20 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: child,
              ),
            );
          },
          child: _buildSignCard(sign, isDark),
        );
      },
    );
  }

  Widget _buildSignCard(TrafficSign sign, bool isDark) {
    final categoryColor = _getCategoryColorByKey(sign.category);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSignDetail(sign),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: categoryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Sign image
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    sign.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_rounded,
                        size: 40,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      );
                    },
                  ),
                ),
              ),
              // Sign name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor.withOpacity(0.15),
                      categoryColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  sign.arabicName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D1E33),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColorByKey(String categoryKey) {
    switch (categoryKey) {
      case 'speed':
        return Colors.blue;
      case 'warning':
        return Colors.amber.shade700;
      case 'prohibition':
        return Colors.red;
      case 'mandatory':
        return Colors.green;
      case 'priority':
        return Colors.orange;
      case 'information':
        return Colors.teal;
      default:
        return const Color(0xFF6C63FF);
    }
  }

  Widget _buildSignDetail(bool isDark) {
    final sign = _selectedSign!;
    final categoryColor = _getCategoryColorByKey(sign.category);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedSign = null;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'رجوع للقائمة',
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: categoryColor, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign image - large
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Image.asset(
              sign.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported_rounded,
                  size: 80,
                  color: Colors.grey[400],
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // Sign info card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor,
                  categoryColor.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Arabic name
                Text(
                  sign.arabicName,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // English name
                Text(
                  sign.name,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),

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
                      Text(
                        _getCategoryNameInArabic(sign.category),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.category_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          sign.description,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: 22,
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
