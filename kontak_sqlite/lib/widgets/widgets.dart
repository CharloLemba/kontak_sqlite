import 'package:flutter/material.dart';

class BottomActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const BottomActionButtons({
    super.key,
    required this.onSave,
    required this.onDelete,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            // ------------------
            // Tombol Simpan Data
            // ------------------
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save, size: 20),
                    SizedBox(height: 2),
                    Text('Simpan', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // -----------------
            // Tombol Hapus Data
            // -----------------
            Expanded(
              child: ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 20),
                    SizedBox(height: 2),
                    Text('Hapus', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // --------------
            // Tombol Telepon
            // --------------
            Expanded(
              child: ElevatedButton(
                onPressed: onCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 20),
                    SizedBox(height: 2),
                    Text('Telepon', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ----------------
            // Tombol Pesan/SMS
            // ----------------
            Expanded(
              child: ElevatedButton(
                onPressed: onMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.message, size: 20),
                    SizedBox(height: 2),
                    Text('Pesan', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
