import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gramcare/frontend/patients/editpatientprofile.dart';
import 'package:http/http.dart' as http;

const String apiBase = 'http://192.168.137.1:4001';

class PatientProfileScreen extends StatefulWidget {
  final String username; // patients.login
  const PatientProfileScreen({super.key, required this.username});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  int _navIndex = 0;

  // Remote state
  bool _loading = true;
  String? _error;

  // Profile fields
  String fullName = '';
  String gender = '';
  String dob = ''; // DD/MM/YYYY
  int? age;
  String patientId = '';
  String primaryPhone = '';
  String email = '';
  String address = '';
  String govId = '';
  String language = '';

  // Emergency
  String emergencyName = '';
  String emergencyPhone = '';

  // Medical basics
  String conditions = '';
  String allergies = '';
  String chronicMeds = '';
  String vitals = '';
  String bloodGroup = '';

  // Care preferences
  String pharmacy = '';
  String primaryDoctor = '';
  String consentTreatment = '';
  String consentResearch = '';

  // Insurance
  String insuranceProvider = '';
  String policyNumber = '';

  // Devices
  String device = '';
  String lastSync = '';

  // Activity log (example)
  List<Map<String, String>> activity = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Uri _buildUri(String path, [Map<String, String>? q]) {
    final base = Uri.parse(apiBase);
    final basePath =
        base.path.endsWith('/')
            ? base.path.substring(0, base.path.length - 1)
            : base.path;
    return base.replace(path: '$basePath$path', queryParameters: q);
  }

  int _ageFromDob(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    if (parts.length != 3) return 0;
    final d = int.tryParse(parts[0]) ?? 1;
    final m = int.tryParse(parts[1]) ?? 1;
    final y = int.tryParse(parts[2]) ?? DateTime.now().year;
    final birth = DateTime(y, m, d);
    final now = DateTime.now();
    int a = now.year - birth.year;
    final hadBirthday =
        (now.month > birth.month) ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) a -= 1;
    return a < 0 ? 0 : a;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = _buildUri('/api/patient-details', {'login': widget.username});
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;

        // Basic
        fullName = (map['fullName'] ?? '').toString();
        gender = (map['gender'] ?? '').toString();
        dob = (map['dob'] ?? '').toString();
        age = dob.isNotEmpty ? _ageFromDob(dob) : null;
        patientId = (map['patientId'] ?? '').toString();

        // Contact
        primaryPhone = (map['primaryPhone'] ?? '').toString();
        email = (map['email'] ?? '').toString();
        address = (map['address'] ?? '').toString();
        govId = (map['govId'] ?? '').toString();
        language = (map['language'] ?? '').toString();

        // Emergency
        emergencyName = (map['emergencyName'] ?? '').toString();
        emergencyPhone = (map['emergencyPhone'] ?? '').toString();

        // Medical basics (optional fields)
        conditions = (map['conditions'] ?? '').toString();
        allergies = (map['allergies'] ?? '').toString();
        chronicMeds = (map['chronicMeds'] ?? '').toString();
        vitals = (map['vitals'] ?? '').toString();
        bloodGroup = (map['bloodGroup'] ?? '').toString();

        // Preferences
        pharmacy = (map['pharmacy'] ?? '').toString();
        primaryDoctor = (map['primaryDoctor'] ?? '').toString();
        consentTreatment = (map['consentTreatment'] ?? 'Yes').toString();
        consentResearch = (map['consentResearch'] ?? 'Yes').toString();

        // Insurance
        insuranceProvider = (map['insuranceProvider'] ?? '').toString();
        policyNumber = (map['policyNumber'] ?? '').toString();

        // Devices
        device = (map['device'] ?? '').toString();
        lastSync = (map['lastSync'] ?? '').toString();

        // Activity (sample)
        activity = [
          {'when': '2 days ago', 'what': 'Appointment scheduled'},
          {'when': '1 week ago', 'what': 'Medication prescribed'},
        ];

