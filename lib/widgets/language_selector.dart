import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worshippro/l10n/app_localizations.dart';
import 'package:worshippro/providers/language_provider.dart';

/// Selector de idioma para la aplicación
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (String languageCode) {
        languageProvider.setLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'es',
            child: Row(
              children: [
                if (languageProvider.isSpanish)
                  const Icon(Icons.check, size: 20),
                if (languageProvider.isSpanish)
                  const SizedBox(width: 8),
                Text(l10n.spanish),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'en',
            child: Row(
              children: [
                if (languageProvider.isEnglish)
                  const Icon(Icons.check, size: 20),
                if (languageProvider.isEnglish)
                  const SizedBox(width: 8),
                Text(l10n.english),
              ],
            ),
          ),
        ];
      },
    );
  }
}
