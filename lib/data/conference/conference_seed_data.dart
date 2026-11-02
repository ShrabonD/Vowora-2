// lib/data/conference_expanded_data.dart

class ConferenceExpandedData {
  static const halls = [
    {
      'id': 'hall_01',
      'name': 'Grand Palace Convention',
      'city': 'Dhaka',
      'capacity': 300,
      'price': 35000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator'],
      'policies': {
        'outside_food': true,
        'outside_decoration': true,
        'outside_sound': false,
      },
      'packages': [
        {'name': 'Basic', 'price': 35000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 47000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 60000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'Projector', 'price': 2500},
        {'name': 'Extra Hour', 'price': 3000},
        {'name': 'Extended Stage', 'price': 5000},
      ],
    },
    {
      'id': 'hall_02',
      'name': 'Radisson Blu Water Garden',
      'city': 'Dhaka',
      'capacity': 800,
      'price': 95000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator', 'Green Room'],
      'policies': {'outside_food': false, 'outside_decoration': true, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 95000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 107000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 120000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'LED Screen', 'price': 12000},
        {'name': 'Projector', 'price': 4500},
        {'name': 'Extra Hour', 'price': 5000},
      ],
    },
    {
      'id': 'hall_03',
      'name': 'Bashundhara Convention Hall',
      'city': 'Dhaka',
      'capacity': 1200,
      'price': 120000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator'],
      'policies': {'outside_food': true, 'outside_decoration': true, 'outside_sound': true},
      'packages': [
        {'name': 'Basic', 'price': 120000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 132000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 145000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'LED Wall', 'price': 15000},
        {'name': 'Stage Extension', 'price': 8000},
        {'name': 'Extra Hour', 'price': 5000},
      ],
    },
    {
      'id': 'hall_04',
      'name': 'Pan Pacific Sonargaon',
      'city': 'Dhaka',
      'capacity': 500,
      'price': 85000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator'],
      'policies': {'outside_food': false, 'outside_decoration': true, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 85000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 97000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 110000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'Projector', 'price': 4000},
        {'name': 'Premium Lighting', 'price': 6000},
      ],
    },
    {
      'id': 'hall_05',
      'name': 'Le Méridien Dhaka',
      'city': 'Dhaka',
      'capacity': 450,
      'price': 90000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Green Room'],
      'policies': {'outside_food': false, 'outside_decoration': true, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 90000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 102000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 115000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'LED Screen', 'price': 10000},
        {'name': 'Extra Hour', 'price': 5000},
      ],
    },
    {
      'id': 'hall_06',
      'name': 'The Westin Dhaka',
      'city': 'Dhaka',
      'capacity': 400,
      'price': 88000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator'],
      'policies': {'outside_food': false, 'outside_decoration': false, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 88000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 100000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 113000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'Projector', 'price': 4000},
        {'name': 'Stage Lighting', 'price': 7000},
      ],
    },
    {
      'id': 'hall_07',
      'name': 'International Convention City',
      'city': 'Dhaka',
      'capacity': 2000,
      'price': 180000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator', 'Green Room'],
      'policies': {'outside_food': true, 'outside_decoration': true, 'outside_sound': true},
      'packages': [
        {'name': 'Basic', 'price': 180000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 192000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 205000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'LED Wall', 'price': 20000},
        {'name': 'VIP Room', 'price': 10000},
      ],
    },
    {
      'id': 'hall_08',
      'name': 'Six Seasons Hotel',
      'city': 'Dhaka',
      'capacity': 350,
      'price': 70000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage'],
      'policies': {'outside_food': false, 'outside_decoration': true, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 70000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 82000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 95000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'Projector', 'price': 3000},
        {'name': 'Extra Hour', 'price': 4000},
      ],
    },
    {
      'id': 'hall_09',
      'name': 'Amari Dhaka',
      'city': 'Dhaka',
      'capacity': 320,
      'price': 75000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage'],
      'policies': {'outside_food': false, 'outside_decoration': true, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 75000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 87000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 100000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'LED Screen', 'price': 10000},
        {'name': 'Extra Hour', 'price': 4000},
      ],
    },
    {
      'id': 'hall_10',
      'name': 'Hotel Sarina',
      'city': 'Dhaka',
      'capacity': 380,
      'price': 68000,
      'facilities': ['AC', 'WiFi', 'CCTV', 'Parking', 'Stage', 'Generator'],
      'policies': {'outside_food': false, 'outside_decoration': true, 'outside_sound': false},
      'packages': [
        {'name': 'Basic', 'price': 68000, 'duration': '6 Hours'},
        {'name': 'Standard', 'price': 80000, 'duration': '10 Hours'},
        {'name': 'Premium', 'price': 93000, 'duration': '12 Hours'},
      ],
      'addons': [
        {'name': 'Projector', 'price': 3000},
        {'name': 'Extra Hour', 'price': 3500},
      ],
    },
  ];

  // FOOD ITEMS: reusable menu records with individual item prices.
  static const foodItems = [
    {'id': 'f01', 'name': 'Kacchi Biryani', 'category': 'Main Course', 'price': 250, 'meal': 'lunch'},
    {'id': 'f02', 'name': 'Morog Polao', 'category': 'Main Course', 'price': 220, 'meal': 'lunch'},
    {'id': 'f03', 'name': 'Beef Tehari', 'category': 'Main Course', 'price': 200, 'meal': 'lunch'},
    {'id': 'f04', 'name': 'Chicken Roast', 'category': 'Main Course', 'price': 180, 'meal': 'lunch'},
    {'id': 'f05', 'name': 'Beef Rezala', 'category': 'Main Course', 'price': 230, 'meal': 'lunch'},
    {'id': 'f06', 'name': 'Plain Polao', 'category': 'Rice', 'price': 90, 'meal': 'lunch'},
    {'id': 'f07', 'name': 'Rui Fish Curry', 'category': 'Main Course', 'price': 160, 'meal': 'lunch'},
    {'id': 'f08', 'name': 'Mixed Vegetable', 'category': 'Side Dish', 'price': 70, 'meal': 'lunch'},
    {'id': 'f09', 'name': 'Fresh Salad', 'category': 'Side Dish', 'price': 50, 'meal': 'lunch'},
    {'id': 'f10', 'name': 'Borhani', 'category': 'Drinks', 'price': 40, 'meal': 'lunch'},
    {'id': 'f11', 'name': 'Firni', 'category': 'Dessert', 'price': 80, 'meal': 'lunch'},
    {'id': 'f12', 'name': 'Jorda', 'category': 'Dessert', 'price': 60, 'meal': 'lunch'},
    {'id': 'f13', 'name': 'Paratha', 'category': 'Breakfast', 'price': 25, 'meal': 'breakfast'},
    {'id': 'f14', 'name': 'Boiled Egg', 'category': 'Breakfast', 'price': 25, 'meal': 'breakfast'},
    {'id': 'f15', 'name': 'Dal', 'category': 'Breakfast', 'price': 35, 'meal': 'breakfast'},
    {'id': 'f16', 'name': 'Butter Toast', 'category': 'Breakfast', 'price': 40, 'meal': 'breakfast'},
    {'id': 'f17', 'name': 'Tea', 'category': 'Drinks', 'price': 25, 'meal': 'breakfast'},
    {'id': 'f18', 'name': 'Chicken Grill', 'category': 'Main Course', 'price': 220, 'meal': 'dinner'},
    {'id': 'f19', 'name': 'BBQ Chicken', 'category': 'Main Course', 'price': 260, 'meal': 'dinner'},
    {'id': 'f20', 'name': 'Butter Naan', 'category': 'Bread', 'price': 45, 'meal': 'dinner'},
    {'id': 'f21', 'name': 'Chicken Pasta', 'category': 'Main Course', 'price': 190, 'meal': 'dinner'},
    {'id': 'f22', 'name': 'Fruit Custard', 'category': 'Dessert', 'price': 90, 'meal': 'dinner'},
    {'id': 'f23', 'name': 'Mineral Water', 'category': 'Drinks', 'price': 20, 'meal': 'dinner'},
    {'id': 'f24', 'name': 'Beef Korma', 'category': 'Main Course', 'price': 280, 'meal': 'dinner'},
    {'id': 'f25', 'name': 'Mutton Rezala', 'category': 'Main Course', 'price': 320, 'meal': 'dinner'},
    {'id': 'f26', 'name': 'Fried Rice', 'category': 'Rice', 'price': 140, 'meal': 'dinner'},
    {'id': 'f27', 'name': 'Firni', 'category': 'Dessert', 'price': 80, 'meal': 'dinner'},
    {'id': 'f28', 'name': 'Jorda', 'category': 'Dessert', 'price': 70, 'meal': 'dinner'},
  ];

  static const foods = [
    {'id': 'food_01', 'name': 'Dhaka Catering Services', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 180},
    {'id': 'food_02', 'name': 'Premium Bites', 'city': 'Dhaka', 'minimum_guests': 30, 'starting_price': 220},
    {'id': 'food_03', 'name': 'Kacchi Bhai', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 250},
    {'id': 'food_04', 'name': 'Sultans Dine', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 250},
    {'id': 'food_05', 'name': 'Tabaq Coffee', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 150},
    {'id': 'food_06', 'name': 'Cafe Rio', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 180},
    {'id': 'food_07', 'name': 'Star Kabab', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 170},
    {'id': 'food_08', 'name': 'Herfy', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 200},
    {'id': 'food_09', 'name': 'Pizza Hut', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 300},
    {'id': 'food_10', 'name': 'Chillox', 'city': 'Dhaka', 'minimum_guests': 20, 'starting_price': 200},
  ];

  static const sounds = [
    {'id': 'sound_01', 'name': 'ProAudio Events', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 12000, 'includes': ['2 Speakers', '2 Microphones', 'Mixer', 'Operator']},
      {'name': 'Pro', 'price': 22000, 'includes': ['4 Speakers', '4 Wireless Mics', 'Digital Mixer', 'Projector']},
      {'name': 'Pro Plus', 'price': 37000, 'includes': ['PA System', 'LED Screen', '6 Wireless Mics', 'Stage Lighting']},
    ]},
    {'id': 'sound_02', 'name': 'Sound Master BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 13500, 'includes': ['2 Speakers', '2 Microphones', 'Mixer']},
      {'name': 'Pro', 'price': 23500, 'includes': ['4 Speakers', '4 Wireless Mics', 'Projector']},
      {'name': 'Pro Plus', 'price': 38500, 'includes': ['PA System', 'LED Screen', 'Stage Lighting']},
    ]},
    {'id': 'sound_03', 'name': 'Mega Sound', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 15000, 'includes': ['2 Speakers', '2 Microphones', 'Operator']},
      {'name': 'Pro', 'price': 25000, 'includes': ['4 Speakers', '4 Wireless Mics', 'Digital Mixer']},
      {'name': 'Pro Plus', 'price': 40000, 'includes': ['PA System', 'LED Wall', 'Stage Lighting']},
    ]},
    {'id': 'sound_04', 'name': 'Elite AV Solutions', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 16500, 'includes': ['2 Speakers', '2 Microphones', 'Mixer']},
      {'name': 'Pro', 'price': 26500, 'includes': ['4 Speakers', '4 Wireless Mics', 'Projector']},
      {'name': 'Pro Plus', 'price': 41500, 'includes': ['PA System', 'LED Screen', 'AV Team']},
    ]},
    {'id': 'sound_05', 'name': 'DJ Rafi Setup', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 12000, 'includes': ['DJ Console', '2 Speakers', 'Operator']},
      {'name': 'Pro', 'price': 22000, 'includes': ['DJ Console', '4 Speakers', 'Lighting']},
      {'name': 'Pro Plus', 'price': 35000, 'includes': ['DJ Console', 'LED Screen', 'Lighting', 'PA System']},
    ]},
    {'id': 'sound_06', 'name': 'VisualPro Screens', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 14000, 'includes': ['Projector', 'Screen', 'Operator']},
      {'name': 'Pro', 'price': 26000, 'includes': ['HD Projector', 'LED Screen', 'AV Operator']},
      {'name': 'Pro Plus', 'price': 42000, 'includes': ['Large LED Wall', 'Multiple Displays', 'AV Team']},
    ]},
    {'id': 'sound_07', 'name': 'Sound & Light BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 14500, 'includes': ['Speakers', 'Microphones', 'Basic Lighting']},
      {'name': 'Pro', 'price': 25500, 'includes': ['Speakers', 'Wireless Mics', 'Stage Lighting']},
      {'name': 'Pro Plus', 'price': 41000, 'includes': ['PA System', 'LED Wall', 'Premium Lighting']},
    ]},
    {'id': 'sound_08', 'name': 'Event Tech BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 16000, 'includes': ['Mixer', 'Speakers', 'Operator']},
      {'name': 'Pro', 'price': 27000, 'includes': ['Digital Mixer', 'Projector', 'Wireless Mics']},
      {'name': 'Pro Plus', 'price': 43000, 'includes': ['Complete AV Setup', 'LED Screen', 'Technical Team']},
    ]},
    {'id': 'sound_09', 'name': 'Acoustic Perfect', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 17000, 'includes': ['Speakers', 'Mixer', 'Microphones']},
      {'name': 'Pro', 'price': 28000, 'includes': ['Professional PA', 'Wireless Mics', 'Sound Engineer']},
      {'name': 'Pro Plus', 'price': 45000, 'includes': ['Premium PA', 'LED Display', 'Complete Sound Team']},
    ]},
    {'id': 'sound_10', 'name': 'NextGen Displays', 'city': 'Dhaka', 'packages': [
      {'name': 'Normal', 'price': 18000, 'includes': ['Projector', 'Screen', 'Operator']},
      {'name': 'Pro', 'price': 29000, 'includes': ['LED Display', 'Projector', 'AV Operator']},
      {'name': 'Pro Plus', 'price': 46000, 'includes': ['Large LED Wall', 'Multi Screen', 'Full AV Team']},
    ]},
  ];

  static const decorations = [
    {'id': 'decor_01', 'name': 'Elegant Events Decor', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 18000, 'includes': ['Stage Backdrop', 'Welcome Sign']},
      {'name': 'Standard', 'price': 30000, 'includes': ['Stage', 'Flowers', 'Lighting', 'Entrance']},
      {'name': 'Premium', 'price': 48000, 'includes': ['Custom Stage', 'Premium Flowers', 'Full Venue Lighting', 'Branding']},
    ]},
    {'id': 'decor_02', 'name': 'Floral Fantasy', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 20000, 'includes': ['Flower Backdrop', 'Stage Flowers']},
      {'name': 'Standard', 'price': 33000, 'includes': ['Floral Stage', 'Entrance Flowers', 'Table Centerpieces']},
      {'name': 'Premium', 'price': 52000, 'includes': ['Luxury Floral Design', 'Full Stage', 'Entrance Installation']},
    ]},
    {'id': 'decor_03', 'name': 'Theme Crafters', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 22000, 'includes': ['Theme Backdrop', 'Stage']},
      {'name': 'Standard', 'price': 35000, 'includes': ['Custom Theme', 'Lighting', 'Entrance']},
      {'name': 'Premium', 'price': 55000, 'includes': ['Full Custom Theme', 'Stage', 'Branding', 'Lighting']},
    ]},
    {'id': 'decor_04', 'name': 'Light & Shadow', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 19000, 'includes': ['Basic Lighting', 'Backdrop']},
      {'name': 'Standard', 'price': 32000, 'includes': ['Stage Lighting', 'Backdrop', 'Entrance']},
      {'name': 'Premium', 'price': 50000, 'includes': ['Full Venue Lighting', 'LED Backdrop', 'Stage Design']},
    ]},
    {'id': 'decor_05', 'name': 'Balloon Bliss', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 15000, 'includes': ['Balloon Backdrop', 'Welcome Area']},
      {'name': 'Standard', 'price': 27000, 'includes': ['Balloon Arch', 'Stage', 'Entrance']},
      {'name': 'Premium', 'price': 43000, 'includes': ['Custom Balloon Installation', 'Stage', 'Photo Zone']},
    ]},
    {'id': 'decor_06', 'name': 'Royal Decor BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 24000, 'includes': ['Royal Backdrop', 'Stage Flowers']},
      {'name': 'Standard', 'price': 38000, 'includes': ['Premium Stage', 'Entrance', 'Lighting']},
      {'name': 'Premium', 'price': 60000, 'includes': ['Luxury Theme', 'Full Stage', 'Floral Work', 'Lighting']},
    ]},
    {'id': 'decor_07', 'name': 'Minimalist Designs', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 16000, 'includes': ['Minimal Backdrop', 'Stage']},
      {'name': 'Standard', 'price': 28000, 'includes': ['Minimal Theme', 'Lighting', 'Signage']},
      {'name': 'Premium', 'price': 45000, 'includes': ['Full Minimal Theme', 'Stage', 'Photo Wall']},
    ]},
    {'id': 'decor_08', 'name': 'Fairy Lights BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 17000, 'includes': ['Fairy Lights', 'Backdrop']},
      {'name': 'Standard', 'price': 29000, 'includes': ['Stage Lights', 'Entrance Lights', 'Backdrop']},
      {'name': 'Premium', 'price': 47000, 'includes': ['Full Venue Lights', 'Stage', 'Photo Zone']},
    ]},
    {'id': 'decor_09', 'name': 'Stage Craft', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 21000, 'includes': ['Stage', 'Backdrop']},
      {'name': 'Standard', 'price': 34000, 'includes': ['Extended Stage', 'Lighting', 'Branding']},
      {'name': 'Premium', 'price': 55000, 'includes': ['Custom Stage', 'LED Backdrop', 'Premium Lighting']},
    ]},
    {'id': 'decor_10', 'name': 'Artistic Touches', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 19000, 'includes': ['Artistic Backdrop', 'Stage']},
      {'name': 'Standard', 'price': 32000, 'includes': ['Custom Art', 'Stage', 'Lighting']},
      {'name': 'Premium', 'price': 51000, 'includes': ['Full Artistic Theme', 'Stage', 'Photo Wall', 'Entrance']},
    ]},
  ];

  static const photography = [
    {'id': 'photo_01', 'name': 'Chitrogolpo Studios', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 15000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 27000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 45000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_02', 'name': 'Lens Life BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 16000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 28000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 46000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_03', 'name': 'Frame Perfect', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 17000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 29000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 47000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_04', 'name': 'Visual Storytellers', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 18000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 30000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 48000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_05', 'name': 'Pixel Studio', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 19000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 31000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 49000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_06', 'name': 'Drone Shots BD', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 20000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': true, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 32000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 50000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_07', 'name': 'Cinematic Frames', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 21000, 'hours': 3, 'photographers': 1, 'videographers': 1, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 33000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 51000, 'hours': 10, 'photographers': 2, 'videographers': 2, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_08', 'name': 'Snap Event', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 22000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 34000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 52000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_09', 'name': 'Studio 71', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 23000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 35000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 53000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
    {'id': 'photo_10', 'name': 'Event Clicks', 'city': 'Dhaka', 'packages': [
      {'name': 'Basic', 'price': 24000, 'hours': 3, 'photographers': 1, 'videographers': 0, 'drone': false, 'edited_photos': 100, 'delivery_days': 7},
      {'name': 'Pro', 'price': 36000, 'hours': 6, 'photographers': 2, 'videographers': 1, 'drone': false, 'edited_photos': 250, 'delivery_days': 10},
      {'name': 'Cinematic', 'price': 54000, 'hours': 10, 'photographers': 2, 'videographers': 1, 'drone': true, 'edited_photos': 400, 'delivery_days': 14},
    ]},
  ];

  static const transport = [
    {'id': 'transport_01', 'name': 'Luxury Rides BD', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3500},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 5500},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6500},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8000},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12000},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16000},
    ]},
    {'id': 'transport_02', 'name': 'Dhaka Car Rental', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3800},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 5800},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6800},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8300},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12300},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16300},
    ]},
    {'id': 'transport_03', 'name': 'Executive Transport', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 4000},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 6000},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 7000},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8500},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12500},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16500},
    ]},
    {'id': 'transport_04', 'name': 'VIP Shuttle', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 4200},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 6200},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 7200},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8700},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12700},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16700},
    ]},
    {'id': 'transport_05', 'name': 'City Movers', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3600},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 5600},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6600},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8100},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12100},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16100},
    ]},
    {'id': 'transport_06', 'name': 'Elite Chauffeur', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 4500},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 6500},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 7500},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 9000},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 13000},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 17000},
    ]},
    {'id': 'transport_07', 'name': 'Group Travels', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3700},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 5700},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6700},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8200},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12200},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16200},
    ]},
    {'id': 'transport_08', 'name': 'Airport Transfers BD', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3900},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 5900},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6900},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 8400},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 12400},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 16400},
    ]},
    {'id': 'transport_09', 'name': 'Luxury Fleet', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 5000},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 7000},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 8000},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 9500},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 13500},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 17500},
    ]},
    {'id': 'transport_10', 'name': 'Safe Ride BD', 'city': 'Dhaka', 'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3400},
      {'id': 'v02', 'name': 'Premium Sedan', 'capacity': 4, 'price_per_day': 5400},
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6400},
      {'id': 'v04', 'name': 'Hiace', 'capacity': 15, 'price_per_day': 7900},
      {'id': 'v05', 'name': 'Mini Bus', 'capacity': 30, 'price_per_day': 11900},
      {'id': 'v06', 'name': 'Large Coach', 'capacity': 40, 'price_per_day': 15900},
    ]},
  ];

  static const soundEquipment = [
    {'id': 'eq01', 'name': 'Digital Audio Mixer', 'price': 3500},
    {'id': 'eq02', 'name': 'Professional Speaker', 'price': 1800},
    {'id': 'eq03', 'name': 'Wireless Microphone', 'price': 800},
    {'id': 'eq04', 'name': 'HD Projector', 'price': 4500},
    {'id': 'eq05', 'name': 'Projection Screen', 'price': 1800},
    {'id': 'eq06', 'name': 'LED Display Panel', 'price': 2500},
    {'id': 'eq07', 'name': 'Stage Light', 'price': 500},
    {'id': 'eq08', 'name': 'Sound Operator', 'price': 2500},
  ];

  static const decorationServices = [
    {'id': 'ds01', 'name': 'Stage Decoration', 'price': 8000},
    {'id': 'ds02', 'name': 'Printed Backdrop', 'price': 4500},
    {'id': 'ds03', 'name': 'Floral Arrangement', 'price': 6000},
    {'id': 'ds04', 'name': 'Ambient Lighting', 'price': 5000},
    {'id': 'ds05', 'name': 'Entrance Gate', 'price': 4500},
    {'id': 'ds06', 'name': 'Table Centerpiece', 'price': 500},
    {'id': 'ds07', 'name': 'Balloon Installation', 'price': 3500},
    {'id': 'ds08', 'name': 'Welcome Signage', 'price': 1800},
    {'id': 'ds09', 'name': 'Corporate Branding Panel', 'price': 3000},
  ];

  static const photographyServices = [
    {'id': 'ps01', 'name': 'Event Photography', 'price': 8000},
    {'id': 'ps02', 'name': 'Event Videography', 'price': 10000},
    {'id': 'ps03', 'name': 'Cinematic Highlight Film', 'price': 12000},
    {'id': 'ps04', 'name': 'Drone Coverage', 'price': 7000},
    {'id': 'ps05', 'name': 'Live Event Coverage', 'price': 6000},
    {'id': 'ps06', 'name': 'Speaker Portrait Session', 'price': 3500},
    {'id': 'ps07', 'name': 'Guest Interview Clips', 'price': 5000},
  ];

  static const bookingRules = {
    'food_total_formula': 'sum(selected_item.price * selected_item.quantity)',
    'transport_total_formula': 'vehicle.price_per_day * quantity * rental_days',
    'hall_availability_check_required': true,
    'provider_availability_check_required': true,
    'skipped_category_creates_booking': false,
    'currency': 'BDT',
  };
}

