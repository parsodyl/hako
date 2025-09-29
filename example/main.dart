import 'package:flutter/material.dart';
import 'package:hako/hako.dart';

void main() {
  runApp(
    HakoProvider(
      create: (_) => CounterHako(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // use watchHakoState to subscribe to the counter int state.
    final count = context.watchHakoState<CounterHako, int>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hako Example')),
      body: Center(
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // use getHako to access the container for method calls.
        onPressed: () => context.getHako<CounterHako>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterHako extends Hako {
  // register all initial state values in the constructor.
  CounterHako()
      : super((register) {
          register<int>(0);
        });

  // (optional) expose state with getters for convenient access.
  int get count => get<int>();

  // expose methods to modify the state.
  void increment() => set<int>((current) => current + 1);
}
