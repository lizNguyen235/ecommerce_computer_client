
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TimePeriod { daily, weekly, monthly, quarterly, yearly, custom }
class TimeFilterResult {
  final DateTime startDate;
  final DateTime endDate;
  final TimePeriod period;
  final String displayLabel;

  TimeFilterResult({
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.displayLabel,
  });

  @override
  String toString() {
    return 'TimeFilterResult(period: $period, label: $displayLabel, start: ${startDate.toIso8601String()}, end: ${endDate.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeFilterResult &&
        other.startDate.isAtSameMomentAs(startDate) &&
        other.endDate.isAtSameMomentAs(endDate) &&
        other.period == period &&
        other.displayLabel == displayLabel;
  }

  @override
  int get hashCode =>
      startDate.hashCode ^
      endDate.hashCode ^
      period.hashCode ^
      displayLabel.hashCode;
}

// Lớp tiện ích cho logic tính toán, có thể đặt ở đây hoặc file riêng
class TimeFilterLogic {
  static String getDisplayLabelForPeriod(TimePeriod period, DateTime? start, DateTime? end) {
    switch (period) {
      case TimePeriod.daily:
        return "Today";
      case TimePeriod.weekly:
        return "This Week";
      case TimePeriod.monthly:
        return "This Month";
      case TimePeriod.quarterly:
        return "This Quarter";
      case TimePeriod.yearly:
        return "This Year";
      case TimePeriod.custom:
        if (start != null && end != null) {
          // Kiểm tra start và end có cùng ngày không
          if (start.year == end.year && start.month == end.month && start.day == end.day) {
            return DateFormat.yMd().format(start);
          }
          return "${DateFormat.yMd().format(start)} - ${DateFormat.yMd().format(end)}";
        }
        return "Custom Range";
    }
  }

  static TimeFilterResult calculateTimeFilterResult({
    required TimePeriod period,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    DateTime now = DateTime.now();
    DateTime startDate, endDate;

    switch (period) {
      case TimePeriod.daily:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case TimePeriod.weekly:
        int currentWeekday = now.weekday; // Monday is 1, Sunday is 7
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: currentWeekday - DateTime.monday));
        endDate = startDate.add(const Duration(
            days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
        break;
      case TimePeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999); // Day 0 of next month is last day of current
        break;
      case TimePeriod.quarterly:
        int quarterStartMonth;
        if (now.month <= 3)
          quarterStartMonth = 1;
        else if (now.month <= 6)
          quarterStartMonth = 4;
        else if (now.month <= 9)
          quarterStartMonth = 7;
        else
          quarterStartMonth = 10;
        startDate = DateTime(now.year, quarterStartMonth, 1);
        endDate = DateTime(now.year, quarterStartMonth + 3, 0, 23, 59, 59, 999);
        break;
      case TimePeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59, 999);
        break;
      case TimePeriod.custom:
        if (customStart != null && customEnd != null) {
          startDate = DateTime(customStart.year, customStart.month, customStart.day);
          // Ensure endDate is at the end of its day
          endDate = DateTime(customEnd.year, customEnd.month, customEnd.day, 23, 59, 59, 999);
          // Ensure startDate is before or same as endDate
          if (endDate.isBefore(startDate)) {
            endDate = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59, 999); // Default to same day if invalid range
          }
        } else {
          // Default for custom if dates are null (should ideally not happen if UI enforces selection)
          // Or, this could be an indicator that custom range is not yet set
          // For calculation purposes, if custom is selected but no dates, default to 'Today'
          print(
            "DEBUG_WIDGET: calculateTimeFilterResult - Custom period selected but no dates, defaulting to today.",
          );
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        }
        break;
    }
    return TimeFilterResult(
      startDate: startDate,
      endDate: endDate,
      period: period,
      displayLabel: getDisplayLabelForPeriod(period, startDate, endDate),
    );
  }
}

class TimeFilterWidget extends StatefulWidget {
  final Function(TimeFilterResult result) onFilterChanged;
  final TimePeriod initialPeriod;
  final DateTime? initialCustomStartDate;
  final DateTime? initialCustomEndDate;

  const TimeFilterWidget({
    super.key,
    required this.onFilterChanged,
    this.initialPeriod = TimePeriod.monthly,
    this.initialCustomStartDate,
    this.initialCustomEndDate,
  });

  @override
  State<TimeFilterWidget> createState() => _TimeFilterWidgetState();
}

class _TimeFilterWidgetState extends State<TimeFilterWidget> {
  late TimePeriod _selectedPeriod;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isMountedWidget = false;

  @override
  void initState() {
    super.initState();
    _isMountedWidget = true;
    _selectedPeriod = widget.initialPeriod;
    if (widget.initialPeriod == TimePeriod.custom) {
      _customStartDate = widget.initialCustomStartDate;
      _customEndDate = widget.initialCustomEndDate;
    }
    print(
      "DEBUG_WIDGET: TimeFilterWidget initState - Initial Period: ${widget.initialPeriod}, Selected: $_selectedPeriod, CustomStart: $_customStartDate, CustomEnd: $_customEndDate. Widget mounted: $_isMountedWidget",
    );
    // KHÔNG gọi _notifyCaller() ở đây. DashboardScreen sẽ xử lý load ban đầu.
    print("DEBUG_WIDGET: TimeFilterWidget initState - END");
  }

