import 'maintenance_schedule.dart';
import 'schedule_factory.dart';

MaintenanceSchedule trailerSchedule() => buildSchedule(
      const [
        ScheduleComponent('brakes', 'Brakes'),
        ScheduleComponent('lights', 'Lights'),
        ScheduleComponent('tires', 'Tires'),
        ScheduleComponent('frame', 'Frame'),
        ScheduleComponent('coupling', 'Coupling and landing gear'),
        ScheduleComponent('air', 'Air and electrical connections'),
        ScheduleComponent('body', 'Body, doors, and floor'),
      ],
      const [
        ScheduleTask('brakes', 'check', 'Brake response and air leaks'),
        ScheduleTask('lights', 'all', 'All lamps and reflective markings'),
        ScheduleTask('tires', 'cond', 'Inflation, tread, sidewalls, and lugs'),
        ScheduleTask('frame', 'damage', 'Frame, crossmembers, and visible damage'),
        ScheduleTask('coupling', 'landing', 'Landing gear, kingpin, and locking jaws'),
        ScheduleTask('air', 'connect', 'Glad hands, electrical plug, and lines'),
        ScheduleTask('body', 'doors', 'Doors, locks, hinges, floor, and roof'),
      ],
      const [
        ScheduleTask('brakes', 'chambers', 'Chambers, slack adjusters, and linings'),
        ScheduleTask('lights', 'lenses', 'Lenses, wiring, grounds, and connectors'),
        ScheduleTask('tires', 'pressure', 'Pressure, tread depth, and wheel seals'),
        ScheduleTask('frame', 'pins', 'Pins, cracks, welds, and corrosion'),
        ScheduleTask('coupling', 'gear', 'Landing gear lubrication and fasteners'),
        ScheduleTask('air', 'valves', 'Air valves, tanks, and leak-down check'),
        ScheduleTask('body', 'structure', 'Floor, roof, doors, seals, and mud flaps'),
      ],
      const [
        ScheduleTask('brakes', 'adjust', 'Brake lining, drum, and ABS inspection'),
        ScheduleTask('lights', 'sockets', 'Lamp sockets, harnesses, and reflectors'),
        ScheduleTask('tires', 'tread', 'Tread wear, alignment, and torque records'),
        ScheduleTask('frame', 'susp', 'Suspension, axles, and structural inspection'),
        ScheduleTask('coupling', 'wear', 'Kingpin, fifth wheel, and landing gear wear'),
        ScheduleTask('air', 'service', 'Air reservoir, valves, and hose service'),
        ScheduleTask('body', 'repair', 'Body sealing, floor condition, and corrosion repair'),
      ],
    );
