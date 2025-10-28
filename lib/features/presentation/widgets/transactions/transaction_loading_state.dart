import 'package:flutter/material.dart';

class TransactionLoadingState extends StatelessWidget {
  const TransactionLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9747FF)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading transactions...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}