import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_ui/dummy_data/apps.dart';
import 'package:game_ui/widgets/admins.dart';
import 'package:game_ui/widgets/draggable.dart';
import 'package:game_ui/widgets/nav_bar.dart';
import 'dart:html' as html;
import 'dart:async';

import 'package:game_ui/widgets/neon_icon.dart';

final streamController = StreamController();

// Model for app data with icon and color information
class AppData {
  final IconData icon;
  final Color hoverColor;

  const AppData({
    required this.icon,
    required this.hoverColor,
  });
}

void main() {
  final runnableApp = _buildRunnableApp(
    isWeb: kIsWeb,
    webAppWidth: 1920.0,
    app: const MyApp(),
  );

  html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is Map) {
      streamController.add(data);
    }
  });

  runApp(runnableApp);
}

Widget _buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return Center(
    child: ClipRect(
      child: SizedBox(
        width: webAppWidth,
        child: app,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quasar Roleplay'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final adminsWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlurryContainer(
        blur: 8,
        elevation: 6,
        padding: const EdgeInsets.all(32),
        color: Colors.white.withOpacity(0.15),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: admins.length,
          itemBuilder: (context, index) => admins[index],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(
          left: 4.0,
          right: 4.0,
          bottom: 4.0,
          // top: 4.0,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28.0),
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
            bottomRight: Radius.circular(28.0),
          ),
          child: Container(
            color: const Color(0xff212121),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Row showing open apps
                const OpenAppsRow(),

                // Implement a row of the open tabs
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        top: 200,
                        left: 10,
                        child: GradientBall(
                            colors: [Colors.deepOrange, Colors.amber]),
                      ),
                      const Positioned(
                        top: 400,
                        right: 10,
                        child: GradientBall(
                          size: Size.square(200),
                          colors: [Colors.blue, Colors.purple],
                        ),
                      ),
                      DraggableContainer(
                        child: adminsWidget,
                      ),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: NavBar(
                    iconWidth: 81, // Icon width + Spacing
                    iconLength: 12, // Number of icons
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: apps,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OpenAppsRow extends StatefulWidget {
  const OpenAppsRow({super.key});

  @override
  State<OpenAppsRow> createState() => _OpenAppsRowState();
}

class _OpenAppsRowState extends State<OpenAppsRow> {
  // List of open apps that can be modified
  final List<AppData> _openApps = [
    const AppData(
      icon: Icons.local_fire_department,
      hoverColor: Colors.red,
    ),
    const AppData(
      icon: Icons.shield,
      hoverColor: Colors.blue,
    ),
    const AppData(
      icon: Icons.favorite,
      hoverColor: Colors.pink,
    ),
  ];

  // Remove an app from the list
  void _removeApp(int index) {
    setState(() {
      _openApps.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      child: BlurryContainer(
        blur: 8,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Open Apps:",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            // Display open apps with X button
            ..._openApps.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // App icon
                    NeonIcon(
                      icon: app.icon,
                      color: Colors.white,
                      hoverColor: app.hoverColor,
                      size: 36,
                    ),
                    // X button for closing app
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => _removeApp(index),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Spacer(),
            // Add button to open new app
          ],
        ),
      ),
    );
  }
}

class GradientBall extends StatelessWidget {
  final List<Color> colors;
  final Size size;

  const GradientBall({
    super.key,
    required this.colors,
    this.size = const Size.square(150),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
        ),
      ),
    );
  }
}
