// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tima/app/ApiService/postApiBaseHelper.dart';
import 'package:tima/app/DataBase/dataHub/secureStorageService.dart';
import 'package:tima/app/DataBase/keys/keys.dart';
import 'package:tima/app/core/constants/apiUrlConst.dart';
import 'package:tima/app/core/models/attendancemodel.dart';
import 'package:tima/app/core/models/enquiryviewdetailmodel.dart';
import 'package:tima/app/core/models/next_visit_model.dart';
import 'package:tima/app/core/models/nextvisitmodel.dart';
import 'package:tima/app/feature/NavBar/report/screen/reportList.dart';


abstract class ReportScreenBuilder extends State<Reportlist> {
  final SecureStorageService _secureStorageService = SecureStorageService();

  final client = http.Client();
  dynamic startDateController;
  dynamic endDateController;
  var nextVisitLoad = false;

  List<DatumNextVisit> nextVisitDataModelList = [];

  DateTime selectedDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String nextVisitMessage='';
  List<Datum> nextVisitDataList = [];

  List<DataList> inquiryVisitDetailList = [];
  String inquiryVisitMessage='';
  // * attendence tab

  List<AttDatum> attendanceDataList = [];
  var attendanceDataLoad = false;
  String attendanceMessage = '';

  var enquiryVisitDetailLoad = false;

  @override
  void initState() {
    startDateController = DateFormat('yyyy-MM-dd').format(selectedDate);
    endDateController = DateFormat('yyyy-MM-dd').format(selectedEndDate);
    getNextVisitApi();
    getEnquiryDetailApi();
    getAttendance();
    super.initState();
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        var date = DateFormat.yMd().format(selectedDate);
        startDateController = DateFormat('yyyy-MM-dd').format(selectedDate);
        if (endDateController != "") {
          getNextVisitApi();
          getEnquiryDetailApi();
          getAttendance();
        }
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked != null) {
      setState(() {
        selectedEndDate = picked;
        endDateController = DateFormat('yyyy-MM-dd').format(selectedEndDate);
        getNextVisitApi();
        getEnquiryDetailApi();
        getAttendance();
      });
    }
  }

  void getNextVisitApi() async {
    nextVisitLoad = true;
    setState(() {});
    String? userID =
        await _secureStorageService.getUserID(key: StorageKeys.userIDKey);
    var body = ({
      'user_id': userID.toString(),
      'from_date': startDateController.toString(),
      'to_date': endDateController.toString()
    });
    var url = show_next_visit_app_url;

    var response = await ApiBaseHelper().postAPICall(Uri.parse(url), body);

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);

      log("client NextVisitModel body -->body");
      log("client NextVisitModel response -->${response.body}");
      print("client NextVisitModel response -->${response.body}");

      NextVisitModel nextVisitModel = NextVisitModel.fromJson(decodedResponse);

      nextVisitMessage = nextVisitModel.message;

      nextVisitDataModelList = nextVisitModel.data;

      Fluttertoast.showToast(msg: decodedResponse['message']);
    }
    nextVisitLoad = false;
    setState(() {});
  }

  Future<void> getEnquiryDetailApi() async {
    enquiryVisitDetailLoad = true;

    setState(() {});

    String? userID =
        await _secureStorageService.getUserID(key: StorageKeys.userIDKey);
    var body = ({
      'user_id': userID.toString(),
      'id': "0",
      'from_date': startDateController,
      'to_date': endDateController
    });

    var url = get_visit_data_url;
    log("client getenquiry_detail body --$url");
    log("client getenquiry_detail body -->$body ");

    var response = await ApiBaseHelper().postAPICall(Uri.parse(url), body);
    log("client getenquiry_detail response --> ${response.body}");
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var enquiryVisitDetail = GetEnquiryViewDetailModel.fromJson(responseData);
      inquiryVisitDetailList = enquiryVisitDetail.data;
      inquiryVisitMessage = enquiryVisitDetail.message;

      log("client getenquiryView_detail response -->${nextVisitDataList.length} ");
      enquiryVisitDetailLoad = false;

      // Fluttertoast.showToast(msg: responseData['message']);
    }
    enquiryVisitDetailLoad = false;
    setState(() {});
  }

  void getAttendance() async {
    attendanceDataLoad = true;
    setState(() {});
    String? userID =
        await _secureStorageService.getUserID(key: StorageKeys.userIDKey);
    var body = ({
      'user_id': userID.toString(),
      'from_date': startDateController,
      'to_date': endDateController
    });

    var url = show_attendance_app_url;
    log("client attendancedata body $body");
    var response = await ApiBaseHelper().postAPICall(Uri.parse(url), body);
    log("client attendancedata response $response.body");
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var attendanceData = AttendanceModel.fromJson(responseData);
      attendanceMessage = attendanceData.message;
      attendanceDataList = attendanceData.data;
    }
    attendanceDataLoad = false;
    setState(() {});
  }
}
