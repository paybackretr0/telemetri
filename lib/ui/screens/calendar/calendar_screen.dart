import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_provider.dart';
import '../../../utils/date_formatter.dart';
import '../../widgets/custom_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late CalendarProvider _provider;
  List<Map<String, dynamic>> _filteredEvents = [];
  bool _showingAllEvents = false;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = Provider.of<CalendarProvider>(context, listen: false);
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    await _provider.getEvents();

    if (_provider.needsReauthentication) {
      _showReauthenticationDialog();
    } else {
      _filterEventsBySelectedDay();
      _generateEventsMap();
    }
  }

  Future<void> _refreshToken() async {
    final success = await _provider.refreshToken();

    if (success) {
      await _loadEvents();
    } else if (_provider.needsReauthentication) {
      _showReauthenticationDialog();
    }
  }

  void _generateEventsMap() {
    _events = {};

    for (var event in _provider.formattedEvents) {
      final parts = event['date'].split('/');
      if (parts.length != 3) continue;

      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final eventDate = DateTime(year, month, day);

        if (_events[eventDate] != null) {
          _events[eventDate]!.add(event);
        } else {
          _events[eventDate] = [event];
        }
      } catch (e) {
        // Abaikan jika format tanggal tidak valid
      }
    }

    setState(() {});
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _filterEventsBySelectedDay() {
    if (_selectedDay == null) return;

    setState(() {
      _filteredEvents =
          _provider.formattedEvents.where((event) {
            final parts = event['date'].split('/');
            if (parts.length != 3) return false;

            try {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);

              final eventDate = DateTime(year, month, day);
              return isSameDay(eventDate, _selectedDay);
            } catch (e) {
              return false;
            }
          }).toList();
    });
  }

  void _showAllEvents() {
    setState(() {
      _showingAllEvents = true;
      _filteredEvents = _provider.formattedEvents;
    });
  }

  void _showReauthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Autentikasi Diperlukan'),
          content: const Text(
            'Token kadaluarsa, silakan refresh dengan klik tombol di bawah ini.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: Consumer<CalendarProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shadowColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.3),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2025, 1, 1),
                        lastDay: DateTime.utc(2035, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        eventLoader: _getEventsForDay,
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          decoration: BoxDecoration(color: Colors.white),
                          headerMargin: EdgeInsets.only(bottom: 12.0),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          weekendStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          weekendTextStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          outsideTextStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                          ),
                          defaultDecoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          weekendDecoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          rowDecoration: BoxDecoration(color: Colors.white),
                          markerDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          markersAlignment: Alignment.bottomCenter,
                          markerSize: 6,
                          isTodayHighlighted: true,
                          outsideDaysVisible: true,
                        ),
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _filterEventsBySelectedDay();
                            _showingAllEvents = false;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshToken,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _showingAllEvents
                                    ? 'Semua Kegiatan'
                                    : 'Acara pada ${DateFormatter.formatDate(_selectedDay!, 'dd MMMM yyyy')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _showAllEvents();
                                },
                                child: const Text('Lihat Semua'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child:
                              _filteredEvents.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.event_busy,
                                          size: 64,
                                          color: Colors.grey.withOpacity(0.6),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Tidak ada acara pada tanggal ini',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: _filteredEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = _filteredEvents[index];
                                      return _buildEventCard(event);
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: const Color(0xFFDCEAFF),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['date'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event['startTime']} - ${event['endTime']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