        if (!mounted) return;
        setState(() => _loading = false);
      } else if (resp.statusCode == 404) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Profile not found';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Failed: ${resp.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Network error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _TopBar(),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2.4))
              : (_error != null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  )
                  : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 6),
                              ProfileHeader(
                                fullName:
                                    fullName.isEmpty
                                        ? widget.username
                                        : fullName,
                                ageGender: [
                                  if (age != null) '$age',
                                  if (gender.isNotEmpty) gender,
                                ].join(', '),
                                patientId: patientId.isEmpty ? '—' : patientId,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Contact Details',
                          tiles: [
                            InfoTile(
                              icon: Icons.phone_outlined,
                              title: 'Phone',
                              subtitle:
                                  primaryPhone.isEmpty ? '—' : primaryPhone,
                            ),
                            InfoTile(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              subtitle: email.isEmpty ? '—' : email,
                            ),
                            InfoTile(
                              icon: Icons.location_on_outlined,
                              title: 'Address',
                              subtitle: address.isEmpty ? '—' : address,
                            ),
                            InfoTile(
                              icon: Icons.badge_outlined,
                              title: 'Government ID',
                              subtitle: govId.isEmpty ? '—' : govId,
                            ),
                            InfoTile(
                              icon: Icons.language_outlined,
                              title: 'Language Preference',
                              subtitle: language.isEmpty ? '—' : language,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Emergency Contacts',
                          tiles: [
                            InfoTile(
                              icon: Icons.person_pin_circle_outlined,
                              title:
                                  emergencyName.isEmpty ? '—' : emergencyName,
                              subtitle:
                                  emergencyPhone.isEmpty ? '—' : emergencyPhone,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Medical Basics',
                          tiles: [
                            InfoTile(
                              icon: Icons.water_drop_outlined,
                              title: 'Blood Group',
                              subtitle: bloodGroup.isEmpty ? '—' : bloodGroup,
                            ),
                            InfoTile(
                              icon: Icons.favorite_border,
                              title: 'Vitals',
                              subtitle: vitals.isEmpty ? '—' : vitals,
                            ),
                            InfoTile(
                              icon: Icons.view_list_outlined,
                              title: 'Conditions',
                              subtitle: conditions.isEmpty ? '—' : conditions,
                            ),
                            InfoTile(
                              icon: Icons.medication_outlined,
                              title: 'Allergies',
                              subtitle: allergies.isEmpty ? '—' : allergies,
                            ),
                            InfoTile(
                              icon: Icons.draw_outlined,
                              title: 'Chronic Meds',
                              subtitle: chronicMeds.isEmpty ? '—' : chronicMeds,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Care Preferences',
                          tiles: [
                            InfoTile(
                              icon: Icons.local_pharmacy_outlined,
                              title: 'Pharmacy',
                              subtitle: pharmacy.isEmpty ? '—' : pharmacy,
                            ),
                            InfoTile(
                              icon: Icons.person_outline,
                              title: 'Primary Doctor',
                              subtitle:
                                  primaryDoctor.isEmpty ? '—' : primaryDoctor,
                            ),
                            InfoTile(
                              icon: Icons.check_box_outlined,
                              title: 'Consent for Treatment',
                              subtitle:
                                  consentTreatment.isEmpty
                                      ? '—'
                                      : consentTreatment,
                            ),
                            InfoTile(
                              icon: Icons.check_box_outlined,
                              title: 'Consent for Research',
                              subtitle:
                                  consentResearch.isEmpty
                                      ? '—'
                                      : consentResearch,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Insurance Details',
                          tiles: [
                            InfoTile(
                              icon: Icons.apartment_outlined,
                              title: 'Provider',
                              subtitle:
                                  insuranceProvider.isEmpty
                                      ? '—'
                                      : insuranceProvider,
                            ),
                            InfoTile(
                              icon: Icons.numbers_outlined,
                              title: 'Policy Number',
                              subtitle:
                                  policyNumber.isEmpty ? '—' : policyNumber,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Linked Devices',
                          tiles: [
                            InfoTile(
                              icon: Icons.watch_outlined,
                              title: 'Device',
                              subtitle: device.isEmpty ? '—' : device,
                            ),
                            InfoTile(
                              icon: Icons.history_toggle_off_outlined,
                              title: 'Last Sync',
                              subtitle: lastSync.isEmpty ? '—' : lastSync,
                            ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SectionBlock(
                          title: 'Activity Log',
                          tiles:
                              activity.isEmpty
                                  ? [
                                    const InfoTile(
                                      icon: Icons.info_outline,
                                      title: 'No recent activity',
                                      subtitle: '—',
                                    ),
                                  ]
                                  : activity
                                      .map(
                                        (e) => InfoTile(
                                          icon: Icons.event_available_outlined,
                                          title: (e['when'] ?? '—'),
                                          subtitle: (e['what'] ?? '—'),
                                        ),
                                      )
                                      .toList(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButton(
                                      text: 'Edit Profile',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => EditProfileScreen(
                                                  username: widget.username,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TertiaryButton(
                                      text: 'View QR',
                                      onTap: _noop,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i, label) => setState(() => _navIndex = i),
      ),
    );
  }
}

void _noop() {}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        onPressed: () => Navigator.maybePop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Patient Profile',
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String ageGender;
  final String patientId;
  const ProfileHeader({
    super.key,
    this.fullName = '—',
    this.ageGender = '—',
    this.patientId = '—',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xFFF3E7E3),
          backgroundImage: AssetImage('dummy_image.png'),
        ),
        const SizedBox(height: 10),
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          ageGender,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Patient ID: $patientId',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class SectionBlock extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const SectionBlock({super.key, required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          ...tiles,
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            child: Icon(icon, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle.isEmpty ? '—' : subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1E40FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TertiaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const TertiaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE6EAF0)),
          foregroundColor: const Color(0xFF111827),
          backgroundColor: const Color(0xFFF8F9FB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final void Function(int, String) onTap;
  const _BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItemData(Icons.dashboard_outlined, 'Dashboard'),
      _NavItemData(Icons.people_alt_outlined, 'Patients'),
      _NavItemData(Icons.chat_bubble_outline, 'Messages'),
      _NavItemData(Icons.event_note_outlined, 'Schedule'),
      _NavItemData(Icons.settings_outlined, 'Settings'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == index;
            final color =
                selected ? const Color(0xFF2563EB) : const Color(0xFF98A2B3);
            return InkWell(
              onTap: () => onTap(i, items[i].label),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon, color: color, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}
