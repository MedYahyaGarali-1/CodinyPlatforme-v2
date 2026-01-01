import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../state/session/session_controller.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  late Future<void> _future;
  int _students = 0;
  int _earned = 0;
  int _owed = 0;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    final session = context.read<SessionController>();
    final repo = UserRepository();
    await repo.loadSchoolProfile(session);
    
    setState(() {
      _students = session.schoolProfile?.students ?? 0;
      _earned = session.schoolProfile?.earned ?? 0;
      _owed = session.schoolProfile?.owed ?? 0;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'TND ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snap) {
          // Loading State
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(
                  isLoading: true,
                  child: SkeletonCard(
                    height: 120,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          }

          // Error State
          if (snap.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to Load',
              message: snap.error.toString(),
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          final totalRevenue = _earned + _owed;
          final collectionRate = totalRevenue > 0 ? (_earned / totalRevenue) * 100 : 0;
          final averagePerStudent = _students > 0 ? totalRevenue / _students : 0;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card with Total Revenue
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white.withOpacity(0.9),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Total Revenue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currencyFormat.format(totalRevenue),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From $_students ${_students == 1 ? "student" : "students"}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Financial Overview Section
                Text(
                  'Financial Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Earned vs Owed Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        context,
                        title: 'Collected',
                        amount: _earned,
                        icon: Icons.check_circle,
                        color: Colors.green,
                        currencyFormat: currencyFormat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        context,
                        title: 'Pending',
                        amount: _owed,
                        icon: Icons.pending,
                        color: Colors.orange,
                        currencyFormat: currencyFormat,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Statistics Section
                Text(
                  'Key Metrics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Collection Rate Card
                _buildMetricCard(
                  context,
                  title: 'Collection Rate',
                  value: '${collectionRate.toStringAsFixed(1)}%',
                  subtitle: 'Of total revenue collected',
                  icon: Icons.trending_up,
                  progress: collectionRate / 100,
                  progressColor: collectionRate >= 70 ? Colors.green : Colors.orange,
                ),

                const SizedBox(height: 12),

                // Average Per Student Card
                _buildMetricCard(
                  context,
                  title: 'Average Per Student',
                  value: currencyFormat.format(averagePerStudent),
                  subtitle: 'Revenue per enrolled student',
                  icon: Icons.person,
                  progress: null,
                ),

                const SizedBox(height: 12),

                // Total Students Card
                _buildMetricCard(
                  context,
                  title: 'Total Students',
                  value: _students.toString(),
                  subtitle: 'Currently enrolled',
                  icon: Icons.people,
                  progress: null,
                ),

                const SizedBox(height: 24),

                // Payment Breakdown
                Text(
                  'Payment Breakdown',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildBreakdownRow(
                          context,
                          label: 'Total Expected',
                          amount: totalRevenue,
                          isTotal: true,
                          currencyFormat: currencyFormat,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _buildBreakdownRow(
                          context,
                          label: 'Collected',
                          amount: _earned,
                          color: Colors.green,
                          currencyFormat: currencyFormat,
                        ),
                        const SizedBox(height: 12),
                        _buildBreakdownRow(
                          context,
                          label: 'Pending',
                          amount: _owed,
                          color: Colors.orange,
                          currencyFormat: currencyFormat,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Financial data is updated in real-time as students make payments',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinancialCard(
    BuildContext context, {
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
    required NumberFormat currencyFormat,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormat.format(amount),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    double? progress,
    Color? progressColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor ?? colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context, {
    required String label,
    required int amount,
    Color? color,
    bool isTotal = false,
    required NumberFormat currencyFormat,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: color ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
