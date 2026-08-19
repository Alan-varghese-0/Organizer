import 'package:flutter_test/flutter_test.dart';

import 'package:organizer/app/app.dart';

void main() {
  testWidgets('Organizer app boots into the splash screen', (tester) async {
    await tester.pumpWidget(const OrganizerApp());

    expect(find.text('Organizer'), findsOneWidget);
    expect(find.text('your creative workspace'), findsOneWidget);
  });
}
