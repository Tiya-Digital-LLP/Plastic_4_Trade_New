import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_tab_view/scrollable_tab_view.dart';

class TestFullScroll extends StatefulWidget {
  const TestFullScroll({super.key});

  @override
  State<TestFullScroll> createState() => _TestFullScrollState();
}

class _TestFullScrollState extends State<TestFullScroll>
    with TickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    // Initialize the TabController with a length of 5 and a vsync provided by this class
    controller = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the TabController when the state is disposed to free up resources
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scrollable Tab View'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // TitleWidget widget that displays a centered title
              const TitleWidget(
                title: 'ScrollableTab widget',
              ),
              // ScrollableTab widget that displays horizontal tabs and their content
              ScrollableTab(
                labelColor: Colors.black,
                onTap: (value) {
                  if (kDebugMode) {
                    print('index $value');
                  }
                },
                tabs: List.generate(
                    5,
                    (index) => Tab(
                          text: 'index $index',
                        )),
                children: List.generate(
                    5,
                    (index) => ListTile(
                          title: Center(
                            child: Text(
                              'tab Number $index',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(fontSize: 20.0 + (30 * index)),
                            ),
                          ),
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TitleWidget widget that displays a centered title
class TitleWidget extends StatelessWidget {
  final String title;
  const TitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
