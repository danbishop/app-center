/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/app/package_installer/wizard_page.dart';
import 'package:software/services/packagekit/package_state.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/app/common/utils.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageInstallerApp extends StatelessWidget {
  const PackageInstallerApp({Key? key, required this.path}) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          debugShowCheckedModeBanner: false,
          title: 'Package Installer',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          onGenerateTitle: (context) => context.l10n.appTitle,
          routes: {
            Navigator.defaultRouteName: (context) =>
                _PackageInstallerPage.create(path)
          },
        );
      },
    );
  }
}

class _PackageInstallerPage extends StatefulWidget {
  // ignore: unused_element
  const _PackageInstallerPage({super.key});

  static Widget create(String path) {
    return ChangeNotifierProvider(
      create: (context) =>
          PackageModel(service: getService<PackageService>(), path: path),
      child: const _PackageInstallerPage(),
    );
  }

  @override
  State<_PackageInstallerPage> createState() => _PackageInstallerPageState();
}

class _PackageInstallerPageState extends State<_PackageInstallerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PackageModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();

    return WizardPage(
      title: Text(context.l10n.packageInstaller),
      actions: [
        if (model.isInstalled == null)
          const SizedBox.shrink()
        else if (model.isInstalled!)
          ElevatedButton(
            onPressed: model.packageId == null ||
                    model.packageId!.name.isEmpty ||
                    model.packageState == PackageState.processing
                ? null
                : () => model.remove(),
            child: Text(context.l10n.remove),
          )
        else
          ElevatedButton(
            onPressed: model.packageId == null ||
                    model.packageId!.name.isEmpty ||
                    model.packageState != PackageState.ready
                ? null
                : () => model.install(),
            child: Text(context.l10n.install),
          ),
      ],
      content: Center(
        child: SingleChildScrollView(
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              YaruSection(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  children: [
                    YaruTile(
                      title: Text(context.l10n.name),
                      trailing: Text(model.packageId?.name ?? ''),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    YaruTile(
                      title: Text(context.l10n.version),
                      trailing: Text(model.packageId?.version ?? ''),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    YaruTile(
                      title: Text(context.l10n.architecture),
                      trailing: Text(model.packageId?.arch ?? ''),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    YaruTile(
                      title: Text(context.l10n.source),
                      trailing: Text(model.packageId?.data ?? ''),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    YaruTile(
                      title: Text(context.l10n.license),
                      trailing: Text(model.license),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    YaruTile(
                      title: Text(context.l10n.size),
                      trailing: Text(formatBytes(model.size, 2)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    YaruTile(
                      title: Text(context.l10n.description),
                      trailing: Flexible(
                        child: Text(
                          model.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 145,
                      height: 185,
                      child: LiquidLinearProgressIndicator(
                        value: model.percentage / 100,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                        direction: Axis.vertical,
                        borderRadius: 20,
                      ),
                    ),
                    Icon(
                      YaruIcons.debian,
                      size: 120,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}