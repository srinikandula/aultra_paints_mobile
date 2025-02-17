import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../services/config.dart';
import '../../services/error_handling.dart';
import '../../utility/Utils.dart';

class PointsLedgerPage extends StatefulWidget {
  const PointsLedgerPage({Key? key}) : super(key: key);

  @override
  _PointsLedgerPageState createState() => _PointsLedgerPageState();
}

class _PointsLedgerPageState extends State<PointsLedgerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  Timer? _debounce;

  String? accesstoken;
  List<dynamic> myPointLedgerList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollmyPainterListController = ScrollController();

  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchLocalStorageData();
    _scrollmyPainterListController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollmyPainterListController.position.pixels >=
            _scrollmyPainterListController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      getPointsLedgerList();
    }
  }

  @override
  void dispose() {
    _scrollmyPainterListController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
    await getPointsLedgerList();
  }

  Future<void> getPointsLedgerList() async {
    if (isLoading || accesstoken == null || !hasMore) return;

    setState(() => isLoading = true);
    try {
      final apiUrl = "$BASE_URL$GET_TRANSACTION_LEDGER";
      var query = {
        'page': currentPage,
        'limit': 10,
        "couponCode": searchController.text.isNotEmpty
            ? int.tryParse(searchController.text)
            : null,
        "date": selectedDate != null ? _dateFormat.format(selectedDate!) : null,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": accesstoken!,
        },
        body: json.encode(query),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['transactions'] is List) {
          List<dynamic> newData = responseData['transactions'];
          if (mounted) {
            setState(() {
              myPointLedgerList.addAll(newData);
              currentPage++;
              hasMore = newData.length >= 10;
            });
          }
        }
      } else {
        error_handling.errorValidation(
          context,
          'Error fetching data',
          response.body,
          false,
        );
      }
    } catch (error) {
      error_handling.errorValidation(
        context,
        'Failed to fetch data',
        error.toString(),
        false,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 1;
        myPointLedgerList.clear();
        hasMore = true;
      });
      getPointsLedgerList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        myPointLedgerList.clear();
        currentPage = 1;
        hasMore = true;
      });
      getPointsLedgerList();
    }
  }

  Future<bool> _onWillPop() async {
    Utils.clearToasts(context);
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      Navigator.of(context).pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFF7AD),
                Color(0xFFFFA9F9),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Points Ledger',
                      style: TextStyle(
                        fontSize: unitHeightValue * 0.024,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3533CD),
                      ),
                    ),
                    // const SizedBox(width: 20),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: searchController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Coupon Code",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            // vertical: screenHeight * 0.1,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              // size: unitHeightValue * 0.024,
                            ),
                            onPressed: () =>
                                _onSearchChanged(searchController.text),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          height: screenHeight * 0,
                          // fontSize: unitHeightValue * 0.024,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                          selectedDate = null;
                          currentPage = 1;
                          myPointLedgerList.clear();
                          hasMore = true;
                        });
                        getPointsLedgerList();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: myPointLedgerList.isEmpty
                    ? Center(
                        child: Text(
                          hasMore && isLoading
                              ? "Loading..."
                              : "No data available",
                          style: TextStyle(
                            fontSize: unitHeightValue * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : _buildLedgerList(
                        screenWidth, screenHeight, unitHeightValue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerList(
      double screenWidth, double screenHeight, double unitHeightValue) {
    return Column(
      children: [
        _buildTableHeader(screenWidth, screenHeight, unitHeightValue),
        Expanded(
          child: ListView.builder(
            controller: _scrollmyPainterListController,
            itemCount: myPointLedgerList.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == myPointLedgerList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildLedgerItem(
                myPointLedgerList[index],
                screenWidth,
                screenHeight,
                unitHeightValue,
              );
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
      ],
    );
  }

  Widget _buildTableHeader(
      double screenWidth, double screenHeight, double unitHeightValue) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
      ),
      decoration: const BoxDecoration(
        color: Colors.white30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderCell("Date", screenWidth, unitHeightValue,
              flex: screenWidth > 900 ? 3 : 2),
          _buildHeaderCell("Description", screenWidth, unitHeightValue,
              flex: screenWidth > 600 ? 3 : 2),
          _buildHeaderCell("Balance", screenWidth, unitHeightValue, flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
      String text, double screenWidth, double unitHeightValue,
      {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: unitHeightValue * 0.018,
          color: const Color(0xFF3533CD),
        ),
      ),
    );
  }

  Widget _buildLedgerItem(dynamic item, double screenWidth, double screenHeight,
      double unitHeightValue) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white30,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: screenWidth > 900 ? 3 : 2,
            child: Text(
              _dateFormat.format(DateTime.parse(item['createdAt'] ?? '')),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF3533CD),
                fontSize: unitHeightValue * 0.02,
              ),
            ),
          ),
          Expanded(
            flex: screenWidth > 600 ? 3 : 2,
            child: Text(
              '${item['narration'] ?? ''} ${item['amount'] ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF3533CD),
                fontSize: unitHeightValue * 0.02,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (item['balance'] ?? '').toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF3533CD),
                fontSize: unitHeightValue * 0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
