class CheckStep {
  final String id,title,value,notes;
  final bool done,notApplicable;
  final String description;
  const CheckStep({required this.id,required this.title,this.done=false,this.notApplicable=false,this.value='',this.notes='',this.description=''});
  CheckStep copyWith({String?t,bool?d,bool?na,String?v,String?n,String?desc})=>CheckStep(id:id,title:t??title,done:d??done,notApplicable:na??notApplicable,value:v??value,notes:n??notes,description:desc??description);
  factory CheckStep.fromJson(Map j)=>CheckStep(id:j['id'],title:j['title'],done:j['done']??false,notApplicable:j['not_applicable']??false,value:j['value']??'',notes:j['notes']??'',description:j['description']??'');
  Map toJson()=>{'id':id,'title':title,'done':done,'not_applicable':notApplicable,'value':value,'notes':notes,'description':description};
}
