import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:game_ui/dummy_data/apps.dart';
import 'package:game_ui/widgets/admins.dart';
import 'package:game_ui/widgets/draggable.dart';
import 'package:game_ui/widgets/nav_bar.dart';

void main() {
  runApp(const MyApp());
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
      backgroundColor: const Color(0xff212121),
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned(
                  top: 200,
                  left: 10,
                  child:
                      GradientBall(colors: [Colors.deepOrange, Colors.amber]),
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
