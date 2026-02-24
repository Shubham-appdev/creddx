import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'notification_screen.dart';
import 'send_screen.dart';
import 'receive_screen.dart';
import 'withdraw_screen.dart';
import 'deposit_screen.dart'; // Import the new DepositScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTab = 'Exchange History';
  final List<String> _tabs = ['Exchange History', 'Transaction History'];
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  // Mock wallet data
  final String _walletAddress = '0×2340....3420';
  final double _totalBalance = 227169.85;

  // Crypto holdings
  final List<Map<String, dynamic>> _cryptoHoldings = [
    {
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'amount': 0.34545,
      'usdValue': 21900.84,
      'icon': 'btc.png',
    },
    {
      'symbol': 'ETH',
      'name': 'Ethereum',
      'amount': 12345.0,
      'usdValue': 37870.88,
      'icon': 'eth.png',
    },
  ];

  // Exchange history data
  final List<Map<String, dynamic>> _exchangeHistory = [
    {
      'from': 'BTC',
      'to': 'ETH',
      'fromAmount': '0.342 BTC',
      'toAmount': '6,21 ETH',
      'txId': '#12123TRA',
      'time': '2024-01-15 14:30',
      'fromIcon': 'btc.png',
      'toIcon': 'eth.png',
    },
    {
      'from': 'ETH',
      'to': 'BTC',
      'fromAmount': '12.5 ETH',
      'toAmount': '0.456 BTC',
      'txId': '#12124TRA',
      'time': '2024-01-14 09:15',
      'fromIcon': 'eth.png',
      'toIcon': 'btc.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBalanceSection(),
            _buildActionButtons(),
            _buildTabSection(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 26),
                onPressed: () {
                  // Search functionality
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Wallet Balance',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$227.169,85',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/wallet.png',
                width: 16,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _walletAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _walletAddress));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final actions = [
      {'icon': 'send.png', 'label': 'Send'},
      {'icon': 'request.png', 'label': 'Request'},
      {'icon': 'deposit.png', 'label': 'Deposit'},
      {'icon': 'more.png', 'label': 'More'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return GestureDetector(
            onTap: () => _handleActionTap(action['label'] as String),
            child: SizedBox(
              width: 70, // Increased to accommodate larger icons
              height: 70,
              child: Center(
                child: Image.asset(
                  'assets/images/${action['icon']}',
                  width: 56, // Increased from 48 to 56
                  height: 56,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.help_outline,
                    color: Color(0xFF84BD00),
                    size: 56,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = tab == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF84BD00) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'Exchange History':
        return _buildExchangeHistory();
      case 'Transaction History':
        return _buildTransactionHistory();
      default:
        return _buildExchangeHistory();
    }
  }

  Widget _buildExchangeHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _exchangeHistory.map((tx) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                // Double icon with PNG images
                SizedBox(
                  width: 52,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: _buildCryptoIcon(tx['fromIcon'] as String, 32),
                      ),
                      Positioned(
                        left: 18,
                        top: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0D0D0D),
                              width: 2,
                            ),
                          ),
                          child: _buildCryptoIcon(tx['toIcon'] as String, 28),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['txId'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx['time'] as String,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx['fromAmount'] as String,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx['toAmount'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _cryptoHoldings.map((crypto) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: crypto['symbol'] == 'BTC' 
                          ? const Color(0xFFF7931A).withOpacity(0.2)
                          : const Color(0xFF627EEA).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      crypto['symbol'][0],
                      style: TextStyle(
                        color: crypto['symbol'] == 'BTC' 
                              ? const Color(0xFFF7931A)
                              : const Color(0xFF627EEA),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  crypto['symbol'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatNumber(crypto['amount'] as double),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(crypto['usdValue'] as double),
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCryptoIcon(String iconName, double size) {
    return Image.asset(
      'assets/images/$iconName',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: iconName.contains('btc')
                ? const Color(0xFFF7931A).withOpacity(0.2)
                : const Color(0xFF627EEA).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            iconName.contains('btc') ? 'B' : 'E',
            style: TextStyle(
              color: iconName.contains('btc')
                  ? const Color(0xFFF7931A)
                  : const Color(0xFF627EEA),
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return NumberFormat('#,###').format(number);
    }
    return number.toString();
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(value);
  }

  void _handleActionTap(String action) {
    switch (action) {
      case 'Send':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SendScreen()),
        );
        break;
      case 'Request':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ReceiveScreen()),
        );
        break;
      case 'Deposit':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DepositScreen()),
        );
        break;
      case 'More':
        _showMoreOptions(context);
        break;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'More Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _moreOptionItem('Withdraw', 'withdraw.png'),
                  _moreOptionItem('History', 'chart.png'),
                  _moreOptionItem('Settings', 'more.png'),
                  _moreOptionItem('Help', 'key.png'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreOptionItem(String label, String assetPath) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        if (label == 'Withdraw') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WithdrawScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label coming soon!')),
          );
        }
      },
      child: Center(
        child: Image.asset(
          'assets/images/$assetPath',
          width: 56, // Increased from 48 to 56
          height: 56,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.help_outline,
            color: Color(0xFF84BD00),
            size: 56,
          ),
        ),
      ),
    );
  }
}
