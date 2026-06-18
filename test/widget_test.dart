import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:local_reader/main.dart';

void main() {
  testWidgets('App launches and shows bookshelf', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppSettings(),
        child: const LocalReaderApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('我的书架'), findsOneWidget);
    expect(find.text('书架空空如也'), findsOneWidget);
  });
}
