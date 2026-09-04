import 'package:flutter/material.dart';
import 'package:organizer/app/theme/app_color.dart';

class ProjectSpeedDialItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ProjectSpeedDialItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class ProjectSpeedDial extends StatefulWidget {
  final List<ProjectSpeedDialItem> items;

  const ProjectSpeedDial({super.key, required this.items});

  @override
  State<ProjectSpeedDial> createState() => _ProjectSpeedDialState();
}

class _ProjectSpeedDialState extends State<ProjectSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );
  bool _isOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen)
          ScaleTransition(
            scale: _animation,
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.border),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 8),
                          ],
                        ),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton.small(
                        heroTag: 'project-${item.label}',
                        onPressed: item.onTap,
                        backgroundColor: item.color,
                        child: Icon(item.icon, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: _isOpen ? AppColor.surfaceAlt : AppColor.primary,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              Icons.add_rounded,
              color: _isOpen ? AppColor.primarySoft : Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}
