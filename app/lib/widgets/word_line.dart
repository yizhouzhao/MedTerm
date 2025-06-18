import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../services/database.dart';

// Global notification manager
class NotificationManager {
  static OverlayEntry? _currentNotification;
  static Timer? _timer;

  static void showNotification(BuildContext context, String message) {
    // Remove existing notification and timer
    _currentNotification?.remove();
    _timer?.cancel();

    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder:
          (ctx) => Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemPurple.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_bubble,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    _currentNotification = overlayEntry;
    overlay.insert(overlayEntry);

    _timer = Timer(const Duration(seconds: 2), () {
      overlayEntry.remove();
      if (_currentNotification == overlayEntry) {
        _currentNotification = null;
      }
    });
  }

  static void dispose() {
    _currentNotification?.remove();
    _timer?.cancel();
    _currentNotification = null;
    _timer = null;
  }
}

class WordLine extends StatefulWidget {
  final String word;
  final int memoryLevel;
  const WordLine({super.key, required this.word, required this.memoryLevel});

  @override
  State<WordLine> createState() => _WordLineState();
}

class _WordLineState extends State<WordLine> {
  late int _memoryLevel;
  final DatabaseService databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _memoryLevel = widget.memoryLevel;
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    super.dispose();
  }

  Widget buildAlreadyRememberIcon() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Tooltip(
        message: 'Mark as remembered',
        child: const Icon(
          CupertinoIcons.minus_circle,
          color: CupertinoColors.activeGreen,
        ),
      ),
      onPressed: () {
        setState(() {
          _memoryLevel = 1;
        });
        NotificationManager.showNotification(
          context,
          'Marked as already memorized',
        );
        databaseService.addUserWordMemory(widget.word, _memoryLevel);
      },
    );
  }

  Widget buildTailButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_memoryLevel == 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildAlreadyRememberIcon(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Tooltip(
                  message: 'Mark as don\'t remember',
                  child: const Icon(
                    CupertinoIcons.plus_circle,
                    color: CupertinoColors.activeOrange,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _memoryLevel = -1;
                  });
                  NotificationManager.showNotification(
                    context,
                    'Added to notebook',
                  );
                  databaseService.addUserWordMemory(widget.word, _memoryLevel);
                },
              ),
            ],
          )
        else if (_memoryLevel == 1)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Tooltip(
              message: 'Reset memory level',
              child: const Icon(
                CupertinoIcons.restart,
                color: CupertinoColors.destructiveRed,
              ),
            ),
            onPressed: () {
              setState(() {
                _memoryLevel = 0;
              });
              NotificationManager.showNotification(
                context,
                'Reset memory level',
              );
              databaseService.addUserWordMemory(widget.word, _memoryLevel);
            },
          )
        else // -1
          buildAlreadyRememberIcon(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoListTile.notched(
          title: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.push('/word/${widget.word}');
            },
            child: Text(
              widget.word,
              style: TextStyle(
                color:
                    _memoryLevel > 0
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.label,
              ),
            ),
          ),
          trailing: buildTailButton(),
        ),
      ),
    );
  }
}
