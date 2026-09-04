import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class EmptyProjectState extends StatelessWidget {
  final VoidCallback onCreateProject;

  const EmptyProjectState({super.key, required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 42,
                color: AppColor.primary,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "No Projects Yet",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              "Create your first project to start organizing\nimages, PDFs, links, notes and more.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: 220,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onCreateProject,
                icon: const Icon(Icons.add),
                label: const Text("Create Project"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
