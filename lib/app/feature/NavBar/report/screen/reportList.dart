import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tima/app/core/GWidgets/btnText.dart';
import 'package:tima/app/core/constants/colorConst.dart';
import 'package:tima/app/core/constants/textconst.dart';
import 'package:tima/app/feature/NavBar/report/builder/reportBuilder.dart';

class Reportlist extends StatefulWidget {
  const Reportlist({super.key});

  @override
  State<Reportlist> createState() => _ReportlistState();
}

class _ReportlistState extends ReportScreenBuilder {
  bool isShowNxtVisitStartLabel = true;
  bool isShowNxtVisitEndLabel = true;
  bool isShowInquriyStartLabel = true;
  bool isShowInquiryEndLabel = true;
  bool isShowAttendencStartLabel = true;
  bool isShowAttendenceEndLabel = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'REPORTS',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: colorConst.primarycolor,
              letterSpacing: 1.2,
            ),
          ),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            indicatorColor: colorConst.primarycolor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Colors.grey,
            labelColor: colorConst.primarycolor,
            tabs: [
              Tab(
                icon: Icon(Icons.calendar_today_rounded, size: 22.sp),
                text: 'Next Visit',
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 22.sp),
                text: 'Visit',
              ),
              Tab(
                icon: Icon(Icons.person_outline_rounded, size: 22.sp),
                text: 'Attendance',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              size,
              isStartDate: isShowNxtVisitStartLabel,
              isEndDate: isShowNxtVisitEndLabel,
              isLoading: nextVisitLoad,
              isEmpty: nextVisitDataModelList.isEmpty,
              emptyMessage: nextVisitMessage,
              itemCount: nextVisitDataModelList.length,
              itemBuilder: (context, index) => _buildNextVisitCard(nextVisitDataModelList[index]),
            ),
            _buildTabContent(
              size,
              isStartDate: isShowInquriyStartLabel,
              isEndDate: isShowInquiryEndLabel,
              isLoading: enquiryVisitDetailLoad,
              isEmpty: inquiryVisitDetailList.isEmpty,
              emptyMessage: inquiryVisitMessage.toString(),
              itemCount: inquiryVisitDetailList.length,
              itemBuilder: (context, index) => _buildVisitCard(inquiryVisitDetailList[index]),
            ),
            _buildTabContent(
              size,
              isStartDate: isShowAttendencStartLabel,
              isEndDate: isShowAttendenceEndLabel,
              isLoading: attendanceDataLoad,
              isEmpty: attendanceDataList.isEmpty,
              emptyMessage: attendanceMessage,
              itemCount: attendanceDataList.length,
              itemBuilder: (context, index) => _buildAttendanceCard(attendanceDataList[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    Size size, {
    required bool isStartDate,
    required bool isEndDate,
    required bool isLoading,
    required bool isEmpty,
    required String emptyMessage,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          _buildDateSelectors(size, isStartDate, isEndDate),
          SizedBox(height: 16.h),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : isEmpty
                    ? Center(
                        child: Text(
                          emptyMessage,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: colorConst.primarycolor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: itemCount,
                        itemBuilder: itemBuilder,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectors(Size size, bool showStart, bool showEnd) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showStart) ...[
            Text(
              'Start Date',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorConst.primarycolor,
              ),
            ),
            SizedBox(height: 8.h),
            _buildDateSelector(
              size,
              startDateController.toString(),
              () => selectStartDate(context),
            ),
          ],
          if (showEnd) ...[
            SizedBox(height: 16.h),
            Text(
              'End Date',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorConst.primarycolor,
              ),
            ),
            SizedBox(height: 8.h),
            _buildDateSelector(
              size,
              endDateController.toString(),
              () => selectEndDate(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(Size size, String date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 50.h,
        width: size.width,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20.sp,
              color: colorConst.primarycolor,
            ),
            SizedBox(width: 12.w),
            Text(
              date,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextVisitCard(dynamic details) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Client/Vendor", details.client),
            _buildInfoRow("Product/Service", details.productService),
            _buildInfoRow(
              "Last Visit",
              DateFormat.yMd().add_jm().format(details.startAt),
            ),
            _buildInfoRow(
              "Next Visit",
              DateFormat.yMd().add_jm().format(details.nextVisit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(dynamic details) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Visit At", details.visitAt),
            _buildInfoRow("Client/Vendor", details.vendor ?? details.client),
            _buildInfoRow("Product/Services", details.productService),
            _buildInfoRow(
              "Visit Date",
              DateFormat.yMMMMd('en_US').format(details.startAt!),
            ),
            _buildInfoRow("Person Name", details.personName),
            _buildInfoRow("Person Mobile", details.personMobile),
            _buildInfoRow("Duration", details.duration),
            _buildInfoRow("Order", details.orderDone),
            _buildInfoRow("Complaints", details.queryComplaint),
            _buildInfoRow("Remark", details.remark),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic details) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Date", details.attDate),
            _buildInfoRow("Check In", details.inTime ?? "N/A"),
            _buildInfoRow("Check Out", details.outTime ?? "N/A"),
            _buildInfoRow("Status", details.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
