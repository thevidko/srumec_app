import 'package:flutter/material.dart';

class AppUtils {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'active':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'ČEKÁ NA SCHVÁLENÍ';
      case 'approved':
      case 'active':
        return 'AKTIVNÍ';
      case 'rejected':
      case 'cancelled':
        return 'ZAMÍTNUTO';
      default:
        return status.toUpperCase();
    }
  }

  static String formatDateSimple(DateTime date) {
    final local = date.toLocal();
    return "${local.day}.${local.month}. • ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  static String formatDateTime(DateTime date) {
    final local = date.toLocal();
    return "${local.day}.${local.month}.${local.year} • ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}
