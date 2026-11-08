import 'package:flutter/material.dart';

enum WeddingType { traditional, royal, modern, garden, destination, beach }
enum VenueType { indoor, outdoor, both }
enum RSVPStatus { invited, pending, confirmed, declined }
enum TaskPriority { low, medium, high }
enum TaskStatus { pending, inProgress, completed }
enum InvitationTheme { luxuryGold, floral, minimal, royal, modern }

// --- 1. Venue Model ---
class VenueModel {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final double rating;
  final double price;
  final bool isAvailable;
  final VenueType venueType; // indoor / outdoor / both
  final List<String> facilities;
  final String imageUrl;
  final String description;

  VenueModel({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.rating,
    required this.price,
    this.isAvailable = true,
    required this.venueType,
    required this.facilities,
    required this.imageUrl,
    required this.description,
  });
}

// --- 2. Package Model ---
class WeddingPackageModel {
  final String id;
  final String name;
  final String tier; // Basic, Standard, Premium
  final String targetAudience;
  final double price;
  final String decorationSummary;
  final String cateringSummary;
  final String photographySummary;
  final String videographySummary;
  final String stageSummary;
  final String lightingSummary;
  final String soundSummary;

  WeddingPackageModel({
    required this.id,
    required this.name,
    required this.tier,
    required this.targetAudience,
    required this.price,
    required this.decorationSummary,
    required this.cateringSummary,
    required this.photographySummary,
    required this.videographySummary,
    required this.stageSummary,
    required this.lightingSummary,
    required this.soundSummary,
  });
}

// --- 3. Decoration Item Model ---
class DecorationItemModel {
  final String id;
  final String name;
  final String category; // Wedding Arch, Stage, Floral, Entrance, Table, Lighting, Centerpieces, Seating
  final String themeName; // Luxury Floral Arch, Classic White, Royal Red, Modern Golden, Garden Theme
  final String description;
  final double price;
  final String imageUrl;
  bool isSelected;

  DecorationItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.themeName,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isSelected = false,
  });
}

// --- 4. Catering Package Model ---
class CateringItemModel {
  final String id;
  final String packageName;
  final double perPersonPrice;
  final List<String> appetizers;
  final List<String> mainCourse;
  final List<String> riceDishes;
  final List<String> meatDishes;
  final List<String> fishDishes;
  final List<String> vegetables;
  final List<String> desserts;
  final List<String> drinks;

  CateringItemModel({
    required this.id,
    required this.packageName,
    required this.perPersonPrice,
    required this.appetizers,
    required this.mainCourse,
    required this.riceDishes,
    required this.meatDishes,
    required this.fishDishes,
    required this.vegetables,
    required this.desserts,
    required this.drinks,
  });
}

// --- 5. Guest Model ---
class WeddingGuestModel {
  final String id;
  String name;
  String phone;
  String email;
  String groupFamily; // Family, Friends, VIP, Colleague
  int numberOfGuests;
  bool isInvited;
  RSVPStatus rsvpStatus;

  WeddingGuestModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.groupFamily,
    this.numberOfGuests = 1,
    this.isInvited = true,
    this.rsvpStatus = RSVPStatus.pending,
  });
}

// --- 6. Photography Service Model ---
enum MediaServiceType {
  photography,
  videography,
  combo, // Photography + Videography
  drone,
  other,
}

extension MediaServiceTypeExtension on MediaServiceType {
  String get label {
    switch (this) {
      case MediaServiceType.photography:
        return 'Photography';
      case MediaServiceType.videography:
        return 'Videography';
      case MediaServiceType.combo:
        return 'Photography + Videography';
      case MediaServiceType.drone:
        return 'Drone Coverage';
      case MediaServiceType.other:
        return 'Other Media Service';
    }
  }
}

enum MediaBookingStatus {
  planned,
  booked,
  completed,
}

extension MediaBookingStatusExtension on MediaBookingStatus {
  String get label {
    switch (this) {
      case MediaBookingStatus.planned:
        return 'Planned';
      case MediaBookingStatus.booked:
        return 'Booked';
      case MediaBookingStatus.completed:
        return 'Completed';
    }
  }
}

class PhotographyServiceModel {
  final String id;
  String title;
  String studioName;
  String contactInfo;
  DateTime? eventDate;
  MediaServiceType serviceType;
  double price;
  double advancePaid;
  MediaBookingStatus bookingStatus;
  String duration;
  String notes;
  String description;
  List<String> portfolioImages;
  bool isBooked;

  double get remainingBalance => price > advancePaid ? price - advancePaid : 0.0;

  PhotographyServiceModel({
    required this.id,
    required this.title,
    this.studioName = '',
    this.contactInfo = '',
    this.eventDate,
    this.serviceType = MediaServiceType.photography,
    required this.price,
    this.advancePaid = 0.0,
    this.bookingStatus = MediaBookingStatus.planned,
    required this.duration,
    this.notes = '',
    this.description = '',
    List<String>? portfolioImages,
    this.isBooked = false,
  }) : portfolioImages = portfolioImages ?? [];
}

// --- 7. Entertainment Option Model ---
class EntertainmentOptionModel {
  final String id;
  final String name;
  final String category; // DJ, Live Band, Singer, Dance, Sound System, Stage, Special Effects
  final String description;
  final double price;
  final String duration;
  final String imageUrl;
  bool isSelected;

  EntertainmentOptionModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.duration,
    required this.imageUrl,
    this.isSelected = false,
  });

  String get title => name;
}

