  void _toggleDemoMode() {
    setState(() {
      _isDemoMode = !_isDemoMode;
    });
    
    if (_isDemoMode) {
      DemoPaymentService.startDemo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo mode started - Payments will appear every 15 seconds'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      DemoPaymentService.stopDemo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo mode stopped'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }