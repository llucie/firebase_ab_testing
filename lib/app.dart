import 'package:firebase_ab_testing/app_controller.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  bool loading = false;
  int amount = 0;
  bool donationSent = false;

  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: '0')..addListener(amountChanged);
  }

  void amountChanged() {
    int newAmount = int.parse(amountController.text);
    if (amount != newAmount) {
      setState(() {
        amount = newAmount;
        donationSent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(retrieveFromRemoteConfig);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              amountController.text = '0';
              donationSent = false;
            }),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Center(
        child: state.when(
          data: ((amounts) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Faire un don', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: amounts
                        .map((remoteConfigAmount) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    amountController.text = remoteConfigAmount.toString();
                                    donationSent = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                child: Text(remoteConfigAmount.toString()),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: amountController,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  setState(() => loading = true);

                                  // Fake processing
                                  await Future.delayed(const Duration(milliseconds: 400));

                                  debugPrint(amount.toString());

                                  await FirebaseAnalytics.instance.logEvent(
                                    name: "select_content",
                                    parameters: {"amount": amount},
                                  );

                                  setState(() {
                                    loading = false;
                                    donationSent = true;
                                  });
                                },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          icon: Center(
                            child: loading
                                ? const CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                                  )
                                : const Icon(Icons.send, color: Colors.teal),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  if (donationSent)
                    Visibility(
                      visible: donationSent,
                      child: Column(
                        children: [
                          const Text('Thank you for your donation of '),
                          Text('$amount€'),
                        ],
                      ),
                    ),
                ],
              )),
          error: (error, _) => Text('Failed to load from RemoteConfig: ${error.toString()}'),
          loading: () => const CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}
