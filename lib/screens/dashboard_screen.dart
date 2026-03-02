import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_screen.dart';
import 'send_screen.dart';
import 'receive_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'inr_deposit_screen.dart';
import 'inr_withdraw_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTab = 'Exchange History';
  final List<String> _tabs = ['Exchange History', 'Transaction History'];
  final String _walletAddress = '0x1234...5678';

  final List<Map<String, dynamic>> _cryptoHoldings = [
    {'symbol': 'BTC', 'name': 'Bitcoin', 'amount': '0.5234', 'value': '\$24,560.12', 'change': '+2.5%'},
    {'symbol': 'ETH', 'name': 'Ethereum', 'amount': '12.5', 'value': '\$32,120.45', 'change': '-1.2%'},
  ];

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildBalanceSection(),
              _buildActionButtons(),
              _buildTabSection(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: _buildContent(),
              ),
            ],
          ),
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
                onPressed: () {},
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
        const Text(
          '\$227.169,85',
          style: TextStyle(
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
    final row1 = [
      {'icon': 'send.png', 'label': 'Send'},
      {'icon': 'withdraw.png', 'label': 'Request'},
      {'icon': 'deposit.png', 'label': 'Deposit'},
      {'icon': 'inrdeposit.png', 'label': 'INR Deposit'},
    ];
    final row2 = [
      {'icon': 'inrwithdraw.png', 'label': 'INR Withdraw'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row1.map((action) => _buildActionItem(action)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row2.map((action) => _buildActionItem(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(Map<String, String> action) {
    bool isINRDeposit = action['label'] == 'INR Deposit';
    bool isINRWithdraw = action['label'] == 'INR Withdraw';
    double iconSize = (isINRDeposit || isINRWithdraw) ? 40 : 56;
    
    return GestureDetector(
      onTap: () => _handleActionTap(action['label'] as String),
      child: SizedBox(
        width: 85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/${action['icon']}',
              width: iconSize,
              height: iconSize,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.help_outline,
                color: const Color(0xFF84BD00),
                size: iconSize,
              ),
            ),
            if (isINRDeposit) ...[
              const SizedBox(height: 4),
              const Text(
                'INRDeposit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDCE4E8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (isINRWithdraw) ...[
              const SizedBox(height: 4),
              const Text(
                'Withdraw INR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDCE4E8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleActionTap(String label) {
    switch (label) {
      case 'Send':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SendScreen()));
        break;
      case 'Request':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReceiveScreen()));
        break;
      case 'Deposit':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DepositScreen()));
        break;
      case 'INR Deposit':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InrDepositScreen()));
        break;
      case 'INR Withdraw':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InrWithdrawScreen()));
        break;
    }
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crypto['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        crypto['symbol'] as String,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      crypto['value'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      crypto['change'] as String,
                      style: TextStyle(
                        color: (crypto['change'] as String).startsWith('+') 
                              ? const Color(0xFF00C853) 
                              : const Color(0xFFE74C3C),
                        fontSize: 13,
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

  Widget _buildCryptoIcon(String assetName, double size) {
    return Image.asset(
      'assets/images/$assetName',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.circle,
        color: const Color(0xFF84BD00),
        size: size,
      ),
    );
  }
}
