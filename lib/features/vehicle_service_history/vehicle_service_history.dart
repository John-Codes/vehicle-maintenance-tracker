import '../records/check_step.dart';
class LastServiceInfo { final bool has; final String date; final List<CheckStep> steps; const LastServiceInfo(this.has,{this.date='',this.steps=const[]}); }
class VehicleServiceHistory {
  static LastServiceInfo findLast(List<dynamic> recs,String v){
    if(recs.isEmpty||v.isEmpty)return LastServiceInfo(false);
    final vn=v.trim().toLowerCase();
    for(final r in recs){
      try{ final rn=(r.vehicleNumber??r.vehicle_number??'').toString().toLowerCase().trim(); if(rn==vn){ final d=(r.dateStarted??r.date_started??'').toString(); return LastServiceInfo(true,date:d,steps:r.steps??[]);} }catch(_){}
    }
    return LastServiceInfo(false);
  }
}
