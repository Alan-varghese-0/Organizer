import 'package:flutter/material.dart';
import 'package:organizer/core/database/database_service.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/app/theme/app_text_style.dart';
import 'package:organizer/app/theme/theme_notifier.dart';
import 'package:organizer/features/bottom_navigaion/presentation/screens/main_navigation_screen.dart';
import 'package:organizer/features/create_workspace/widgets/personality_card.dart';

class WorkspaceSetupScreen extends StatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  State<WorkspaceSetupScreen> createState() => _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends State<WorkspaceSetupScreen> {
  final TextEditingController workspaceController = TextEditingController(
    text: "My Workspace",
  );


  int selectedPersonality = 0;

  final personalities = [
    (
      title: "Ocean",
      colors: [
        const Color(0xff2563EB),
        const Color(0xff38BDF8),
        const Color(0xffF8FAFC),
        const Color(0xff1D4ED8),
      ],
    ),
    (
      title: "Forest",
      colors: [
        const Color(0xff15803D),
        const Color(0xff22C55E),
        const Color(0xffF8FAFC),
        const Color(0xff166534),
      ],
    ),
    (
      title: "Sunset",
      colors: [
        const Color(0xffF97316),
        const Color(0xffFDBA74),
        const Color(0xffFFF7ED),
        const Color(0xffEA580C),
      ],
    ),
    (
      title: "Aurora",
      colors: [
        const Color(0xff7C3AED),
        const Color(0xffA855F7),
        const Color(0xffFAF5FF),
        const Color(0xff6D28D9),
      ],
    ),
    (
      title: "Noir",
      colors: [
        const Color(0xff111827),
        const Color(0xff374151),
        const Color(0xffF9FAFB),
        const Color(0xff000000),
      ],
    ),
  ];

  @override
  void dispose() {
    workspaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Workspace",
                style: AppTextStyle.display.copyWith(color: AppColor.primary),
              ),

              const SizedBox(height: 8),

              Text(
                "Personalize Organizer before you begin.",
                style: AppTextStyle.title.copyWith(color: AppColor.primary),
              ),

              const SizedBox(height: 35),

              Text(
                "Workspace Name",
                style: AppTextStyle.title.copyWith(color: AppColor.primary),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: workspaceController,
                style: AppTextStyle.body.copyWith(color: AppColor.scaffold),
                decoration: InputDecoration(
                  hintText: "My Workspace",
                  hintStyle: AppTextStyle.body.copyWith(
                    color: AppColor.background,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),


              Text(
                "Workspace Personality",
                style: AppTextStyle.title.copyWith(color: AppColor.primary),
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(personalities.length, (index) {
                  final item = personalities[index];

                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: PersonalityCard(
                      title: item.title,
                      colors: item.colors,
                      selected: selectedPersonality == index,
                      onTap: () {
                        setState(() {
                          selectedPersonality = index;
                        });
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 35),


              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    // Save selected workspace name and personality to settings
                    await DatabaseService.instance.updateSetting('workspaceName', workspaceController.text.trim());
                    await DatabaseService.instance.updateSetting('personality', personalities[selectedPersonality].title);

                    // Update global notifier so theme applies immediately
                    personalityNotifier.value = personalities[selectedPersonality].title;

                    await DatabaseService.instance.completeOnboarding();

                    if (!mounted) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Create Workspace",
                    style: AppTextStyle.title.copyWith(
                      color: AppColor.background,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
