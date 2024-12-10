import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/foundation.dart';

class Booking {
  String? id;
  String? customer;
  String? customerId;
  String? customerNo;
  String? customerEmail;
  String? paymentMethod;
  String? paymentStatus;
  String? partner;
  String? profileImage;
  String? userId;
  String? partnerId;
  String? cityId;
  String? total;
  String? taxPercentage;
  String? taxAmount;
  String? promoCode;
  String? promoDiscount;
  String? finalTotal;
  String? adminEarnings;
  String? partnerEarnings;
  String? addressId;
  String? address;
  String? dateOfService;
  String? startingTime;
  String? endingTime;
  String? duration;
  String? status;
  String? providerAdvanceBookingDays;
  String? otp;
  List<dynamic>? workStartedProof;
  List<dynamic>? workCompletedProof;
  String? providerAddress;
  String? providerLatitude;
  String? providerLongitude;
  String? providerNumber;
  String? remarks;
  String? createdAt;
  String? companyName;
  String? visitingCharges;
  List<BookedService>? services;
  String? invoiceNo;
  String? isCancelable;
  String? newStartTimeWithDate;
  String? newEndTimeWithDate;
  String? isReorderAllowed;
  List<MultipleDayBookingData>? multipleDaysBooking;
  String? enquiryId;
  Key? key = UniqueKey();
  String? isPostBookingChatAllowed;

  Booking({
    this.id,
    this.key,
    this.customer,
    this.customerId,
    this.customerNo,
    this.customerEmail,
    this.paymentMethod,
    this.paymentStatus,
    this.partner,
    this.profileImage,
    this.userId,
    this.partnerId,
    this.cityId,
    this.isCancelable,
    this.total,
    this.taxPercentage,
    this.taxAmount,
    this.promoCode,
    this.promoDiscount,
    this.finalTotal,
    this.adminEarnings,
    this.partnerEarnings,
    this.addressId,
    this.address,
    this.dateOfService,
    this.startingTime,
    this.endingTime,
    this.duration,
    this.status,
    this.otp,
    this.remarks,
    this.createdAt,
    this.companyName,
    this.visitingCharges,
    this.services,
    this.invoiceNo,
    this.workCompletedProof,
    this.workStartedProof,
    this.multipleDaysBooking,
    this.newEndTimeWithDate,
    this.newStartTimeWithDate,
    this.providerNumber,
    this.providerAddress,
    this.providerLatitude,
    this.providerAdvanceBookingDays,
    this.providerLongitude,
    this.isReorderAllowed,
    this.enquiryId,
    this.isPostBookingChatAllowed,
  });

  Booking.fromJson(final Map<String, dynamic> json) {
    id = json["id"];
    customer = json["customer"];
    customerId = json["customer_id"];
    customerNo = json["customer_no"];
    customerEmail = json["customer_email"];
    paymentMethod = json["payment_method"];
    paymentStatus = json["payment_status"] ?? '';
    partner = json["partner"];
    profileImage = json["profile_image"];
    userId = json["user_id"];
    partnerId = json["partner_id"];
    cityId = json["city_id"];
    total = json["total"];
    taxPercentage = json["tax_percentage"];
    taxAmount = json["tax_amount"];
    promoCode = json["promo_code"];
    promoDiscount = json["promo_discount"];
    finalTotal = json["final_total"].toString();
    adminEarnings = json["admin_earnings"];
    partnerEarnings = json["partner_earnings"];
    addressId = json["address_id"];
    address = json["address"];
    dateOfService = json["date_of_service"];
    startingTime = json["starting_time"];
    endingTime = json["ending_time"];
    duration = json["duration"];
    status = json["status"];
    otp = json["otp"] != '' ? json["otp"] : '--';
    remarks = json["remarks"];
    createdAt = json["created_at"];
    companyName = json["company_name"];
    visitingCharges = json["visiting_charges"];
    workStartedProof = json["work_started_proof"];
    workCompletedProof = json["work_completed_proof"];
    isReorderAllowed = json["is_reorder_allowed"];
    providerAdvanceBookingDays = json["advance_booking_days"];
    invoiceNo = json["invoice_no"];
    isCancelable = json["is_cancelable"].toString();
    providerAddress = json["partner_address"];
    providerLatitude = json["partner_latitude"] != null && json["partner_latitude"] != ""
        ? json["partner_latitude"]
        : "0.0";
    providerLongitude = json["partner_longitude"] != null && json["partner_longitude"] != ""
        ? json["partner_longitude"]
        : "0.0";
    providerNumber = json["partner_no"];
    newStartTimeWithDate = json['new_start_time_with_date'] ?? '';
    newEndTimeWithDate = json['new_end_time_with_date'] ?? '';
    enquiryId = json['e_id'] ?? '0';
    isPostBookingChatAllowed = json['post_booking_chat'] ?? '0';

    if (json["services"] != null) {
      services = <BookedService>[];
      json["services"].forEach((final v) {
        services!.add(BookedService.fromJson(v));
      });
    }
    if (json["multiple_days_booking"] != null) {
      multipleDaysBooking = <MultipleDayBookingData>[];
      json["multiple_days_booking"].forEach((final v) {
        multipleDaysBooking!.add(MultipleDayBookingData.fromJson(v));
      });
    }
  }
}

