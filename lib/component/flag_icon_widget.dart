import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/common.dart';
import 'package:storyapp/provider/localization_provider.dart';
import 'package:storyapp/util/localization.dart';

class FlagIconWidget extends StatelessWidget {
  const FlagIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        icon: const Icon(Icons.language_outlined),
        items:
            AppLocalizations.supportedLocales.map((Locale locale) {
              final flag = Localization.getFlag(locale.languageCode);
              final languageName = Localization.getFlagName(
                locale.languageCode,
              );
              return DropdownMenuItem(
                value: locale,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        flag,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        languageName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  final provider = Provider.of<LocalizationProvider>(
                    context,
                    listen: false,
                  );
                  provider.setLocale(locale);
                },
              );
            }).toList(),
        onChanged: (_) {},
      ),
    );
  }
}
