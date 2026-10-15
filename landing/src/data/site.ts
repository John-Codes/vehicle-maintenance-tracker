// One place for every business number on the page. Change prices here,
// the whole page follows.
export const APP_URL = 'https://app.safeprevent.com';
export const PHONE_DISPLAY = '(210) 387-9812';
export const PHONE_TEL = '+12103879812';
export const EMAIL = 'efexzium@gmail.com';

export const TIERS = [
  {
    name: 'Essential',
    price: 119,
    hours: 1,
    tagline: 'One pro hour, every month. Breakdowns never get a chance.',
  },
  {
    name: 'Professional',
    price: 219,
    hours: 2,
    tagline: 'Twice the hands-on time. For fleets that run hard.',
    featured: true,
  },
  {
    name: 'Maximum',
    price: 429,
    hours: 4,
    tagline: 'Serious coverage: 4 pooled hours + priority dispatch.',
    priority: true,
  },
];

export const BUNDLE = [
  { icon: '📡', title: 'GPS tracking + telematics', text: 'Know where every vehicle is and what it is doing, in real time.' },
  { icon: '🔗', title: 'OBD sync per vehicle', text: 'An adapter on each unit streams miles and engine hours automatically.' },
  { icon: '📋', title: 'Inspection checklists', text: 'Daily, weekly, and monthly checklists with GPS-stamped history.' },
  { icon: '✨', title: 'AI maintenance info', text: 'Tell it the year, make, and model — get a full maintenance checklist.' },
  { icon: '🔔', title: 'Smart alerts', text: 'Email and text reminders before something breaks, not after.' },
  { icon: '👥', title: 'Teams + roles', text: 'Managers and techs, invite-only workspaces, PDF & Excel reports.' },
];

export const HARDWARE = {
  intro: 'Powered by the CANedge data loggers by CSS Electronics — trusted by VW, '
      + 'Cummins, and Thermo King. You never touch J1939 filters, DBC files, or SIMs: '
      + 'we bring the AI and the technical expertise.',
  kits: [
    {
      icon: '🏭',
      name: 'Yard Kit',
      price: 79,
      device: 'CANedge2 (WiFi)',
      text: 'For reclaimers, mud pumps, and heavy equipment at the depot. Uploads '
          + 'when machines come in range of your yard WiFi — no data fees, ever.',
    },
    {
      icon: '🚛',
      name: 'Road Kit',
      price: 95,
      device: 'CANedge3 (cellular + GPS)',
      text: 'For trucks and road vehicles. SIM and data are part of your monthly — '
          + 'no extra bills, one invoice. Built-in GPS adds position, speed, and trip distance.',
      featured: true,
    },
  ],
  terms: '12-month term per vehicle. Hardware, professional installation, data, and '
      + 'a 3-year warranty included. Devices remain SafePrevent property until the term '
      + 'is paid out; refundable deposit collected at install.',
};

export const COMING_SOON = [
  { icon: '📝', title: 'DOT / ELD compliance' },
  { icon: '⛽', title: 'Fuel management' },
];
