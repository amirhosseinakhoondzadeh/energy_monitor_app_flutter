import 'package:energy_monitor_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:energy_monitor_app_flutter/features/home/presentation/bloc/home_bloc.dart';
import 'package:energy_monitor_app_flutter/features/home/domain/enums/metric_type.dart';

import 'home_page_widget_test.mocks.dart';

@GenerateMocks([HomeBloc])
void main() {
  late MockHomeBloc mockHomeBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();

    when(mockHomeBloc.state).thenReturn(HomeState());
    when(mockHomeBloc.stream).thenAnswer((_) => Stream.value(HomeState()));
  });

  Widget createTestableWidget(Widget child) {
    return BlocProvider<HomeBloc>.value(
      value: mockHomeBloc,
      child: MaterialApp(home: child),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('Displays AppBar, BottomNavigationBar, and FAB',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomePage()));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Toggles between Watts and Kilowatts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomePage()));

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Expect switch value to change
      expect((tester.widget<Switch>(switchFinder)).value, isTrue);
    });

    testWidgets('Switches tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomePage()));

      // Tap Battery Tab
      await tester.tap(find.text('Battery'));
      await tester.pumpAndSettle();

      verify(mockHomeBloc.add(MetricChangedEvent(MetricType.battery)))
          .called(1);
    });

    testWidgets('Opens DatePicker when FAB is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const HomePage()));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('Shows error Snackbar when in error state',
        (WidgetTester tester) async {
      when(mockHomeBloc.state).thenReturn(
        HomeState(
            status: HomeStateStatus.error, errorMessage: "Error fetching data"),
      );
      when(mockHomeBloc.stream).thenAnswer((_) => Stream.value(
            HomeState(
                status: HomeStateStatus.error,
                errorMessage: "Error fetching data"),
          ));

      await tester.pumpWidget(createTestableWidget(const HomePage()));
      await tester.pump();

      expect(find.text("Error fetching data"), findsOneWidget);
    });
  });
}
