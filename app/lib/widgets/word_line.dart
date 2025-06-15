import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;

import '../services/database.dart';

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

  Widget buildAlreadyRememberIcon() {
    return CupertinoButton(
        padding: EdgeInsets.zero,
        child: Tooltip(
          message: 'Mark as remembered',
          child: const Icon(
            CupertinoIcons.checkmark_circle,
            color: CupertinoColors.activeGreen,
          ),
        ),
        onPressed: () {
          setState(() {
            _memoryLevel = 1;
          });
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
                    CupertinoIcons.multiply_circle,
                    color: CupertinoColors.activeOrange,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _memoryLevel = -1;
                  });
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
              // TODO: Handle tap
              print('tapped');
            },
            child: Text(
              widget.word,
              style: TextStyle(
                color: _memoryLevel > 0
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.label,
              ),
            ),
          ),
          trailing: buildTailButton(),
          // onTap: () {
          //   // TODO: Handle tap
          //   print('tapped');
          // },
        ),
      ),
    );
  }
}
