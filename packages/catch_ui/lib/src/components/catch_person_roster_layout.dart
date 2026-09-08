import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_person_row_data.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchPersonRosterLayout extends StatelessWidget {
  const CatchPersonRosterLayout({super.key, required this.data});

  final CatchPersonRowData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.name,
          style: CatchTextStyles.sectionTitle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (data.metaLine != null) ...[
          gapH3,
          Text(
            data.metaLine!,
            style: CatchTextStyles.supporting(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (data.contextLine != null) ...[
          gapH2,
          Row(
            children: [
              Icon(
                CatchIcons.directionsRunRounded,
                size: CatchIcon.micro,
                color: CatchTokens.of(context).ink3,
              ),
              gapW3,
              Expanded(
                child: Text(
                  data.contextLine!,
                  style: CatchTextStyles.supporting(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
