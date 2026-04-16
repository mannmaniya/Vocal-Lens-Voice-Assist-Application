import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/auth_controller.dart';
import 'package:vocal_lens/Controllers/theme_controller.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Flexify.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text(
          tr(
            "user_settings",
          ),
        ),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: Consumer<AuthController>(builder: (context, authValue, _) {
        final user = authValue.user;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildUserProfileCard(user),
              _buildNotificationCard(context),
              // _buildDarkModeCard(),
              _buildLanguageSelectionCard(context),
              _buildLogoutCard(context, authValue),
            ],
          ),
        );
      }),
    );
  }

  /// User Profile Card
  Widget _buildUserProfileCard(user) {
    return Card(
      elevation: 5,
      color: Colors.blueGrey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            user?.photoURL ??
                'https://lh3.googleusercontent.com/a/ACg8ocI9QCdU3XG6sRX9S-O-A4HKn-RyUKPdBnjpHc01KwSZ6eXskwE=s360-c-no',
          ),
        ),
        title: Text(
          user?.displayName ?? 'Kunal Gangani',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user?.email ?? 'thekunalgangani@gmail.com',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  /// Notification Toggle Card
  Widget _buildNotificationCard(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.blueGrey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          tr('notifications'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tr(
            'enable_disable_notifications',
          ),
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: Switch(
          value: true,
          onChanged: (bool value) {
            Provider.of<AuthController>(context, listen: false)
                .toggleNotifications();
          },
          activeThumbColor: Colors.blueGrey.shade900,
        ),
      ),
    );
  }

  /// Dark Mode Toggle Card
  Widget _buildDarkModeCard() {
    return Consumer<ThemeController>(builder: (context, themeController, _) {
      return Card(
        elevation: 5,
        color: Colors.blueGrey.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            tr('dark_mode'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            tr('enable_disable_dark_theme'),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: Switch(
            value: themeController.isDarkMode,
            onChanged: (bool value) {
              themeController.toggleTheme();
            },
            activeThumbColor: Colors.blueGrey.shade200,
          ),
        ),
      );
    });
  }

  /// Language Selection Card
  Widget _buildLanguageSelectionCard(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.blueGrey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          tr('language'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tr('change_app_language'),
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        onTap: () {
          showLanguageSelectionDialog(context);
        },
      ),
    );
  }

  /// Logout Card
  Widget _buildLogoutCard(BuildContext context, AuthController authValue) {
    return Card(
      elevation: 5,
      color: Colors.blueGrey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          tr('log_out'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tr('log_out_account'),
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Colors.blueGrey.shade800,
            ),
          ),
          onPressed: () async {
            bool? shouldSignOut = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.black,
                  title: Text(
                    tr('sign_out'),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  content: Text(
                    tr('log_out_confirm'),
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        tr('cancel'),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(
                        tr('im_sure'),
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );

            if (shouldSignOut == true) {
              await authValue.signOut();
            }
          },
          child: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// **Language Selection Dialog**
void showLanguageSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.blueGrey.shade900,
        title: Text(tr("Select Language"),
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            languageOption(
              context,
              'English',
              const Locale(
                'en',
                'US',
              ),
            ),
            languageOption(
              context,
              'Español',
              const Locale(
                'es',
                'ES',
              ),
            ),
            languageOption(
              context,
              'Français',
              const Locale(
                'fr',
                'FR',
              ),
            ),
            languageOption(
              context,
              'Deutsch',
              const Locale(
                'de',
                'DE',
              ),
            ),
            languageOption(
              context,
              'हिन्दी',
              const Locale(
                'hi',
                'IN',
              ),
            ),
            languageOption(
              context,
              'Nederlands',
              const Locale(
                'nl',
                'NL',
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget languageOption(BuildContext context, String name, Locale locale) {
  return ListTile(
    title: Text(
      name,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    onTap: () {
      context.setLocale(locale);
      Flexify.back();
    },
  );
}