class ConferenceSeedData {
  static const _images = {
    'hall':
        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1200&q=80',
    'food':
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1200&q=80',
    'sound':
        'https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1200&q=80',
    'decoration':
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=1200&q=80',
    'photography':
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
    'transportation':
        'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=80',
  };

  static final List<Map<String, dynamic>> halls =
      ConferenceExpandedData.halls.map((record) {
    final provider = _common(record, 'hall');
    final facilities = (record['facilities'] as List?) ?? const [];
    provider.addAll({
      'price_per_day': record['price'],
      'ac': facilities.contains('AC'),
      'wifi': facilities.contains('WiFi'),
      'parking': facilities.contains('Parking'),
    });
    return provider;
  }).toList();

  static final List<Map<String, dynamic>> foods =
      ConferenceExpandedData.foods.map((record) {
    final packages = <String, List<Map<String, dynamic>>>{};
    for (final meal in ['breakfast', 'lunch', 'dinner']) {
      packages[meal] = ConferenceExpandedData.foodItems
          .where((item) => item['meal'] == meal)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return {
      ..._common(record, 'food'),
      'packages': packages,
    };
  }).toList();

  static final List<Map<String, dynamic>> foodItems =
      ConferenceExpandedData.foodItems.map((item) {
    return {
      ...Map<String, dynamic>.from(item),
      'image_url': _images['food'],
    };
  }).toList();

  static final List<Map<String, dynamic>> sounds =
      ConferenceExpandedData.sounds.map((record) {
    final packages = (record['packages'] as List?) ?? const [];
    return {
      ..._common(record, 'sound'),
      'packs': packages.map((raw) {
        final item = Map<String, dynamic>.from(raw as Map);
        final inclusions = item['includes'];
        return {
          ...item,
          'details': inclusions is List ? inclusions.join(', ') : '',
        };
      }).toList(),
    };
  }).toList();

  static final List<Map<String, dynamic>> decorations =
      ConferenceExpandedData.decorations.map((record) {
    final packages = (record['packages'] as List?) ?? const [];
    return {
      ..._common(record, 'decoration'),
      'packs': packages.map((raw) {
        final item = Map<String, dynamic>.from(raw as Map);
        final inclusions = item['includes'];
        return {
          ...item,
          'details': inclusions is List ? inclusions.join(', ') : '',
        };
      }).toList(),
    };
  }).toList();

  static final List<Map<String, dynamic>> photography =
      ConferenceExpandedData.photography.map((record) {
    final packages = (record['packages'] as List?) ?? const [];
    return {
      ..._common(record, 'photography'),
      'packs': packages.map((raw) {
        final item = Map<String, dynamic>.from(raw as Map);
        return {
          ...item,
          'details':
              '${item['hours'] ?? 0} hours · '
              '${item['photographers'] ?? 0} photographers · '
              '${item['videographers'] ?? 0} videographers · '
              'Drone ${item['drone'] == true ? 'included' : 'not included'} · '
              '${item['edited_photos'] ?? 0} edited photos · '
              '${item['delivery_days'] ?? 0} day delivery',
        };
      }).toList(),
    };
  }).toList();

  static final List<Map<String, dynamic>> transport =
      ConferenceExpandedData.transport.map((record) {
    return {
      ..._common(record, 'transportation'),
      'cars': record['vehicles'],
    };
  }).toList();

  static Map<String, dynamic> _common(
    Map<dynamic, dynamic> source,
    String category,
  ) {
    final record = Map<String, dynamic>.from(source);
    final city = (record['city'] ?? record['location'] ?? 'Dhaka').toString();
    return {
      ...record,
      'city': city,
      'location': city,
      'image': record['image'] ?? record['image_url'] ?? _images[category],
      'demo_notice': 'Demo listing; provider details are not verified.',
    };
  }
}