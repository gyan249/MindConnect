import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'config.dart';
import 'dashboard.dart';
import 'community.dart';
import 'chatbot.dart';
import 'daily_quiz.dart';
import 'wellness_assessment.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

import 'theme_controller.dart';
import 'language_controller.dart';
import 'strings.dart';

// Extra sections (Books removed)
import 'journal_screen.dart';
import 'yoga_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await themeController.loadTheme();
  await languageController.loadLanguage();
  runApp(const MindConnectApp());
}

class MindConnectApp extends StatelessWidget {
  const MindConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Roboto',
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Roboto',
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF111111),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([
        themeController,
        languageController,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: S.of('app_title'),
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return const MainContainer();
      },
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startMoodQuiz() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyMoodQuiz(
          lang: languageController.currentLanguage,
          onComplete: (result, score) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('moodEntries')
                .add({
              'result': result,
              'score': score,
              'timestamp': FieldValue.serverTimestamp(),
            });
          },
        ),
      ),
    );
  }

  void _startWellness() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WellnessAssessment(
          lang: languageController.currentLanguage,
          onComplete: (result, score) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('wellnessEntries')
                .add({
              'result': result,
              'score': score,
              'timestamp': FieldValue.serverTimestamp(),
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final userName = (data != null &&
                data['name'] is String &&
                (data['name'] as String).isNotEmpty)
            ? data['name']
            : user.email ?? "MindConnect user";

        final pages = [
          HomeScreen(
            lang: languageController.currentLanguage,
            onStartMood: _startMoodQuiz,
            onStartWellness: _startWellness,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          HistoryScreen(userId: user.uid),
          GroupsScreen(userId: user.uid, userName: userName),
        ];

        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.primary),
                  accountName: Text(userName),
                  accountEmail: Text(user.email ?? ''),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),

                // ------------ MENU ITEMS ------------

                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(S.of('drawer_profile')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: const Text("Journal Writing"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JournalScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.self_improvement),
                  title: const Text("Yoga"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const YogaScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(S.of('drawer_settings')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(S.of('drawer_logout')),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          body: SafeArea(child: pages[_selectedIndex]),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primary,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: S.of('nav_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: S.of('nav_history'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.group_outlined),
                activeIcon: const Icon(Icons.group),
                label: S.of('nav_groups'),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIChatPage(
                    lang: languageController.currentLanguage,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
