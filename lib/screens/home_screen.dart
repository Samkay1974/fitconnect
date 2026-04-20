import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../models/activity_type.dart';
import '../providers/activity_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_type_filter_chip.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/notification_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadActivities() {
    final activityProvider = context.read<ActivityProvider>();
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    activityProvider.setCurrentUserId(authProvider.currentUser?.id);
    activityProvider.fetchActivities();

    // Fetch notifications for current user
    if (authProvider.currentUser != null) {
      notificationProvider.fetchNotifications(authProvider.currentUser!.id);
    }
  }

  void _handleSearch(String query) {
    final activityProvider = context.read<ActivityProvider>();
    if (query.isEmpty) {
      activityProvider.clearSearch();
    } else {
      activityProvider.searchActivities(query);
    }
  }

  void _handleFilterByType(ActivityType? type) {
    final activityProvider = context.read<ActivityProvider>();
    if (type == null) {
      _searchController.clear();
      activityProvider.clearFilters();
      return;
    }

    activityProvider.filterByType(type);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name.trim().isNotEmpty == true
        ? authProvider.currentUser!.name.trim()
        : 'there';

    return Consumer<UiProvider>(
      builder: (context, uiProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConstants.appName),
            elevation: 0,
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppTheme.paddingMedium),
                child: NotificationBadge(
                  onPressed: () {
                    Navigator.pushNamed(context, AppConstants.routeNotifications);
                  },
                ),
              ),
            ],
          ),
          body: Consumer<ActivityProvider>(
            builder: (context, activityProvider, _) {
              return Column(
                children: [
                  // Hero + Search panel
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryDark,
                            AppTheme.primaryColor,
                            AppTheme.primaryLight.withValues(alpha: 0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.sports,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppTheme.paddingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, $userName',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Find Your Next Match',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      'Football, aerobics, jogging and more',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.paddingLarge),
                          TextField(
                            controller: _searchController,
                            onChanged: _handleSearch,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search by activity or location',
                              hintStyle: const TextStyle(color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _handleSearch('');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingLarge,
                    ),
                    child: Row(
                      children: [
                          FilterChip(
                            label: const Text('All Types'),
                            selected: activityProvider.selectedType == null,
                            onSelected: (_) => _handleFilterByType(null),
                            backgroundColor: AppTheme.backgroundColor,
                            selectedColor: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          ...ActivityType.values.map(
                            (type) => Padding(
                              padding: const EdgeInsets.only(
                                right: AppTheme.paddingMedium,
                              ),
                              child: ActivityTypeFilterChip(
                                type: type,
                                isSelected: activityProvider.selectedType == type,
                                onSelected: () => _handleFilterByType(type),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.paddingMedium),

                  // Activities list
                  Expanded(
                    child: activityProvider.isLoading
                        ? const LoadingIndicator(message: 'Loading activities...')
                        : activityProvider.activities.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: AppTheme.textTertiary,
                                    ),
                                    const SizedBox(
                                      height: AppTheme.paddingMedium,
                                    ),
                                    Text(
                                      'No activities found',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  _loadActivities();
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingLarge,
                                  ),
                                  itemCount: activityProvider.activities.length,
                                  itemBuilder: (context, index) {
                                    final activity =
                                        activityProvider.activities[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppTheme.paddingLarge,
                                      ),
                                      child: ActivityCard(
                                        activity: activity,
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            AppConstants.routeActivityDetails,
                                            arguments: activity.id,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppConstants.routeCreateActivity,
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Activity'),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: uiProvider.selectedBottomNavIndex,
            onTap: (index) {
              uiProvider.setSelectedBottomNavIndex(index);
              switch (index) {
                case 0:
                  // Home - already here
                  break;
                case 1:
                  Navigator.of(context).pushNamed(
                    AppConstants.routeMyActivities,
                  );
                  break;
                case 2:
                  Navigator.of(context).pushNamed(
                    AppConstants.routeProfile,
                  );
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline),
                activeIcon: Icon(Icons.bookmark),
                label: 'My Activities',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
