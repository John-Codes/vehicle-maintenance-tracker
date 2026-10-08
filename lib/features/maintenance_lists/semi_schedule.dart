import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule semiSchedule() => buildSchedule(
      const [
        ScheduleComponent('brakes', 'Brakes'),
        ScheduleComponent('lights', 'Lights'),
        ScheduleComponent('tires', 'Tires'),
        ScheduleComponent('fluids', 'Fluids'),
        ScheduleComponent('safety', 'Safety equipment'),
        ScheduleComponent('engine', 'Engine and cooling'),
        ScheduleComponent('air', 'Air system'),
        ScheduleComponent('coupling', 'Fifth wheel and coupling'),
        ScheduleComponent('suspension', 'Steering and suspension'),
        ScheduleComponent('frame', 'Frame and exhaust'),
      ],
      const [
        ScheduleTask('brakes', 'air', 'Air pressure and warning lights'),
        ScheduleTask('brakes', 'brake_leaks', 'Air leaks and brake hoses'),
        ScheduleTask('lights', 'all', 'Headlights, markers, and signals'),
        ScheduleTask('tires', 'cond', 'Inflation, tread, and sidewalls'),
        ScheduleTask('tires', 'lugs', 'Lug nuts and wheel seals'),
        ScheduleTask('fluids', 'levels', 'Oil, coolant, DEF, and washer fluid'),
        ScheduleTask('fluids', 'fluid_leaks', 'Fluid leaks under the tractor'),
        ScheduleTask('safety', 'walk', 'Mirrors, horn, belts, and emergency equipment'),
      ],
      const [
        ScheduleTask('brakes', 'adjusters', 'Slack adjuster travel and linings'),
        ScheduleTask('brakes', 'chambers', 'Brake chambers and mounting'),
        ScheduleTask('lights', 'wiring', 'Lenses, wiring, and connectors'),
        ScheduleTask('tires', 'pressure', 'Pressure, tread depth, and valve stems'),
        ScheduleTask('fluids', 'filters', 'Fluid filters and service indicators'),
        ScheduleTask('engine', 'belts', 'Belts, hoses, radiator, and battery'),
        ScheduleTask('air', 'dryer', 'Air dryer, tanks, and drain valves'),
        ScheduleTask('coupling', 'fifth', 'Fifth wheel, kingpin, and locking jaws'),
        ScheduleTask('suspension', 'steering', 'Steering, suspension, and driveline'),
      ],
      const [
        ScheduleTask('brakes', 'measure', 'Brake lining and drum wear measurements'),
        ScheduleTask('brakes', 'abs', 'ABS sensors and fault history'),
        ScheduleTask('lights', 'sockets', 'Lamp sockets, grounds, and harnesses'),
        ScheduleTask('tires', 'wear', 'Tread wear pattern and alignment'),
        ScheduleTask('fluids', 'service', 'Oil, coolant, fuel, and DEF service intervals'),
        ScheduleTask('engine', 'mounts', 'Engine mounts, exhaust, and aftertreatment'),
        ScheduleTask('air', 'test', 'Air system leak-down and governor test'),
        ScheduleTask('coupling', 'coupling_inspect', 'Fifth wheel wear and fastener torque'),
        ScheduleTask('frame', 'frame_inspect', 'Frame, crossmembers, and corrosion'),
      ],
    );
