// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:e_demand/data/model/serviceModel.dart';

class Cart {
  List<CartDetails>? cartDetails;
  String? carId;
  String? providerName;
  String? isAtDoorstepAvailable;
  String? isAtStoreAvailable;
  String? providerId;
  String? totalQuantity;
  String? subTotal;
  String? taxPercentage;
  String? taxAmount;
  String? overallAmount;
  String? total;
  String? promoCodeDiscountAmount;
  String? appliedPromoCodeName;
  String? isPayLaterAllowed;
  String? isOnlinePaymentAllowed;
  String? visitingCharges;
  String? advanceBookingDays;
  String? companyName;

  Cart({
    this.carId,
    this.cartDetails,
    this.providerName,
    this.providerId,
    this.totalQuantity,
    this.subTotal,
    this.taxPercentage,
    this.taxAmount,
    this.overallAmount,
    this.total,
    this.appliedPromoCodeName,
    this.promoCodeDiscountAmount,
    this.visitingCharges,
    this.advanceBookingDays,
    this.companyName,
    this.isPayLaterAllowed,
    this.isAtDoorstepAvailable,
    this.isAtStoreAvailable,
    this.isOnlinePaymentAllowed,
  });

  Cart.fromJson(final Map<String, dynamic> json) {
    if (json['data'] != null && json["data"] != "") {
      cartDetails = <CartDetails>[];
      json['data'].forEach((final v) {
        cartDetails!.add(CartDetails.fromJson(v));
      });
    }
    carId = json["cart_id"];
    isAtDoorstepAvailable = json["at_doorstep"];
    isAtStoreAvailable = json["at_store"];
    providerName = json['provider_names'];
    providerId = json['provider_id'];
    totalQuantity = json['total_quantity'];
    subTotal = json['sub_total'].toString();
    taxPercentage = json['tax_percentage'].toString();
    taxAmount = json['tax_amount'].toString();
    overallAmount = json['overall_amount'].toString();
    total = json['total'].toString();
    visitingCharges = json['visiting_charges'].toString();
    isPayLaterAllowed = json['is_pay_later_allowed'].toString();
    advanceBookingDays = json['advance_booking_days'].toString();
    companyName = json['company_name'].toString();
    isOnlinePaymentAllowed = json['is_online_payment_allowed'].toString();
  }
}

class CartDetails {
  String? id;
  String? serviceId;
  String? isSavedForLater;
  String? qty;
  Services? serviceDetails;

  CartDetails({
    this.id,
    this.serviceId,
    this.isSavedForLater,
    this.qty,
    this.serviceDetails,
  });

  CartDetails.fromJson(final Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    isSavedForLater = json['is_saved_for_later'];
    qty = json['qty'];
    serviceDetails =
        json['servic_details'] != null ? Services.fromJson(json['servic_details']) : null;
  }
}