// --- 8. Checklist Task Model ---
class WeddingTaskModel {
  final String id;
  final String title;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;

  WeddingTaskModel({
    required this.id,
    required this.title,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
  });
}

// --- 9. Payment Record Model ---
class PaymentRecordModel {
  final String id;
  final String weddingId;
  final DateTime date;
  final String serviceName;
  final double amount;
  final String paymentMethod; // bKash, Nagad, Rocket, Credit Card, Bank
  final String transactionId; // TrxID
  final String senderPhone;
  final String paymentType; // 50% Advance (Half Payment), Full Payment, Custom
  final String invoiceNo;
  final String status; // Verified ✓, Pending Verification

  PaymentRecordModel({
    required this.id,
    this.weddingId = 'WED-2026-0001',
    required this.date,
    required this.serviceName,
    required this.amount,
    required this.paymentMethod,
    this.transactionId = '',
    this.senderPhone = '',
    this.paymentType = '50% Advance (Half Payment)',
    this.invoiceNo = '',
    this.status = 'Verified ✓',
  });
}

// --- 10. Notification Item Model ---
class WeddingNotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final bool isRead;

  WeddingNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}

// --- Main Complete Booking Entity ---
class WeddingBookingModel {
  String weddingId; // WED-2026-0001
  
  // Couple
  String brideName;
  String groomName;
  String bridePhone;
  String groomPhone;

  // Wedding Info
  DateTime weddingDate;
  String weddingTime;
  WeddingType weddingType;
  int expectedGuestCount;
  String description;
  String? bridePhotoUrl;
  String? groomPhotoUrl;
  String? coverPhotoUrl;

  // Selections
  VenueModel? selectedVenue;
  WeddingPackageModel? selectedPackage;
  List<DecorationItemModel> selectedDecorations;
  CateringItemModel? selectedCateringPackage;
  String specialFoodRequirements;
  List<WeddingGuestModel> guestsList;
  List<PhotographyServiceModel> selectedMediaServices;
  List<EntertainmentOptionModel> selectedEntertainment;
  List<WeddingTaskModel> tasksList;
  
  // Budget
  double totalPlannedBudget;
  List<PaymentRecordModel> paymentHistory;

  // Digital Invitation
  InvitationTheme invitationTheme;
  String fontStyle;

  bool isConfirmed;

  WeddingBookingModel({
    this.weddingId = 'WED-2026-0001',
    this.brideName = 'Ariesha Rahman',
    this.groomName = 'Tariq Hassan',
    this.bridePhone = '+880 1711223344',
    this.groomPhone = '+880 1822334455',
    DateTime? weddingDate,
    this.weddingTime = '06:00 PM',
    this.weddingType = WeddingType.royal,
    this.expectedGuestCount = 300,
    this.description = 'A royal luxury wedding celebration with family & loved ones.',
    this.bridePhotoUrl,
    this.groomPhotoUrl,
    this.coverPhotoUrl,
    this.selectedVenue,
    this.selectedPackage,
    List<DecorationItemModel>? selectedDecorations,
    this.selectedCateringPackage,
    this.specialFoodRequirements = 'Halal food, vegetarian options required.',
    List<WeddingGuestModel>? guestsList,
    List<PhotographyServiceModel>? selectedMediaServices,
    List<EntertainmentOptionModel>? selectedEntertainment,
    List<WeddingTaskModel>? tasksList,
    this.totalPlannedBudget = 400000.0,
    List<PaymentRecordModel>? paymentHistory,
    this.invitationTheme = InvitationTheme.luxuryGold,
    this.fontStyle = 'Playfair Display',
    this.isConfirmed = false,
  })  : weddingDate = weddingDate ?? DateTime.now().add(const Duration(days: 120)),
        selectedDecorations = selectedDecorations ?? [],
        guestsList = guestsList ?? [],
        selectedMediaServices = selectedMediaServices ?? [],
        selectedEntertainment = selectedEntertainment ?? [],
        tasksList = tasksList ?? [],
        paymentHistory = paymentHistory ?? [];

  // --- Dynamic Pricing Calculations ---
  double get venueCost => selectedVenue?.price ?? 0.0;
  double get packageCost => selectedPackage?.price ?? 0.0;
  double get decorationCost =>
      selectedDecorations.fold(0.0, (sum, item) => sum + item.price);
  double get cateringCost =>
      (selectedCateringPackage?.perPersonPrice ?? 0.0) * expectedGuestCount;
  double get mediaCost =>
      selectedMediaServices.fold(0.0, (sum, item) => sum + item.price);
  double get entertainmentCost =>
      selectedEntertainment.fold(0.0, (sum, item) => sum + item.price);

  double get totalEstimatedCost =>
      venueCost +
      packageCost +
      decorationCost +
      cateringCost +
      mediaCost +
      entertainmentCost;

  double get totalPaidAmount =>
      paymentHistory.fold(0.0, (sum, item) => sum + item.amount);

  double get remainingBalance => totalEstimatedCost - totalPaidAmount;

  bool get isOverBudget => totalEstimatedCost > totalPlannedBudget;

  int get daysUntilWedding {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(weddingDate.year, weddingDate.month, weddingDate.day);
    return target.difference(today).inDays;
  }

  double get planningProgressPercentage {
    if (tasksList.isEmpty) return 0.0;
    final completed = tasksList.where((t) => t.status == TaskStatus.completed).length;
    return completed / tasksList.length;
  }
}
