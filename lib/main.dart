import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/explore_page.dart';
import 'package:software/pages/my_apps/my_apps_page.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

void main() async {
  runApp(MultiProvider(
    providers: [
      Provider<SnapdClient>(
        create: (_) => SnapdClient(),
        dispose: (_, client) => client.close(),
      ),
    ],
    child: App(),
  ));
}

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ubuntu Software App',
      home: YaruTheme(
        child: Scaffold(
          body: YaruCompactLayout(
            pageItems: pageItems,
          ),
        ),
      ),
    );
  }
}

final pageItems = [
  YaruPageItem(
    titleBuilder: MyAppsPage.createTitle,
    builder: MyAppsPage.create,
    iconData: YaruIcons.app_grid,
  ),
  YaruPageItem(
    titleBuilder: ExplorePage.createTitle,
    builder: ExplorePage.create,
    iconData: YaruIcons.search,
  ),
  YaruPageItem(
    titleBuilder: (context) => Text('Updates'),
    builder: (_) => Center(child: Text('Updates')),
    iconData: YaruIcons.save,
  ),
];
