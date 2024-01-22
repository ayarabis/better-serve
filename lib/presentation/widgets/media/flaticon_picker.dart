import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlatIconPicker extends StatefulWidget {
  final dynamic Function() toggleLoadding;
  final Widget Function(String) imageBuilder;
  const FlatIconPicker(
      this.toggleLoadding, Null Function(String value) onSelect,
      {super.key, required this.imageBuilder});

  @override
  State<FlatIconPicker> createState() => _FlatIconPickerState();
}

class _FlatIconPickerState extends State<FlatIconPicker> {
  final TextEditingController _searchController = TextEditingController();

  late SharedPreferences prefs;
  static String token = "";

  List<String> images = List.empty(growable: true);

  String searchTerm = "food";
  int selectedPage = 1;
  int totalPages = 0;

  bool loading = true;

  dynamic requestToken() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString("flaticon_key") ?? "";
    final response = await http.post(
        Uri.parse("https://api.flaticon.com/v3/app/authentication"),
        body: {"apikey": dotenv.env['FLATICON_KEY']});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      token = body["data"]["token"];
      prefs.setString("flaticon_key", token);
    }
  }

  @override
  void initState() {
    loadIcons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading && images.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(MdiIcons.imageSearch),
                    hintText: "Search Icon",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    suffixIcon: IconButton(
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () {
                  searchTerm = _searchController.text.isNotEmpty
                      ? _searchController.text
                      : "food";
                  selectedPage = 1;
                  loadIcons();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                icon: const Icon(MdiIcons.magnify),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            if (images.isNotEmpty)
              for (String img in images) widget.imageBuilder(img)
            else
              const Center(
                child: Text("No icons available"),
              )
          ],
        ),
        Pagination(
          numOfPages: totalPages,
          selectedPage: selectedPage,
          pagesVisible: 5,
          onPageChanged: (page) {
            setState(() {
              selectedPage = page;
              loadIcons();
            });
          },
          nextIcon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
            size: 14,
          ),
          previousIcon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
            size: 14,
          ),
          activeTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          activeBtnStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
          ),
          inactiveBtnStyle: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
          ),
          inactiveTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> loadIcons() async {
    if (!loading) {
      widget.toggleLoadding();
    }
    final headers = {
      'Accept': 'application/json',
      'Authorization': "Bearer $token"
    };
    final response = await http.get(
      Uri.parse(
          "https://api.flaticon.com/v3/search/icons/added?q=$searchTerm&page=$selectedPage"),
      headers: headers,
    );
    if (response.statusCode == 401) {
      await requestToken();
      await loadIcons();
      return;
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    List<dynamic> items = body["data"];
    Map<String, dynamic> meta = body["metadata"];
    if (!loading) {
      widget.toggleLoadding();
    }
    setState(() {
      totalPages = (meta["total"] / 100).ceil();
      images = items.map((t) => t["images"]["512"].toString()).toList();
      loading = false;
    });
  }
}
