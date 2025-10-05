// lib/features/domain/entities/invoice.dart

class Invoice {
  final String invoiceId;
  final String userId;
  final String invoiceNumber;
  final String clientName;
  final String? clientEmail;
  final String? clientAddress;
  final String issueDate;
  final String dueDate;
  final String status;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final String? notes;
  final List<InvoiceItem> items;
  final String? createdAt;
  final String? updatedAt;

  // Crypto payment fields
  final String? cryptoPaymentAddress;
  final String? cryptoCurrency;
  final double? cryptoAmount;
  final String? sentAt;

  Invoice({
    required this.invoiceId,
    required this.userId,
    required this.invoiceNumber,
    required this.clientName,
    this.clientEmail,
    this.clientAddress,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    this.notes,
    required this.items,
    this.createdAt,
    this.updatedAt,
    this.cryptoPaymentAddress,
    this.cryptoCurrency,
    this.cryptoAmount,
    this.sentAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    List<InvoiceItem> parseItems(dynamic itemsData) {
      if (itemsData == null) return [];
      if (itemsData is! List) return [];
      return itemsData
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Invoice(
      invoiceId: json['invoice_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? '',
      clientEmail: json['client_email']?.toString(),
      clientAddress: json['client_address']?.toString(),
      issueDate: json['issue_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subtotal: toDouble(json['subtotal']),
      taxRate: toDouble(json['tax_rate']),
      taxAmount: toDouble(json['tax_amount']),
      totalAmount: toDouble(json['total_amount']),
      currency: json['currency']?.toString() ?? 'USD',
      notes: json['notes']?.toString(),
      items: parseItems(json['items']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      cryptoPaymentAddress: json['crypto_payment_address']?.toString(),
      cryptoCurrency: json['crypto_currency']?.toString(),
      cryptoAmount: toDouble(json['crypto_amount']),
      sentAt: json['sent_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "invoice_id": invoiceId,
    "user_id": userId,
    "invoice_number": invoiceNumber,
    "client_name": clientName,
    "client_email": clientEmail,
    "client_address": clientAddress,
    "issue_date": issueDate,
    "due_date": dueDate,
    "status": status,
    "subtotal": subtotal,
    "tax_rate": taxRate,
    "tax_amount": taxAmount,
    "total_amount": totalAmount,
    "currency": currency,
    "notes": notes,
    "items": items.map((item) => item.toJson()).toList(),
    "created_at": createdAt,
    "updated_at": updatedAt,
    "crypto_payment_address": cryptoPaymentAddress,
    "crypto_currency": cryptoCurrency,
    "crypto_amount": cryptoAmount,
    "sent_at": sentAt,
  };

  Invoice toEntity() {
    return Invoice(
      invoiceId: invoiceId,
      userId: userId,
      invoiceNumber: invoiceNumber,
      clientName: clientName,
      clientEmail: clientEmail,
      clientAddress: clientAddress,
      issueDate: issueDate,
      dueDate: dueDate,
      status: status,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      currency: currency,
      notes: notes,
      items: items,
      createdAt: createdAt,
      updatedAt: updatedAt,
      cryptoPaymentAddress: cryptoPaymentAddress,
      cryptoCurrency: cryptoCurrency,
      cryptoAmount: cryptoAmount,
      sentAt: sentAt,
    );
  }

  Invoice copyWith({
    String? invoiceId,
    String? userId,
    String? invoiceNumber,
    String? clientName,
    String? clientEmail,
    String? clientAddress,
    String? issueDate,
    String? dueDate,
    String? status,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    String? notes,
    List<InvoiceItem>? items,
    String? createdAt,
    String? updatedAt,
    String? cryptoPaymentAddress,
    String? cryptoCurrency,
    double? cryptoAmount,
    String? sentAt,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      userId: userId ?? this.userId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cryptoPaymentAddress: cryptoPaymentAddress ?? this.cryptoPaymentAddress,
      cryptoCurrency: cryptoCurrency ?? this.cryptoCurrency,
      cryptoAmount: cryptoAmount ?? this.cryptoAmount,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}

// Invoice Item entity
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double taxAmount;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.taxAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return InvoiceItem(
      description: json['description']?.toString() ?? '',
      quantity: toInt(json['quantity']),
      unitPrice: toDouble(json['unit_price']),
      totalPrice: toDouble(json['total_price']),
      taxAmount: toDouble(json['tax_amount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total_price': totalPrice,
  };

  InvoiceItem copyWith({
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      taxAmount: taxAmount,
    );

  }
}