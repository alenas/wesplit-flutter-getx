import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

void main() {
  runApp(const WeSplitApp());
}

class WeSplitApp extends StatelessWidget {
  const WeSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WeSplit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        cardTheme: CardThemeData(margin: EdgeInsets.all(8.0)),
      ),
      initialRoute: '/',
      getPages: [GetPage(name: '/', page: () => HomeView(), binding: BindingsBuilder.put(() => BillController()))],
    );
  }
}

class HomeView extends GetWidget<BillController> {
  HomeView({super.key});

  // MARK: - Properties
  final List<int> tipPercentages = [10, 15, 20, 25, 0];
  final checkAmount = 0.0.obs;
  final numberOfPeople = 2.obs;
  final tipPercentage = 20.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WeSplit'), centerTitle: true),
      body: Obx(
        () => ListView(
          children: [
            // Section 1: Amount and Number of People
            Card(
              child: Column(
                spacing: 16.0,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    onChanged: (value) {
                      checkAmount.value = double.tryParse(value) ?? 0.0;
                    },
                  ),
                  ListTile(
                    title: const Text('Number of people'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$numberOfPeople people', style: TextStyle(color: context.theme.colorScheme.secondary)),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () async {
                      final result = await Get.to<int>(NumberOfPeoplePicker(numberOfPeople.value));
                      if (result != null) {
                        numberOfPeople.value = result;
                      }
                    },
                  ),
                ],
              ).paddingAll(16.0),
            ),

            // Section 2: Tip Percentage
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.0,
                children: [
                  Text('How much do you want to tip?', style: context.theme.textTheme.titleSmall),
                  SegmentedButton<int>(
                    segments: [for (var percentage in tipPercentages) ButtonSegment(value: percentage, label: Text('$percentage%'))],
                    selected: {tipPercentage.value},
                    onSelectionChanged: (newSelection) {
                      tipPercentage.value = newSelection.first;
                    },
                  ),
                ],
              ).paddingAll(16.0),
            ),

            // Section 3: Total Per Person
            Card(
              child: Center(
                child: Text(
                  controller.totalPerPerson(numberOfPeople.value, tipPercentage.value, checkAmount.value),
                  style: context.theme.textTheme.headlineMedium,
                ),
              ).paddingAll(16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class BillController extends GetxController {
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(symbol: NumberFormat.simpleCurrency().currencySymbol, decimalDigits: 2);
    return format.format(amount);
  }

  String totalPerPerson(int numberOfPeople, int tipPercentage, double checkAmount) {
    final tipSelection = tipPercentage.toDouble();

    final tipValue = checkAmount / 100 * tipSelection;
    final grandTotal = checkAmount + tipValue;
    final amountPerPerson = grandTotal / numberOfPeople;

    return _formatCurrency(amountPerPerson);
  }
}

class NumberOfPeoplePicker extends StatelessWidget {
  final int initialValue;

  const NumberOfPeoplePicker(this.initialValue, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number of people')),
      body: ListView.builder(
        itemCount: 98,
        itemBuilder: (context, index) {
          final peopleCount = index + 2;
          final isSelected = index == (initialValue - 2);
          return ListTile(
            title: Text('$peopleCount people'),
            trailing: isSelected ? Icon(Icons.check, color: context.theme.colorScheme.primary) : null,
            selected: isSelected,
            onTap: () {
              Get.back(result: peopleCount);
            },
          );
        },
      ),
    );
  }
}
