import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flick/core/utils/navigation_helper.dart';
import 'package:flick/features/playlists/screens/playlist_cover_crop_screen.dart';
import 'package:flick/l10n/l10n.dart';
import 'package:flick/models/playlist.dart';
import 'package:flick/providers/playlist_provider.dart';
import 'package:flick/widgets/common/flick_snackbar.dart';

/// Gallery picker + crop flow shared by the playlist list and detail menus.
class PlaylistCoverActions {
  PlaylistCoverActions._();

  static Future<bool> choose(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    String? croppedPath;
    var changed = false;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 92,
      );
      if (picked == null || !context.mounted) return false;

      croppedPath = await NavigationHelper.pushFade<String>(
        context,
        (_) => PlaylistCoverCropScreen(sourcePath: picked.path),
      );
      if (croppedPath == null) return false;

      final success = await ref
          .read(playlistsProvider.notifier)
          .setPlaylistCover(playlist.id, croppedPath);
      changed = success;
      messenger?.showFlickSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.playlistCoverUpdated
                : l10n.couldNotUpdatePlaylistCover,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      messenger?.showFlickSnackBar(
        SnackBar(
          content: Text(l10n.couldNotUpdatePlaylistCover),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (croppedPath != null) {
        try {
          final file = File(croppedPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // Temporary crop output; the OS will eventually clean it up.
        }
      }
    }

    return changed;
  }

  static Future<bool> remove(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final success = await ref
        .read(playlistsProvider.notifier)
        .removePlaylistCover(playlist.id);

    messenger?.showFlickSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.playlistCoverRemoved
              : l10n.couldNotUpdatePlaylistCover,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    return success;
  }
}
