import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();
    final favs = appState.favoriteParkIds; // you'll add getter below

    return Scaffold(
      appBar: AppBar(title:  const Text('Favorites')),
      body: favs.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView(
              children: favs.map((id) => ListTile(title: Text(id))).toList(),
            ),
    );
  }
}
