import 'package:flutter/material.dart';

void main() {
  runApp(const PerfumeApp());
}

class PerfumeApp extends StatelessWidget {
  const PerfumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حسابداری و انبار عطر',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

// مدل‌های داده‌ای
class RawMaterial {
  String name;
  double stockGram;
  double pricePerGram;
  RawMaterial({required this.name, required this.stockGram, required this.pricePerGram});
}

class Accessory {
  String name;
  int stockCount;
  double pricePerUnit;
  Accessory({required this.name, required this.stockCount, required this.pricePerUnit});
}

class Invoice {
  String perfumeName;
  double finalPrice;
  double profit;
  DateTime date;
  Invoice({required this.perfumeName, required this.finalPrice, required this.profit, required this.date});
}

// صفحه اصلی و داشبورد
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // اطلاعات نمونه انبار
  final RawMaterial esans = RawMaterial(name: "اسانس فرانسوی", stockGram: 500, pricePerGram: 1500);
  final RawMaterial fixative = RawMaterial(name: "فیکساتور درجه یک", stockGram: 1000, pricePerGram: 400);
  final Accessory glass = Accessory(name: "شیشه ۱۰۰ میل", stockCount: 50, pricePerUnit: 25000);
  final Accessory label = Accessory(name: "لیبل چسبی", stockCount: 100, pricePerUnit: 2000);

  final List<Invoice> salesHistory = [];

  // کنترلر فرمولاسیون جدید
  final TextEditingController _perfumeNameController = TextEditingController();
  final TextEditingController _esansGramController = TextEditingController(text: "20");
  final TextEditingController _fixativeGramController = TextEditingController(text: "80");
  final TextEditingController _profitController = TextEditingController(text: "40");

  double lastCalculatedCost = 0;
  double lastCalculatedPrice = 0;
  double lastCalculatedProfit = 0;

  void _calculateAndSell() {
    double eGram = double.tryParse(_esansGramController.text) ?? 0;
    double fGram = double.tryParse(_fixativeGramController.text) ?? 0;
    double profitPercent = double.tryParse(_profitController.text) ?? 0;

    // بررسی موجودی انبار
    if (esans.stockGram < eGram || fixative.stockGram < fGram || glass.stockCount < 1 || label.stockCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا: موجودی انبار برای این تعداد کافی نیست!')),
      );
      return;
    }

    // محاسبات قیمت تمام‌شده
    double eCost = eGram * esans.pricePerGram;
    double fCost = fGram * fixative.pricePerGram;
    double totalCost = eCost + fCost + glass.pricePerUnit + label.pricePerUnit;
    double finalPrice = totalCost + (totalCost * (profitPercent / 100));
    double profitAmount = finalPrice - totalCost;

    setState(() {
      lastCalculatedCost = totalCost;
      lastCalculatedPrice = finalPrice;
      lastCalculatedProfit = profitAmount;

      // کسر از انبار
      esans.stockGram -= eGram;
      fixative.stockGram -= fGram;
      glass.stockCount -= 1;
      label.stockCount -= 1;

      // ثبت در فاکتورها
      salesHistory.add(Invoice(
        perfumeName: _perfumeNameController.text.isEmpty ? "عطر ترکیبی" : _perfumeNameController.text,
        finalPrice: finalPrice,
        profit: profitAmount,
        date: DateTime.now(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فروش ثبت و از انبار کسر شد!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = salesHistory.fold(0, (sum, item) => sum + item.finalPrice);
    double totalNetProfit = salesHistory.fold(0, (sum, item) => sum + item.profit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابداری و تولید عطر و ادکلن'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بخش داشبورد و آمار کلی
            const Text('داشبورد و آمار کلی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('کل فروش'),
                          const SizedBox(height: 5),
                          Text('${totalRevenue.toStringAsFixed(0)} ت', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('سود کل'),
                          const SizedBox(height: 5),
                          Text('${totalNetProfit.toStringAsFixed(0)} ت', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // موجودی انبار
            const Text('وضعیت انبار مواد اولیه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(title: Text(esans.name), trailing: Text('${esans.stockGram} گرم')),
                    ListTile(title: Text(fixative.name), trailing: Text('${fixative.stockGram} گرم')),
                    ListTile(title: Text(glass.name), trailing: Text('${glass.stockCount} عدد')),
                    ListTile(title: Text(label.name), trailing: Text('${label.stockCount} عدد')),
                  ],
                ),
              ),
            ),
            const Divider(height: 30),

            // فرمولاسیون و فروش عطر
            const Text('ساخت و فروش ادکلن (فرمول گرمی)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _perfumeNameController,
              decoration: const InputDecoration(labelText: 'نام یا کد عطر (مثلاً بلوچنل 01)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _esansGramController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'گرم اسانس', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fixativeGramController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'گرم فیکساتور', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _profitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'درصد سود دلخواه (%)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ).wrap(
                ElevatedButton(
                  onPressed: _calculateAndSell,
                  child: const Text('محاسبه قیمت و ثبت فروش / کسر از انبار'),
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (lastCalculatedPrice > 0)
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('بهای تمام‌شده مواد: ${lastCalculatedCost.toStringAsFixed(0)} تومان'),
                      Text('قیمت نهایی فروش: ${lastCalculatedPrice.toStringAsFixed(0)} تومان', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('سود این فروش: ${lastCalculatedProfit.toStringAsFixed(0)} تومان', style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              ),
            const Divider(height: 30),

            // دستیار هوشمند و هشدارها
            const Text('دستیار هوشمند', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  esans.stockGram < 100 
                    ? '⚠️ هشدار دستیار: موجودی اسانس کم است، به زودی باید خرید کنید.'
                    : '🤖 دستیار هوشمند: انبار در وضعیت مطلوبی قرار دارد. فروش این هفته عالی بوده است.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ButtonStyle {
  Widget wrap(Widget child) {
    return Builder(builder: (context) => TextButton(style: this, onPressed: () {}, child: child)); // helper for wrapper
  }
}
