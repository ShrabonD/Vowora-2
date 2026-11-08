import 'package:flutter/material.dart';
import '../models/wedding_profile.dart';
import '../models/budget_item.dart';
import '../models/guest.dart';
import '../models/vendor.dart';
import '../models/task_item.dart';
import '../models/timeline_event.dart';
import '../models/seating_table.dart';
import '../models/inspiration_item.dart';

class WeddingProvider extends ChangeNotifier {
  WeddingProfile _weddingProfile = WeddingProfile(
    id: '',
    userId: '',
    coupleName: '',
    weddingDate: DateTime.now().add(const Duration(days: 120)),
    location: '',
    estimatedGuestCount: 0,
    estimatedBudget: 0.0,
    currency: 'BDT (৳)',
    style: 'Luxury',
    primaryColor: '#D4AF37',
  );

  List<BudgetItem> _budgetItems = [];
  List<Guest> _guests = [];
  List<Vendor> _vendors = [];
  List<TaskItem> _tasks = [];
  List<TimelineEvent> _timelineEvents = [];
  List<SeatingTable> _seatingTables = [];
  List<InspirationItem> _inspirationItems = [];

  WeddingProfile get weddingProfile => _weddingProfile;
  List<BudgetItem> get budgetItems => _budgetItems;
  List<Guest> get guests => _guests;
  List<Vendor> get vendors => _vendors;
  List<TaskItem> get tasks => _tasks;
  List<TimelineEvent> get timelineEvents => _timelineEvents;
  List<SeatingTable> get seatingTables => _seatingTables;
  List<InspirationItem> get inspirationItems {
    if (_inspirationItems.isEmpty) {
      _inspirationItems = [
        InspirationItem(
          id: 'insp_1',
          title: 'Crystal Chandelier Grand Ballroom Reception',
          category: 'Lighting',
          imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
          isFavorite: true,
        ),
        InspirationItem(
          id: 'insp_2',
          title: 'Cascade White Orchid Floral Arch',
          category: 'Floral Designs',
          imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed',
          isFavorite: false,
        ),
        InspirationItem(
          id: 'insp_3',
          title: 'Bespoke Velvet Stage Setup with Gold Accents',
          category: 'Stage Setups',
          imageUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6',
          isFavorite: true,
        ),
        InspirationItem(
          id: 'insp_4',
          title: 'Candlelit Bohemian Tablescape & Fine China',
          category: 'Table Decor',
          imageUrl: 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce',
          isFavorite: false,
        ),
        InspirationItem(
          id: 'insp_5',
          title: 'Sunset Garden Glasshouse Venue',
          category: 'Luxury Venues',
          imageUrl: 'https://images.unsplash.com/photo-1545232979-fbf82fdc3f86',
          isFavorite: false,
        ),
        InspirationItem(
          id: 'insp_6',
          title: 'Starry Night Outdoor Canopy & Fairy Lights',
          category: 'Outdoor Events',
          imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc',
          isFavorite: true,
        ),
        InspirationItem(
          id: 'insp_7',
          title: 'Haute Couture Lace Gown & Pearl Veil',
          category: 'Wedding',
          imageUrl: 'https://images.unsplash.com/photo-1594552072238-b8a3da72ae9a',
          isFavorite: false,
        ),
        InspirationItem(
          id: 'insp_8',
          title: 'Five-Tier Gold Leaf Sugar Flower Cake',
          category: 'Birthday',
          imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13136',
          isFavorite: false,
        ),
      ];
    }
    return _inspirationItems;
  }

  // Dynamic Budget Calculations
  double get totalBudget => _weddingProfile.estimatedBudget;
  double get totalSpent => _budgetItems.fold(0.0, (sum, item) => sum + item.amount);
  double get totalPaid => _budgetItems.fold(0.0, (sum, item) => sum + item.paidAmount);
  double get remainingBudget => totalBudget - totalSpent;
  double get spentPercentage => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => totalSpent > totalBudget;

  // Dynamic Guest Calculations
  int get totalGuests => _guests.length;
  int get attendingGuests => _guests.where((g) => g.rsvp == 'Attending').length;
  int get pendingRsvpGuests => _guests.where((g) => g.rsvp == 'Pending').length;
  int get notAttendingGuests => _guests.where((g) => g.rsvp == 'Not Attending').length;

  // Dynamic Task Calculations
  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  double get taskCompletionPercentage =>
      totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;

  WeddingProvider() {
    _clearDemoData();
  }

  void _clearDemoData() {
    _budgetItems = [];
    _guests = [];
    _vendors = [];
    _tasks = [];
    _timelineEvents = [];
    _seatingTables = [];
    _inspirationItems = [];
  }

  // --- CRUD ACTIONS ---

  void updateWeddingProfile(WeddingProfile newProfile) {
    _weddingProfile = newProfile;
    notifyListeners();
  }

  // Budget
  void addBudgetItem(BudgetItem item) {
    _budgetItems.add(item);
    notifyListeners();
  }

  void editBudgetItem(BudgetItem item) {
    final index = _budgetItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _budgetItems[index] = item;
      notifyListeners();
    }
  }

  void deleteBudgetItem(String id) {
    _budgetItems.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  // Guests
  void addGuest(Guest guest) {
    _guests.add(guest);
    notifyListeners();
  }

  void editGuest(Guest guest) {
    final index = _guests.indexWhere((g) => g.id == guest.id);
    if (index != -1) {
      _guests[index] = guest;
      notifyListeners();
    }
  }

  void deleteGuest(String id) {
    _guests.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // Vendors
  void addVendor(Vendor vendor) {
    _vendors.add(vendor);
    notifyListeners();
  }

  void editVendor(Vendor vendor) {
    final index = _vendors.indexWhere((v) => v.id == vendor.id);
    if (index != -1) {
      _vendors[index] = vendor;
      notifyListeners();
    }
  }

  void deleteVendor(String id) {
    _vendors.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Tasks
  void addTask(TaskItem task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Timeline
  void addTimelineEvent(TimelineEvent event) {
    _timelineEvents.add(event);
    notifyListeners();
  }

  void deleteTimelineEvent(String id) {
    _timelineEvents.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Seating
  void addSeatingTable(SeatingTable table) {
    _seatingTables.add(table);
    notifyListeners();
  }

  void assignGuestToTable(String guestId, String tableId) {
    for (int i = 0; i < _seatingTables.length; i++) {
      final updatedList = List<String>.from(_seatingTables[i].guestIds)..remove(guestId);
      _seatingTables[i] = _seatingTables[i].copyWith(guestIds: updatedList);
    }
    final targetIndex = _seatingTables.indexWhere((t) => t.id == tableId);
    if (targetIndex != -1) {
      final updatedList = List<String>.from(_seatingTables[targetIndex].guestIds)..add(guestId);
      _seatingTables[targetIndex] = _seatingTables[targetIndex].copyWith(guestIds: updatedList);
    }
    notifyListeners();
  }

  void toggleInspirationFavorite(String id) {
    final index = _inspirationItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _inspirationItems[index] = _inspirationItems[index].copyWith(
        isFavorite: !_inspirationItems[index].isFavorite,
      );
      notifyListeners();
    }
  }
}