class MultipleDayBookingData {
  MultipleDayBookingData({
    this.multipleDayDateOfService,
    this.multipleDayStartingTime,
    this.multipleEndingTime,
  });

  MultipleDayBookingData.fromJson(final Map<String, dynamic> json) {
    multipleDayDateOfService = json['multiple_day_date_of_service'] ?? '';
    multipleDayStartingTime = json['multiple_day_starting_time'] ?? '';
    multipleEndingTime = json['multiple_ending_time'] ?? '';
  }

  String? multipleDayDateOfService;
  String? multipleDayStartingTime;
  String? multipleEndingTime;
}

class BookedService {
  BookedService({
    this.id,
    this.orderId,
    this.serviceId,
    this.serviceTitle,
    this.taxPercentage,
    this.taxAmount,
    this.price,
    this.originalPriceWithTax,
    this.discountPrice,
    this.priceWithTax,
    this.quantity,
    this.subTotal,
    this.status,
    this.tags,
    this.duration,
    this.categoryId,
    this.rating,
    this.comment,
    this.image,
    this.reviewImages,
  });

  BookedService copyWith({
    String? id,
    String? orderId,
    String? serviceId,
    String? serviceTitle,
    String? taxPercentage,
    String? discountPrice,
    String? taxAmount,
    String? price,
    String? quantity,
    String? subTotal,
    String? status,
    String? tags,
    String? duration,
    String? categoryId,
    String? isCancelable,
    String? cancelableTill,
    String? title,
    String? taxType,
    String? taxId,
    String? image,
    String? rating,
    String? comment,
    String? images,
    String? priceWithTax,
    String? taxValue,
    String? originalPriceWithTax,
    List<String>? reviewImages,
  }) =>
      BookedService(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        serviceId: serviceId ?? this.serviceId,
        serviceTitle: serviceTitle ?? this.serviceTitle,
        taxPercentage: taxPercentage ?? this.taxPercentage,
        discountPrice: discountPrice ?? this.discountPrice,
        taxAmount: taxAmount ?? this.taxAmount,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        subTotal: subTotal ?? this.subTotal,
        status: status ?? this.status,
        tags: tags ?? this.tags,
        duration: duration ?? this.duration,
        categoryId: categoryId ?? this.categoryId,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        image: images ?? this.image,
        priceWithTax: priceWithTax ?? this.priceWithTax,
        originalPriceWithTax: originalPriceWithTax ?? this.originalPriceWithTax,
        reviewImages: reviewImages ?? this.reviewImages,
      );

  BookedService.fromJson(final Map<String, dynamic> json) {
    id = json["id"];
    orderId = json["order_id"];
    serviceId = json["service_id"];
    serviceTitle = json["service_title"];
    taxPercentage = json["tax_percentage"];
    taxAmount = json["tax_amount"];
    price = json["price"];
    discountPrice = json["discount_price"];
    priceWithTax = json["price_with_tax"];
    originalPriceWithTax = json["original_price_with_tax"];
    quantity = json["quantity"];
    subTotal = json["sub_total"];
    status = json["status"];
    tags = json["tags"];
    duration = json["duration"];
    categoryId = json["category_id"];
    rating = json["rating"] != "" ? json["rating"] : "0";
    comment = json["comment"];
    image = json["image"];
    reviewImages =
        (json["images"]?.isNotEmpty ?? false) ? (json["images"] as List).cast<String>() : [];
  }

  String? id;
  String? orderId;
  String? serviceId;
  String? serviceTitle;
  String? taxPercentage;
  String? taxAmount;
  String? discountPrice;
  String? price;
  String? originalPriceWithTax;
  String? priceWithTax;
  String? quantity;
  String? subTotal;
  String? status;
  String? tags;
  String? duration;
  String? categoryId;
  String? rating;
  String? comment;
  String? image;
  List<String>? reviewImages;
}
