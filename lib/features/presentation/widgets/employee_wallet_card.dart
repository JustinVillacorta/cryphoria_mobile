import 'package:flutter/material.dart';

class EmployeeWalletCardWidget extends StatefulWidget {
  final String balance;
  final String convertedBalance;
  final bool isTablet;
  final VoidCallback? onRefreshBalance;
  final VoidCallback? onSwitchWallet;
  final VoidCallback? onDisconnectWallet;
  final Function(String)? onCurrencyChanged;

  const EmployeeWalletCardWidget({
    Key? key,
    required this.balance,
    required this.convertedBalance,
    this.isTablet = false,
    this.onRefreshBalance,
    this.onSwitchWallet,
    this.onDisconnectWallet,
    this.onCurrencyChanged,
  }) : super(key: key);

  @override
  State<EmployeeWalletCardWidget> createState() =>
      _EmployeeWalletCardWidgetState();
}

class _EmployeeWalletCardWidgetState extends State<EmployeeWalletCardWidget> {
  String selectedCurrency = 'PHP';
  final List<String> currencies = ['PHP', 'USD'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: widget.isTablet ? 500 : double.infinity,
      ),
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenWidth * 0.03,
        screenWidth * 0.05,
        screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5FBF),
            Color(0xFF6B46C1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Wallet',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: widget.isTablet ? 16 : screenWidth * 0.035,
                ),
              ),
              const Spacer(), // pushes menu to the end
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'refresh':
                      widget.onRefreshBalance?.call();
                      break;
                    case 'switch':
                      widget.onSwitchWallet?.call();
                      break;
                    case 'disconnect':
                      widget.onDisconnectWallet?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.black87),
                        SizedBox(width: 12),
                        Text('Refresh Balance'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'switch',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, color: Colors.black87),
                        SizedBox(width: 12),
                        Text('Switch Wallet'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'disconnect',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Disconnect Wallet',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Metamask',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isTablet ? 18 : screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.001,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '0x23ab...98fd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isTablet ? 18 : screenWidth * 0.04,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(width: screenWidth * 0.015),
                GestureDetector(
                  onTap: () {
                    // Clipboard functionality can be added here
                    print('Copying wallet address...');
                  },
                  child: Icon(
                    Icons.copy,
                    color: Colors.white.withOpacity(0.8),
                    size: widget.isTablet ? 16 : screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            widget.balance,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isTablet ? 36 : screenWidth * 0.08,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Converted to $selectedCurrency',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: widget.isTablet ? 12 : screenWidth * 0.03,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.convertedBalance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isTablet ? 16 : screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Currency Dropdown
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 16,
                  ),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isTablet ? 12 : screenWidth * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCurrency = newValue;
                      });
                      widget.onCurrencyChanged?.call(newValue);
                    }
                  },
                  items:
                  currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
