import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class CreateRunSuccessScreen extends StatelessWidget {
  const CreateRunSuccessScreen({
    super.key,
    required this.runClub,
    required this.run,
    required this.onManageRun,
    required this.onDone,
  });

  final RunClub runClub;
  final Run run;
  final VoidCallback onManageRun;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const successInk = Color(0xFF1A1410);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: CatchTokens.sunsetLight.heroGrad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconBtn(
                    background: successInk.withValues(alpha: 0.16),
                    onTap: onDone,
                    child: const Icon(Icons.close_rounded, color: successInk),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: successInk.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: successInk.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: successInk,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your run is live.',
                  style: CatchTextStyles.displayXL(
                    context,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${run.title} is now listed on ${runClub.name}. Followers can discover it from their home feed.',
                  style: CatchTextStyles.bodyL(context, color: Colors.white),
                ),
                const SizedBox(height: 20),
                CatchSurface(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: successInk.withValues(alpha: 0.14),
                  borderColor: successInk.withValues(alpha: 0.18),
                  radius: CatchRadius.lg,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: successInk,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bookings, waitlist, and attendance are tracked from Manage run.',
                          style: CatchTextStyles.bodyS(
                            context,
                            color: successInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CatchButton(
                  label: 'Manage run',
                  onPressed: onManageRun,
                  fullWidth: true,
                  backgroundColor: Colors.white,
                  foregroundColor: successInk,
                  borderColor: Colors.transparent,
                ),
                const SizedBox(height: 10),
                CatchButton(
                  label: 'Back to club',
                  onPressed: onDone,
                  variant: CatchButtonVariant.secondary,
                  fullWidth: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                  foregroundColor: successInk,
                  borderColor: successInk.withValues(alpha: 0.20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
