import 'package:flutter_test/flutter_test.dart';
import 'package:gp1_mvp/main.dart';

void main() {
  testWidgets('GoJobs smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GoJobsApp());
  });
}