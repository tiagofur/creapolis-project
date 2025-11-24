import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:creapolis_app/l10n/app_localizations.dart';
import '../../../../injection.dart';
import '../../../../presentation/bloc/calendar/calendar_bloc.dart';
import '../../../../presentation/bloc/calendar/calendar_event.dart';
import '../../../../presentation/bloc/calendar/calendar_state.dart';
import '../widgets/calendar_view.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CalendarBloc>()..add(const LoadConnectionStatusEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.googleCalendarTitle ?? 'Calendario',
          ),
          actions: [
            BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
                if (state is ConnectionStatusLoaded && state.isConnected ||
                    state is CalendarEventsLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<CalendarBloc>().add(
                        const RefreshCalendarEventsEvent(),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<CalendarBloc, CalendarState>(
          listener: (context, state) {
            if (state is CalendarError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is ConnectionStatusLoaded && state.isConnected) {
              context.read<CalendarBloc>().add(const LoadCalendarEventsEvent());
            }
            if (state is CalendarConnected) {
              context.read<CalendarBloc>().add(const LoadCalendarEventsEvent());
            }
          },
          builder: (context, state) {
            if (state is CalendarLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CalendarEventsLoaded) {
              return CalendarView(
                events: state.events,
                onDaySelected: (day) {
                  // Opcional: Cargar eventos específicos del día si no se cargan todos de una vez
                },
              );
            }

            if (state is ConnectionStatusLoaded) {
              if (!state.isConnected) {
                return _buildConnectView(context);
              }
              // Si está conectado, debería haber disparado LoadCalendarEventsEvent en el listener
              // Pero mostramos loading por si acaso
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CalendarDisconnected || state is CalendarInitial) {
              return _buildConnectView(context);
            }

            return _buildConnectView(context);
          },
        ),
      ),
    );
  }

  Widget _buildConnectView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Conecta tu calendario',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Sincroniza tus eventos de Google Calendar',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CalendarBloc>().add(const ConnectCalendarEvent());
            },
            icon: const Icon(Icons.link),
            label: const Text('Conectar Google Calendar'),
          ),
        ],
      ),
    );
  }
}
