import 'package:flutter/material.dart';
import 'api_client.dart';

class ColdStartNotice extends StatelessWidget {
  const ColdStartNotice({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: ApiClient.coldStart,
          builder: (context, active, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (active) ...[
                const SizedBox(height: 16),
                Text('Free tier is waking up…', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text('Please wait up to a minute.', style: TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
      );
}
