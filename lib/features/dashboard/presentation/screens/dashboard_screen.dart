import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';
import 'package:organizer/features/dashboard/widgets/dashboard_appbar.dart';
import 'package:organizer/features/dashboard/widgets/new_project_button.dart';
import 'package:organizer/features/dashboard/widgets/project_filters.dart';
import 'package:organizer/features/dashboard/widgets/project_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,

      //      bottomNavigationBar: const AppBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardAppBar(workspaceName: "My Workspace"),

            const SizedBox(height: 10),

            NewProjectButton(
              onTap: () {
                // TODO:
                // Create Project
              },
            ),

            const SizedBox(height: 24),

            ProjectFilter(
              selected: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Expanded(child: ProjectList()),
          ],
        ),
      ),
    );
  }
}
