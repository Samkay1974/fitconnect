import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/loading_indicator.dart';

class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({Key? key}) : super(key: key);

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadActivities() {
    final authProvider = context.read<AuthProvider>();
    final activityProvider = context.read<ActivityProvider>();

    if (authProvider.currentUser != null) {
      activityProvider.setCurrentUserId(authProvider.currentUser!.id);
      activityProvider.fetchActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UiProvider>(
      builder: (context, uiProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Activities'),
            elevation: 0,
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Joined'),
                Tab(text: 'Created'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Joined Activities
              Consumer<ActivityProvider>(
                builder: (context, activityProvider, _) {
                  if (activityProvider.isLoading) {
                    return const LoadingIndicator(
                      message: 'Loading joined activities...',
                    );
                  }

                  if (activityProvider.userJoinedActivities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark_outline,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          Text(
                            'No joined activities',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          Text(
                            'Explore and join activities to see them here',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    itemCount:
                        activityProvider.userJoinedActivities.length,
                    itemBuilder: (context, index) {
                      final activity =
                          activityProvider.userJoinedActivities[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.paddingLarge,
                        ),
                        child: ActivityCard(
                          activity: activity.copyWith(isJoined: true),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppConstants.routeActivityDetails,
                              arguments: activity.id,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              // Created Activities
              Consumer<ActivityProvider>(
                builder: (context, activityProvider, _) {
                  if (activityProvider.isLoading) {
                    return const LoadingIndicator(
                      message: 'Loading created activities...',
                    );
                  }

                  if (activityProvider.userCreatedActivities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.create_outlined,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          Text(
                            'No created activities',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          Text(
                            'Create an activity to get started',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    itemCount:
                        activityProvider.userCreatedActivities.length,
                    itemBuilder: (context, index) {
                      final activity = activityProvider
                          .userCreatedActivities[index];
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
