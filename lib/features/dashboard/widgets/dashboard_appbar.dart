import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget {
  final String workspaceName;

  const DashboardAppBar({super.key, required this.workspaceName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu_rounded)),

          Expanded(
            child: Column(
              children: [
                Text(
                  workspaceName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  "Welcome Back",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        ],
      ),
    );
  }
}
