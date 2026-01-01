import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/environment.dart';

class RevenueStatsWidget extends StatefulWidget {
  final String token;
  final String? schoolId; // null for admin, schoolId for school

  const RevenueStatsWidget({
    super.key,
    required this.token,
    this.schoolId,
  });

  @override
  State<RevenueStatsWidget> createState() => _RevenueStatsWidgetState();
}

class _RevenueStatsWidgetState extends State<RevenueStatsWidget> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = widget.schoolId != null
          ? '${Environment.baseUrl}/schools/${widget.schoolId}/revenue'
          : '${Environment.baseUrl}/admin/revenue/stats';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load revenue stats';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_error!, style: TextStyle(color: colorScheme.error)),
        ),
      );
    }

    final totals = _stats?['totals'] ?? {};
    final isAdmin = widget.schoolId == null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  isAdmin ? 'Platform Revenue' : 'School Revenue',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            if (isAdmin) ...[
              _buildStatRow(
                context,
                'Platform Revenue',
                '${totals['total_platform_revenue'] ?? 0} TND',
                Colors.green,
                Icons.trending_up,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                'Schools Revenue',
                '${totals['total_school_revenue'] ?? 0} TND',
                Colors.blue,
                Icons.school,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                'Total Revenue',
                '${totals['total_revenue'] ?? 0} TND',
                Colors.purple,
                Icons.account_balance,
              ),
            ] else ...[
              _buildStatRow(
                context,
                'Total Revenue',
                '${totals['total_revenue'] ?? 0} TND',
                Colors.green,
                Icons.account_balance_wallet,
              ),
            ],
            
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              isAdmin ? 'Total Transactions' : 'Students Approved',
              '${totals['total_transactions'] ?? totals['total_students_approved'] ?? 0}',
              Colors.orange,
              Icons.people,
            ),
            
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
