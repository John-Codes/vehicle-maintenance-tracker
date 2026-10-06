import '../profile/technician.dart';
import 'check_step.dart';
class ServiceRecord {
  final String id,vehicleNumber,serviceType,dateStarted,notes,nextSteps,vin,licensePlate;
  final num? miles,hours;
  final List<String> workerNames;
  final Technician technician;
  final List<CheckStep> steps;
  const ServiceRecord({this.id='',this.vehicleNumber='',this.serviceType='',required this.dateStarted,this.miles,this.hours,this.workerNames=const[],this.technician=const Technician(),this.steps=const[],this.notes='',this.nextSteps='',this.vin='',this.licensePlate=''});
  factory ServiceRecord.fromJson(Map j)=>ServiceRecord(id:j['id']??'',vehicleNumber:j['vehicle_number']??'',serviceType:j['service_type']??'',dateStarted:j['date_started']??'',miles:j['miles'],hours:j['hours'],notes:j['notes']??'',nextSteps:j['next_steps']??'',technician:Technician.fromJson(Map.from(j['technician']??{})),workerNames:List.from(j['worker_names']??[]),steps:(j['steps'] as List??[]).map((x)=>CheckStep.fromJson(Map.from(x))).toList(),vin:j['vin']??'',licensePlate:j['license_plate']??'');
  Map toJson()=>{'vehicle_number':vehicleNumber,'service_type':serviceType,'date_started':dateStarted,'miles':miles,'hours':hours,'worker_names':workerNames,'technician':technician.toJson(),'steps':steps.map((x)=>x.toJson()).toList(),'notes':notes,'next_steps':nextSteps,'vin':vin,'license_plate':licensePlate};
  ServiceRecord copyWith({String?vehicleNumber,String?serviceType,num?miles,num?hours,List<String>?workerNames,List<CheckStep>?steps,String?notes,String?nextSteps,String?vin,String?licensePlate})=>ServiceRecord(id:id,dateStarted:dateStarted,technician:technician,vehicleNumber:vehicleNumber??this.vehicleNumber,serviceType:serviceType??this.serviceType,miles:miles??this.miles,hours:hours??this.hours,workerNames:workerNames??this.workerNames,steps:steps??this.steps,notes:notes??this.notes,nextSteps:nextSteps??this.nextSteps,vin:vin??this.vin,licensePlate:licensePlate??this.licensePlate);
}
