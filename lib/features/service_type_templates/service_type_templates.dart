class TemplateStep { final String id,title,desc; const TemplateStep(this.id,this.title,this.desc); }
class ServiceTypeTemplates {
  static List<TemplateStep> getSteps(String t) {
    switch(t){
      case 'Semi': return [s('brakes','Brakes','Check pads/drums'),s('tires','DOT tires','Tread/cond'),s('lights','Lights','All lights'),s('fifth','5th wheel','Kingpin/jaws'),s('sus','Susp','Airbags/shocks'),s('def','DEF','Level'),s('fluids','Leaks','Oil/coolant')];
      case 'Trailer': return [s('brakes','Brakes','Chambers/drums'),s('tires','Tires','Tread/press'),s('lg','Landing','Legs/pins'),s('lights','Lights','All lights'),s('frame','Frame','Cracks'),s('sus','Susp','Axles')];
      case 'Vermeer Reclaimer': return [s('cut','Cutter','Teeth wear'),s('hyd','Hyd','Hoses/leaks'),s('conv','Conv','Belt/rolls'),s('ctrl','Controls','E-stops'),s('und','Undercar','Wheels/tracks'),s('filt','Filters','Air/oil')];
      case 'Mud Pump': return [s('fe','Fluid end','Liners/valves'),s('pp','Piston/rod','Wear'),s('pe','Power end','Oil'),s('pd','Puls damp','Charge'),s('rel','Relief','Verify')];
      case 'Other': return [];
      default: return [];
    }
  }
  static TemplateStep s(i,t,d)=>TemplateStep(i,t,d);
  static List<String> getServiceTypes()=>['Semi','Trailer','Vermeer Reclaimer','Mud Pump','Other'];
}
