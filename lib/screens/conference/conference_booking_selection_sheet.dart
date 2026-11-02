import 'package:flutter/material.dart';

import '../../data/conference/conference_seed_data.dart';
import '../../models/conference/conference_provider.dart';
import '../../services/conference_repository.dart';

class ConferenceBookingDraft {
  const ConferenceBookingDraft({
    required this.packageName,
    required this.totalPrice,
    required this.details,
  });

  final String packageName;
  final num totalPrice;
  final Map<String, dynamic> details;
}

class ConferenceBookingSelectionSheet extends StatefulWidget {
  const ConferenceBookingSelectionSheet({
    super.key,
    required this.provider,
    this.previousDetails = const {},
  });

  final ConferenceProvider provider;
  final Map<String, dynamic> previousDetails;

  @override
  State<ConferenceBookingSelectionSheet> createState() =>
      _ConferenceBookingSelectionSheetState();
}

class _ConferenceBookingSelectionSheetState
    extends State<ConferenceBookingSelectionSheet> {
  late final List<Map<String, dynamic>> _packages;
  late final List<Map<String, dynamic>> _vehicles;
  late final Map<String, int> _foodQuantities;
  late final Map<String, int> _vehicleQuantities;
  late String _selectedPackage;
  late int _participants;
  late int _rentalDays;
  String _selectedMeal = 'lunch';
  final _participantsController = TextEditingController();
  final _customController = TextEditingController();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  bool get _isFood => widget.provider.category == 'food';
  bool get _isTransportation => widget.provider.category == 'transportation';

  @override
  void initState() {
    super.initState();
    final packageData =
        widget.provider.details['packages'] ?? widget.provider.details['packs'];
    _packages = packageData is List
        ? packageData
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : [];
    final vehicleData = widget.provider.details['vehicles'];
    _vehicles = vehicleData is List
        ? vehicleData
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : [];
    final oldQuantities =
        widget.previousDetails['food_quantities'] as Map? ?? const {};
    _foodQuantities = {
      for (final item in ConferenceSeedData.foodItems)
        item['id'] as String: oldQuantities[item['id']] as int? ?? 0,
    };
    final oldVehicleQuantities =
        widget.previousDetails['vehicle_quantities'] as Map? ?? const {};
    _vehicleQuantities = {
      for (final vehicle in _vehicles)
        _vehicleId(vehicle):
            oldVehicleQuantities[_vehicleId(vehicle)] as int? ?? 0,
    };
    _selectedPackage =
        widget.previousDetails['package'] as String? ??
        (_packages.isEmpty
            ? 'Custom package'
            : _packages.first['name'] as String);
    _participants = widget.previousDetails['participants'] as int? ?? 20;
    _rentalDays = widget.previousDetails['rental_days'] as int? ?? 1;
    _participantsController.text = '$_participants';
    _customController.text =
        widget.previousDetails['custom_requirements'] as String? ?? '';
    _pickupController.text =
        widget.previousDetails['pickup_location'] as String? ?? '';
    _destinationController.text =
        widget.previousDetails['destination'] as String? ?? '';
  }

  @override
  void dispose() {
    _participantsController.dispose();
    _customController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  num get _packagePrice {
    if (_packages.isEmpty) return widget.provider.startingPrice;
    final selected = _packages.firstWhere(
      (item) => item['name'] == _selectedPackage,
      orElse: () => _packages.first,
    );
    return selected['price'] as num? ?? widget.provider.startingPrice;
  }

  List<Map<String, dynamic>> get _selectedFoods => [
    for (final item in ConferenceExpandedData.foodItems)
      if ((_foodQuantities[item['id'] as String] ?? 0) > 0)
        {
          'id': item['id'],
          'name': item['name'],
          'meal': item['meal'],
          'unit_price': item['price'],
          'quantity': _foodQuantities[item['id'] as String],
        },
  ];

  List<Map<String, dynamic>> get _selectedVehicles => [
    for (final vehicle in _vehicles)
      if ((_vehicleQuantities[_vehicleId(vehicle)] ?? 0) > 0)
        {
          ...vehicle,
          'quantity': _vehicleQuantities[_vehicleId(vehicle)],
          'days': _rentalDays,
        },
  ];

  num get _totalPrice {
    if (_isFood) return ConferenceOrderMath.foodTotal(_selectedFoods);
    if (_isTransportation) {
      return ConferenceOrderMath.transportTotal(_selectedVehicles);
    }
    return _packagePrice;
  }

  void _confirm() {
    if (_isFood && _selectedFoods.isEmpty) {
      _message('Add at least one menu item to continue.');
      return;
    }
    if (_isTransportation) {
      if (_selectedVehicles.isEmpty) {
        _message('Select at least one vehicle.');
        return;
      }
      if (_pickupController.text.trim().isEmpty ||
          _destinationController.text.trim().isEmpty) {
        _message('Enter both pickup and destination locations.');
        return;
      }
    }

    final details = <String, dynamic>{
      'custom_requirements': _customController.text.trim(),
    };
    if (_isFood) {
      details.addAll({
        'participants': _participants,
        'food_quantities': _foodQuantities,
        'items': _selectedFoods,
      });
    } else if (_isTransportation) {
      details.addAll({
        'rental_days': _rentalDays,
        'vehicle_quantities': _vehicleQuantities,
        'vehicles': _selectedVehicles,
        'pickup_location': _pickupController.text.trim(),
        'destination': _destinationController.text.trim(),
      });
    } else {
      final selected = _packages.firstWhere(
        (item) => item['name'] == _selectedPackage,
        orElse: () => <String, dynamic>{},
      );
      final inclusions = selected['includes'] ?? selected['inclusions'];
      details.addAll({
        'package': _selectedPackage,
        'package_details': selected['details'] ?? selected['duration'] ?? '',
        'inclusions': inclusions is List ? inclusions : const <String>[],
      });
    }

    Navigator.of(context).pop(
      ConferenceBookingDraft(
        packageName: _isFood
            ? 'Custom food order'
            : _isTransportation
            ? 'Vehicle rental'
            : _selectedPackage,
        totalPrice: _totalPrice,
        details: details,
      ),
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF3E2C26);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3E2C26),
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: text,
        ),
        textTheme: theme.textTheme.apply(bodyColor: text, displayColor: text),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Color(0xFF8A7A75)),
          labelStyle: const TextStyle(color: text),
          floatingLabelStyle: const TextStyle(color: text),
        ),
        chipTheme: theme.chipTheme.copyWith(
          labelStyle: const TextStyle(color: text),
          secondaryLabelStyle: const TextStyle(color: text),
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          textColor: text,
          subtitleTextStyle: const TextStyle(color: Color(0xFF6D625E)),
        ),
      ),
      child: SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.provider.name,
                            style: const TextStyle(
                              color: text,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.provider.category == 'food'
                                ? 'Choose meals and portions'
                                : widget.provider.category == 'transportation'
                                ? 'Choose vehicles and rental days'
                                : 'Select a package',
                            style: const TextStyle(color: Color(0xFF8A7A75)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: text),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  children: [
                    _buildProviderInformation(),
                    const SizedBox(height: 18),
                    if (_isFood) _buildFoodSelection(),
                    if (_isTransportation) _buildTransportSelection(),
                    if (!_isFood && !_isTransportation) _buildPackages(),
                    if (!_isFood) ...[
                      const SizedBox(height: 18),
                      TextField(
                        controller: _customController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Custom requirements (optional)',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE9DED5))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated total',
                            style: TextStyle(color: Color(0xFF8A7A75)),
                          ),
                          Text(
                            '৳${_totalPrice.toString()}',
                            style: const TextStyle(
                              color: text,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: _confirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: text,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save selection'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackages() {
    if (_packages.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Standard service'),
        subtitle: Text('Starting from ৳${widget.provider.startingPrice}'),
        trailing: const Icon(Icons.check_circle, color: Color(0xFFB88A68)),
      );
    }
    return RadioGroup<String>(
      groupValue: _selectedPackage,
      onChanged: (value) {
        if (value != null) setState(() => _selectedPackage = value);
      },
      child: Column(
        children: _packages.map((item) {
          final name = item['name'] as String? ?? 'Package';
          final inclusions = item['includes'] ?? item['inclusions'];
          final detail =
              item['details'] ??
              item['duration'] ??
              (inclusions is List ? inclusions.join(', ') : '');
          return RadioListTile<String>(
            value: name,
            activeColor: const Color(0xFFB88A68),
            title: Text(name),
            subtitle: Text(
              detail.toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            secondary: Text(
              '৳${item['price'] ?? widget.provider.startingPrice}',
            ),
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProviderInformation() {
    final details = widget.provider.details;
    final facilities = details['facilities'];
    final policies = details['policies'];
    final contacts = [
      details['contact_phone'] ?? details['phone'],
      details['contact_email'] ?? details['email'],
      details['website'],
    ].whereType<String>().where((value) => value.isNotEmpty).toList();
    final facts = <String>[
      if (details['capacity'] != null) 'Capacity: ${details['capacity']}',
      if (details['parking_capacity'] != null)
        'Parking: ${details['parking_capacity']}',
      if (details['staff_count'] != null) 'Staff: ${details['staff_count']}',
      if (details['hygiene_information'] != null)
        'Hygiene: ${details['hygiene_information']}',
      if (details['chef_team'] != null) 'Team: ${details['chef_team']}',
      if (details['fuel_policy'] != null) 'Fuel: ${details['fuel_policy']}',
      if (details['driver_information'] != null)
        'Driver: ${details['driver_information']}',
      if (details['ac'] != null) 'AC: ${details['ac'] == true ? 'Yes' : 'No'}',
      if (details['wifi'] != null)
        'Wi-Fi: ${details['wifi'] == true ? 'Yes' : 'No'}',
      if (details['cctv'] != null)
        'CCTV: ${details['cctv'] == true ? 'Yes' : 'No'}',
      if (policies is Map && policies['outside_food'] != null)
        'Outside food: ${policies['outside_food'] == true ? 'Allowed' : 'Not allowed'}',
      if (policies is Map && policies['outside_decoration'] != null)
        'Outside decoration: ${policies['outside_decoration'] == true ? 'Allowed' : 'Not allowed'}',
      if (policies is Map && policies['outside_sound'] != null)
        'Outside sound: ${policies['outside_sound'] == true ? 'Allowed' : 'Not allowed'}',
    ];
    final gallery = details['gallery'] ?? details['gallery_images'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.provider.address.isNotEmpty)
          _providerLine(Icons.location_on_outlined, widget.provider.address),
        if (widget.provider.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.provider.description,
            style: const TextStyle(
              color: Color(0xFF6D625E),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        if (facilities is List && facilities.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: facilities
                .map(
                  (facility) => Chip(
                    label: Text(facility.toString()),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFFF0E6DD),
                    labelStyle: const TextStyle(
                      color: Color(0xFF3E2C26),
                      fontSize: 11,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (facts.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final fact in facts)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                fact,
                style: const TextStyle(color: Color(0xFF6D625E), fontSize: 12),
              ),
            ),
        ],
        if (contacts.isNotEmpty) ...[
          const SizedBox(height: 10),
          _providerLine(Icons.call_outlined, contacts.join(' · ')),
        ],
        if (gallery is List && gallery.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  gallery[index].toString(),
                  width: 104,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 104,
                    color: const Color(0xFFF0E6DD),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _providerLine(IconData icon, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: const Color(0xFFB88A68)),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(color: Color(0xFF6D625E), fontSize: 12),
        ),
      ),
    ],
  );

  Widget _buildFoodSelection() {
    final items = ConferenceSeedData.foodItems
        .where((item) => item['meal'] == _selectedMeal)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              onPressed: _participants <= 1
                  ? null
                  : () => setState(() {
                      _participants--;
                      _participantsController.text = '$_participants';
                    }),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_participants'),
            IconButton(
              onPressed: () => setState(() {
                _participants++;
                _participantsController.text = '$_participants';
              }),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final meal in ['breakfast', 'lunch', 'dinner'])
              ChoiceChip(
                label: Text(meal[0].toUpperCase() + meal.substring(1)),
                selected: _selectedMeal == meal,
                onSelected: (_) => setState(() => _selectedMeal = meal),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image_url'] as String,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 46,
                  height: 46,
                  color: const Color(0xFFF0E6DD),
                  child: const Icon(Icons.restaurant_outlined, size: 20),
                ),
              ),
            ),
            title: Text(item['name'] as String),
            subtitle: Text('৳${item['price']} per portion'),
            trailing: _quantityControl(
              _foodQuantities[item['id'] as String] ?? 0,
              onChanged: (quantity) => setState(
                () => _foodQuantities[item['id'] as String] = quantity,
              ),
            ),
          ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No demo items are listed for this meal.'),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _participantsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Set participant count',
            helperText: 'This is independent from each item quantity.',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final count = int.tryParse(value);
            if (count != null && count > 0) {
              setState(() => _participants = count);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTransportSelection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Rental duration')),
            IconButton(
              onPressed: _rentalDays <= 1
                  ? null
                  : () => setState(() => _rentalDays--),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_rentalDays days'),
            IconButton(
              onPressed: () => setState(() => _rentalDays++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        for (final vehicle in _vehicles)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(vehicle['name'] as String? ?? 'Vehicle'),
            subtitle: Text(
              '${vehicle['capacity'] ?? '—'} seats · '
              '৳${vehicle['price_per_day'] ?? 0}/day',
            ),
            trailing: _quantityControl(
              _vehicleQuantities[_vehicleId(vehicle)] ?? 0,
              onChanged: (quantity) => setState(
                () => _vehicleQuantities[_vehicleId(vehicle)] = quantity,
              ),
            ),
          ),
        if (_vehicles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('No vehicles are listed by this provider.'),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _pickupController,
          decoration: const InputDecoration(
            labelText: 'Pickup location',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _destinationController,
          decoration: const InputDecoration(
            labelText: 'Destination',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _quantityControl(int value, {required ValueChanged<int> onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: value == 0 ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value'),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  String _vehicleId(Map<String, dynamic> vehicle) =>
      vehicle['id']?.toString() ?? vehicle['name']?.toString() ?? 'vehicle';
}
