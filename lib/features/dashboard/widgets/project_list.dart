import 'package:flutter/material.dart';
import 'package:organizer/core/database/database_service.dart';
import 'empty_project_state.dart';
import 'project_card.dart';

class ProjectList extends StatelessWidget {
  final int filter;

  const ProjectList({super.key, this.filter = 0});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: DatabaseService.instance.projectsListenable,
      builder: (context, box, _) {
        var projects = DatabaseService.instance.getProjects();

        if (filter == 1) {
          projects.sort((a, b) => _recentScore(b.updated).compareTo(_recentScore(a.updated)));
        } else if (filter == 2) {
          projects = projects.where((project) => project.isFavorite).toList();
        }

        if (projects.isEmpty) {
          return EmptyProjectState(onCreateProject: () {});
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 20),
          itemCount: projects.length,
          itemBuilder: (_, index) {
            final project = projects[index];

            return ProjectCard(
              project: project,
            );
          },
        );
      },
    );
  }

  int _recentScore(String updated) {
    final value = updated.toLowerCase();
    if (value.contains('just now')) return 0;
    if (value.contains('second')) return 1;
    if (value.contains('minute')) return 2;
    if (value.contains('hour') || value.contains('h ago')) return 3;
    if (value.contains('today')) return 4;
    if (value.contains('yesterday')) return 5;
    if (value.contains('day')) return 6;
    if (value.contains('week')) return 7;
    return 8;
  }
}