import '../records/check_step.dart';
class LastServiceInfo { final bool hasLastService; final String lastServiceDate; final List<CheckStep> lastServiceSteps; const LastServiceInfo(this.hasLastService,{this.lastServiceDate='',this.lastServiceSteps=const[]}); }
class VehicleServiceHistory {
  static LastServiceInfo findLastServiceForUnit(List<dynamic> allRecords,String vehicleNumber){
    if(allRecords.isEmpty||vehicleNumber.trim().isEmpty)return LastServiceInfo(false);
    final unit=vehicleNumber.trim().toLowerCase();
    for(final record in allRecords){
      try{
        final recordVehicle=(record.vehicleNumber??record.vehicle_number??'').toString().trim().toLowerCase();
        if(recordVehicle==unit)return LastServiceInfo(true,lastServiceDate:(record.dateStarted??record.date_started??'').toString(),lastServiceSteps:record.steps??[]);
      }catch(_){}
    }
    return LastServiceInfo(false);
  }
}
