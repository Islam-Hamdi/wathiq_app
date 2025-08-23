import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/circle_service.dart';
import '../../services/auth_service.dart';
import '../../models/circle_model.dart';
import '../../services/firebase_service.dart';
import '../../services/user_service.dart';

class CirclesScreen extends StatefulWidget {
  const CirclesScreen({super.key});

  @override
  State<CirclesScreen> createState() => _CirclesScreenState();
}

class _CirclesScreenState extends State<CirclesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _circleNameController = TextEditingController();
  final _circleDescriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _circleNameController.dispose();
    _circleDescriptionController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _createCircle() async {
    if (_circleNameController.text.isEmpty || _circleDescriptionController.text.isEmpty) {
      _showSnackBar('Please fill all fields', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final circleService = CircleService();

      if (authService.currentUser == null) {
        _showSnackBar('You must be logged in to create a circle', Colors.red);
        return;
      }

      final newCircle = CircleModel(
        id: FirebaseService.instance.generateId(),
        name: _circleNameController.text.trim(),
        description: _circleDescriptionController.text.trim(),
        ownerId: authService.currentUser!.uid, // ✅ correct field
        memberIds: [authService.currentUser!.uid], // ✅ use memberIds
        createdAt: DateTime.now(),
      );



      await circleService.createCircle(newCircle);
      _showSnackBar('Circle created successfully!', AppTheme.successGreen);
      _circleNameController.clear();
      _circleDescriptionController.clear();
      Navigator.pop(context); // Close dialog
    } catch (e) {
      _showSnackBar('Failed to create circle: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinCircle(String circleId) async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final circleService = CircleService();

      if (authService.currentUser == null) {
        _showSnackBar('You must be logged in to join a circle', Colors.red);
        return;
      }

      await circleService.joinCircle(circleId, authService.currentUser!.uid);
      _showSnackBar('Joined circle successfully!', AppTheme.successGreen);
    } catch (e) {
      _showSnackBar('Failed to join circle: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveCircle(String circleId) async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final circleService = CircleService();

      if (authService.currentUser == null) {
        _showSnackBar('You must be logged in to leave a circle', Colors.red);
        return;
      }

      await circleService.leaveCircle(circleId, authService.currentUser!.uid);
      _showSnackBar('Left circle successfully!', AppTheme.successGreen);
    } catch (e) {
      _showSnackBar('Failed to leave circle: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateCircleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Circle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _circleNameController,
              decoration: const InputDecoration(labelText: 'Circle Name'),
            ),
            TextField(
              controller: _circleDescriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _createCircle,
            child: _isLoading ? const CircularProgressIndicator() : const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final circleService = CircleService();
    final currentUserId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circles'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Circles'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Circles Tab
          StreamBuilder<List<CircleModel>>(
            stream: circleService.getUserCirclesStream(currentUserId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No circles yet',
                  subtitle: 'Create your first Trust Circle or join one!',
                  actionText: 'Create Circle',
                  onAction: _showCreateCircleDialog,
                );
              }

              final circles = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: circles.length,
                itemBuilder: (context, index) {
                  final circle = circles[index];
                  final isCreator = circle.ownerId == currentUserId;

                  return _CircleCard(
                    circle: circle,
                    isCreator: isCreator,
                    onTap: () {
                      // TODO: Navigate to circle details
                    },
                    onJoinLeave: isCreator 
                        ? null 
                        : (isMember) => isMember 
                            ? _leaveCircle(circle.id) 
                            : _joinCircle(circle.id),
                    currentUserId: currentUserId,
                    isLoading: _isLoading, // ← pass the parent's _isLoading

                  );
                },
              );
            },
          ),

          // Discover Circles Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Circles',
                    hintText: 'Enter circle name or description',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {}); // Rebuild to update stream builder
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<CircleModel>>(
                  stream: _searchController.text.isEmpty
                      ? circleService.getRecommendedCircles(currentUserId ?? '')
                      : circleService.searchCircles(_searchController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No circles found. Try a different search or create one!'));
                    }

                    final circles = snapshot.data!;

                    return ListView.builder(
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        final circle = circles[index];
                        final isMember = currentUserId != null &&
                            circle.isMember(currentUserId);
                        final isCreator = circle.ownerId == currentUserId;

                        return _CircleCard(
                          circle: circle,
                          isCreator: isCreator,
                          onTap: () {
                            // TODO: Navigate to circle details
                          },
                          onJoinLeave: isCreator 
                              ? null 
                              : (isMember) => isMember 
                                  ? _leaveCircle(circle.id) 
                                  : _joinCircle(circle.id),
                          currentUserId: currentUserId,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCircleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create Circle'),
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  final CircleModel circle;
  final bool isCreator;
  final VoidCallback onTap;
  final Function(bool isMember)? onJoinLeave;
  final String? currentUserId;
  final bool isLoading; // ← add this

  const _CircleCard({
    required this.circle,
    required this.isCreator,
    required this.onTap,
    this.onJoinLeave,
    this.currentUserId,
    this.isLoading = false, // default to false

  });

  @override
  Widget build(BuildContext context) {
    final isMember = circle.isMember(currentUserId!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCreator ? Icons.star : Icons.groups, // Changed Icons.crown to Icons.star
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.name,
                          style: AppTheme.title,
                        ),
                        if (isCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningAmber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Creator',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warningAmber,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Trust Score - Placeholder for now, needs to be calculated dynamically
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${circle.trustScore.toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                circle.description ??
                    'Uh Oh, No description to show', // fallback to empty string
                style: AppTheme.body,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.people,
                    label: '${circle.memberCount} Members',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.account_balance_wallet,
                    label: '${circle.totalLoans} Loans', // Placeholder
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.trending_up,
                    label:
                        '${circle.trustScore.toInt()}% Success', // Placeholder
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (onJoinLeave != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed:
                          isLoading ? null : () => onJoinLeave!(isMember),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isMember ? Colors.red : AppTheme.primaryBlue,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isMember ? 'Leave Circle' : 'Join Circle'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


