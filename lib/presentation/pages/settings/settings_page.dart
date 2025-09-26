import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Appearance'),
                _buildThemeCard(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Notifications'),
                _buildNotificationCard(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Account'),
                _buildAccountCard(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('About'),
                _buildAboutCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(isDarkMode ? 'Enabled' : 'Disabled'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeBloc>().add(ThemeToggled());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildNotificationItem(
            'Push Notifications',
            'Receive notifications about orders and offers',
            true,
          ),
          const Divider(height: 1),
          _buildNotificationItem(
            'Email Notifications',
            'Get updates via email',
            true,
          ),
          const Divider(height: 1),
          _buildNotificationItem(
            'SMS Notifications',
            'Receive SMS for important updates',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, bool value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          // Handle notification toggle
        },
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAccountItem(
            Icons.person,
            'Edit Profile',
            'Update your personal information',
            () {},
          ),
          const Divider(height: 1),
          _buildAccountItem(
            Icons.lock,
            'Change Password',
            'Update your account password',
            () {},
          ),
          const Divider(height: 1),
          _buildAccountItem(
            Icons.privacy_tip,
            'Privacy Settings',
            'Manage your privacy preferences',
            () {},
          ),
          const Divider(height: 1),
          _buildAccountItem(
            Icons.delete,
            'Delete Account',
            'Permanently delete your account',
            () {
              _showDeleteAccountDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDestructive 
            ? Colors.red.withOpacity(0.1)
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: isDestructive 
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAboutItem(
            Icons.info,
            'App Version',
            '1.0.0',
            () {},
          ),
          const Divider(height: 1),
          _buildAboutItem(
            Icons.help,
            'Help & Support',
            'Get help and contact support',
            () {},
          ),
          const Divider(height: 1),
          _buildAboutItem(
            Icons.description,
            'Terms of Service',
            'Read our terms and conditions',
            () {},
          ),
          const Divider(height: 1),
          _buildAboutItem(
            Icons.privacy_tip,
            'Privacy Policy',
            'Learn how we protect your data',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle account deletion
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
