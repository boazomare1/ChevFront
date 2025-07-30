import 'dart:convert';
import 'dart:io';
import 'package:chevenergies/models/county.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/shared utils/widgets.dart';
import 'package:geolocator/geolocator.dart';

class AddShopScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const AddShopScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  List<County> counties = [];
  List<String> subCounties = [];
  String? selectedCounty;
  String? selectedTown;

  Future<void> _loadCounties() async {
    final String jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/county_data.json');
    final List<dynamic> data = json.decode(jsonString);
    setState(() {
      counties = data.map((e) => County.fromJson(e)).toList();
    });
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  final _formKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final countyController = TextEditingController();
  final townController = TextEditingController();

  File? logoFile;
  String? logoBase64;

  bool loading = false;

  Future<void> _pickLogoImage() async {
    final picker = ImagePicker();
    final pic = await picker.pickImage(source: ImageSource.gallery);
    if (pic != null) {
      final bytes = await pic.readAsBytes();
      setState(() {
        logoFile = File(pic.path);
        logoBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> _submitShop() async {
    if (!_formKey.currentState!.validate()) {
      return showDialog(
        context: context,
        builder:
            (_) =>
                const ErrorDialog(message: "Please fill all required fields."),
      );
    }

    setState(() => loading = true);

    try {
      final position = await _getCurrentPosition();

      await Provider.of<AppState>(context, listen: false).createShop(
        shopName: shopNameController.text,
        customerId: widget.customerId,
        phone: phoneController.text,
        email: emailController.text,
        county: selectedCounty ?? '',
        town: selectedTown ?? '',
        latitude: position.latitude,
        longitude: position.longitude,
        logoBase64: logoBase64 ?? '',
      );

      setState(() => loading = false);

      await showDialog(
        context: context,
        builder:
            (_) => SuccessDialog(
              message: "Shop for ${widget.customerName} created successfully.",
              onClose: () => Navigator.of(context).pop(),
            ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => loading = false);
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: "Failed to create shop: $e"),
      );
    }
  }

  bool _countiesLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_countiesLoaded) {
      _loadCounties();
      _countiesLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Shop for ${widget.customerName}")),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      StyledTextField(
                        label: "Shop Name",
                        controller: shopNameController,
                      ),
                      StyledTextField(
                        label: "Phone",
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      StyledTextField(
                        label: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      DropdownSearch<String>(
                        items: counties.map((c) => c.name).toList(),
                        selectedItem: selectedCounty,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "County",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: "Search County",
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedCounty = value;
                            selectedTown = null;
                            subCounties =
                                counties
                                    .firstWhere((c) => c.name == value)
                                    .subCounties;
                          });
                        },
                        validator:
                            (value) => value == null ? 'Select a county' : null,
                      ),

                      const SizedBox(height: 12),

                      DropdownSearch<String>(
                        items: subCounties,
                        selectedItem: selectedTown,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Town",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: "Search Town",
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        onChanged:
                            (value) => setState(() => selectedTown = value),
                        validator:
                            (value) => value == null ? 'Select a town' : null,
                      ),

                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickLogoImage,
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Logo"),
                      ),
                      if (logoFile != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.file(logoFile!, height: 100),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitShop,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text("Create Shop"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
