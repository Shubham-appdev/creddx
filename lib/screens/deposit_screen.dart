import 'package:flutter/material.dart';
import 'deposit_address_screen.dart';
import '../services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String _selectedCoin = 'BTC';
  String _selectedNetwork = 'Bitcoin (BTC)';
  List<Coin> _coins = [];
  List<Network> _networks = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _fetchCoins();
  }
  
  Future<void> _fetchCoins() async {
    final coinsData = await WalletService.getAllCoins();
    
    if (mounted) {
      setState(() {
        _coins = coinsData.map((data) => Coin.fromJson(data)).toList();
        
        if (_coins.isNotEmpty) {
          _selectedCoin = _coins.first.symbol;
          _networks = _coins.first.networks;
          
          if (_networks.isNotEmpty) {
            _selectedNetwork = _networks.first.name;
          }
        }
        _isLoading = false;
      });
    }
  }
  
  void _onCoinChanged(String coinSymbol) {
    setState(() {
      _selectedCoin = coinSymbol;
      final selectedCoin = _coins.firstWhere((coin) => coin.symbol == coinSymbol);
      _networks = selectedCoin.networks;
      
      if (_networks.isNotEmpty) {
        _selectedNetwork = _networks.first.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Deposit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF84BD00)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Coin',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C2C2E)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButton<String>(
                      value: _selectedCoin,
                      dropdownColor: const Color(0xFF1C1C1E),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _coins.map((coin) => DropdownMenuItem(
                        value: coin.symbol,
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF84BD00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  coin.symbol.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF84BD00),
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    coin.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    coin.symbol,
                                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _onCoinChanged(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Network',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C2C2E)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButton<String>(
                      value: _selectedNetwork,
                      dropdownColor: const Color(0xFF1C1C1E),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _networks.where((network) => network.isActive).map((network) => DropdownMenuItem(
                        value: network.name,
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF84BD00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.network_check,
                                color: Color(0xFF84BD00),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    network.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    network.type,
                                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedNetwork = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DepositAddressScreen(
                            coin: _selectedCoin,
                            network: _selectedNetwork,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF84BD00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Deposit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
      ),
    );
  }

}