  @override
  void didUpdateWidget(TimeFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
      "DEBUG_WIDGET: TimeFilterWidget didUpdateWidget - oldInitial: ${oldWidget.initialPeriod}, newInitial: ${widget.initialPeriod}, currentSelected: $_selectedPeriod, newCustomStart: ${widget.initialCustomStartDate}, newCustomEnd: ${widget.initialCustomEndDate}",
    );

    bool needsStateUpdate = false;

    if (widget.initialPeriod != _selectedPeriod) {
      needsStateUpdate = true;
    } else if (widget.initialPeriod == TimePeriod.custom) {
      // Check if custom dates themselves have changed if passed in
      bool customDatesDifferent = false;
      if (widget.initialCustomStartDate != null && _customStartDate != null) {
        if (!widget.initialCustomStartDate!.isAtSameMomentAs(_customStartDate!)) customDatesDifferent = true;
      } else if (widget.initialCustomStartDate != _customStartDate) { // One is null, other is not
        customDatesDifferent = true;
      }

      if (widget.initialCustomEndDate != null && _customEndDate != null) {
        if (!widget.initialCustomEndDate!.isAtSameMomentAs(_customEndDate!)) customDatesDifferent = true;
      } else if (widget.initialCustomEndDate != _customEndDate) { // One is null, other is not
        customDatesDifferent = true;
      }

      if (customDatesDifferent) {
        needsStateUpdate = true;
      }
    }


    if (needsStateUpdate && _isMountedWidget) {
      print(
        "DEBUG_WIDGET: TimeFilterWidget didUpdateWidget - External change detected or internal state mismatch. Updating internal state.",
      );
      setState(() {
        _selectedPeriod = widget.initialPeriod;
        if (_selectedPeriod == TimePeriod.custom) {
          _customStartDate = widget.initialCustomStartDate;
          _customEndDate = widget.initialCustomEndDate;
        } else {
          _customStartDate = null;
          _customEndDate = null;
        }
      });
      // Không gọi _notifyCaller() ở đây vì thay đổi này đến từ DashboardScreen
      // việc cập nhật state nội bộ là để widget hiển thị đúng.
    }
  }

  @override
  void dispose() {
    _isMountedWidget = false;
    print("DEBUG_WIDGET: TimeFilterWidget dispose");
    super.dispose();
  }

  void _notifyCaller() {
    if (!_isMountedWidget) {
      print(
        "DEBUG_WIDGET: TimeFilterWidget _notifyCaller - Widget is unmounted. Aborting notification.",
      );
      return;
    }
    final result = TimeFilterLogic.calculateTimeFilterResult(
      period: _selectedPeriod,
      customStart: _customStartDate,
      customEnd: _customEndDate,
    );
    print(
      "DEBUG_WIDGET: TimeFilterWidget _notifyCaller - Calling onFilterChanged with: ${result.toString()}",
    );
    widget.onFilterChanged(result);
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future dates for custom range selection
      helpText: 'Select Custom Date Range',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white, // Text on primary color buttons
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && _isMountedWidget) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedPeriod = TimePeriod.custom;
      });
      _notifyCaller();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      "DEBUG_WIDGET: TimeFilterWidget build - Selected Period: $_selectedPeriod. CustomStart: $_customStartDate, CustomEnd: $_customEndDate",
    );
    final dropdownItems =
    TimePeriod.values.where((p) => p != TimePeriod.custom).map((
        TimePeriod period,
        ) {
      // Sử dụng TimeFilterLogic để lấy label cho dropdown items
      final label = TimeFilterLogic.getDisplayLabelForPeriod(period, null, null);
      return DropdownMenuItem<TimePeriod>(
        value: period,
        child: Text(label),
      );
    }).toList();

    // Xác định label cho nút custom
    String customButtonLabel = "Custom Range";
    if (_selectedPeriod == TimePeriod.custom &&
        _customStartDate != null &&
        _customEndDate != null) {
      customButtonLabel = TimeFilterLogic.getDisplayLabelForPeriod(
        TimePeriod.custom,
        _customStartDate,
        _customEndDate,
      );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TimePeriod>(
                  value: _selectedPeriod == TimePeriod.custom ? null : _selectedPeriod,
                  hint: const Text("Select Period"),
                  isDense: true,
                  items: dropdownItems,
                  onChanged: (TimePeriod? newValue) {
                    if (newValue != null &&
                        newValue != TimePeriod.custom &&
                        _isMountedWidget) {
                      setState(() {
                        _selectedPeriod = newValue;
                        _customStartDate = null; // Reset custom dates when a predefined period is chosen
                        _customEndDate = null;
                      });
                      _notifyCaller();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(
                customButtonLabel,
                style: TextStyle(
                  color: _selectedPeriod == TimePeriod.custom ? Theme.of(context).primaryColor : null,
                  fontWeight: _selectedPeriod == TimePeriod.custom ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                side: BorderSide(
                  color: _selectedPeriod == TimePeriod.custom
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor,
                  width: _selectedPeriod == TimePeriod.custom ? 1.5 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _selectCustomDateRange(context),
            ),
          ],
        ),
      ),
    );
  }
}