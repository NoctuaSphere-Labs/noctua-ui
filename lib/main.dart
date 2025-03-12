import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_ui/dummy_data/apps.dart';
import 'package:game_ui/widgets/admins.dart';
import 'package:game_ui/widgets/draggable.dart';
import 'package:game_ui/widgets/nav_bar.dart';
import 'dart:html' as html;
import 'dart:async';


final streamController = StreamController();

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(left: 56.0, right: 56.0, bottom: 56.0),
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
                    iconWidth: 91, // Icon width + Spacing
                    iconLength: 12, // Number of icons
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
