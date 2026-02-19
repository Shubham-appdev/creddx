import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCrypto = 'BTC/USDT';
  final List<String> _cryptoOptions = ['BTC/USDT', 'ETH/USDT', 'SOL/USDT', 'BNB/USDT'];
  
  List<CandleChartData> _chartData = [];
  Timer? _timer;
  double _currentPrice = 0.0;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInitialData();
    _startRealTimeUpdates();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchPrice(),
      _fetchKlines(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchPrice() async {
    try {
      final symbol = _selectedCrypto.replaceAll('/', '');
      final response = await http.get(Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=$symbol'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _currentPrice = double.parse(data['price'] ?? '0.0');
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching price: $e');
    }
  }

  Future<void> _fetchKlines() async {
    try {
      final symbol = _selectedCrypto.replaceAll('/', '');
      final response = await http.get(Uri.parse('https://api.binance.com/api/v3/klines?symbol=$symbol&interval=1h&limit=20'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _chartData = data.map((k) => CandleChartData(
              double.parse(k[1]), // open
              double.parse(k[2]), // high
              double.parse(k[3]), // low
              double.parse(k[4]), // close
              DateTime.fromMillisecondsSinceEpoch(k[0]),
            )).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching klines: $e');
    }
  }

  void _startRealTimeUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchPrice();
        _fetchKlines();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF84BD00)))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildWalletBalance(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 40),
                _buildMyAssets(),
                const SizedBox(height: 40),
                _buildMarketOverview(),
                const SizedBox(height: 40),
                _buildHistorySection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white), 
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationScreen()));
          }
        ),
        const SizedBox(width: 8),
        Container(
          width: 35, height: 35,
          decoration: const BoxDecoration(color: Color(0xFF1E1E20), shape: BoxShape.circle),
          child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWalletBalance() {
    return Center(
      child: Column(
        children: [
          Text('$_selectedCrypto Price', style: const TextStyle(color: Color(0xFF6C7278), fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(_currentPrice),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton('assets/images/send.png'),
          _buildActionButton('assets/images/request.png'),
          _buildActionButton('assets/images/withdraw.png'),
          _buildActionButton('assets/images/more.png'),
        ],
      ),
    );
  }

  Widget _buildActionButton(String path) {
    return GestureDetector(
      onTap: () {
        if (path.contains('more')) _showMoreOptions(context);
      },
      child: Image.asset(
        path,
        width: 72,
        height: 72,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: Colors.white, size: 72),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('More', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _moreOptionItem('Send', 'assets/images/send.png'),
                      _moreOptionItem('Request', 'assets/images/request.png'),
                      _moreOptionItem('Withdraw', 'assets/images/withdraw.png'),
                      _moreOptionItem('Add wallet', 'assets/images/addwallet.png'),
                      _moreOptionItem('Deposit', 'assets/images/deposit.png'),
                      _moreOptionItem('Edit Wallet', 'assets/images/editwallet.png'),
                      _moreOptionItem('Buy Crypto', 'assets/images/buycrpto.png'),
                      _moreOptionItem('Sell Crypto', 'assets/images/sellcrypto.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _moreOptionItem(String label, String assetPath) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          Image.asset(assetPath, width: 56, height: 56, errorBuilder: (c, e, s) => const Icon(Icons.help, color: Colors.white, size: 56)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildMyAssets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('My Assets', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24),
            children: [
              _assetCard('BTC Balance', '0.34545 BTC', '\$21,900.84', 'assets/images/btclogo.png', 'BTC'),
              _assetCard('ETH Balance', '12.345 ETH', '\$3,456.78', 'assets/images/eth.png', 'ETH'),
              _assetCard('USDT Balance', '45,678 USDT', '\$45,678.00', 'assets/images/usdt.png', 'USDT'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _assetCard(String title, String amt, String val, String assetPath, String symbol) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _buildCryptoLogo(assetPath, symbol),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF6C7278), fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
          const Spacer(),
          Text(amt, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(color: Color(0xFF6C7278), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCryptoLogo(String path, String symbol) {
    Color logoColor = _getSymbolColor(symbol);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor.withOpacity(0.4),
            logoColor.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: logoColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          path,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              symbol[0],
              style: TextStyle(
                color: logoColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getSymbolColor(String symbol) {
    if (symbol == 'BTC') return const Color(0xFFF7931A);
    if (symbol == 'ETH') return const Color(0xFF627EEA);
    if (symbol == 'USDT') return const Color(0xFF26A17B);
    return Colors.white;
  }

  Widget _buildMarketOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Market Overview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFF1E1E20), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCrypto,
                    dropdownColor: const Color(0xFF1E1E20),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: _cryptoOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedCrypto = v);
                        _fetchInitialData();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(color: const Color(0xFF1E1E20), borderRadius: BorderRadius.circular(20)),
            child: _chartData.isEmpty 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF84BD00)))
              : SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: DateTimeAxis(isVisible: false),
                  primaryYAxis: NumericAxis(isVisible: true, labelStyle: const TextStyle(color: Colors.white54, fontSize: 10), majorGridLines: const MajorGridLines(width: 0.1), numberFormat: NumberFormat.compact()),
                  series: <CandleSeries<CandleChartData, DateTime>>[
                    CandleSeries<CandleChartData, DateTime>(dataSource: _chartData, xValueMapper: (d, _) => d.time, lowValueMapper: (d, _) => d.low, highValueMapper: (d, _) => d.high, openValueMapper: (d, _) => d.open, closeValueMapper: (d, _) => d.close, bearColor: Colors.redAccent, bullColor: const Color(0xFF84BD00)),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exchange History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Center(child: Text('No history found', style: TextStyle(color: Color(0xFF6C7278)))),
        ],
      ),
    );
  }
}

class CandleChartData {
  final double open, high, low, close;
  final DateTime time;
  CandleChartData(this.open, this.high, this.low, this.close, this.time);
}
