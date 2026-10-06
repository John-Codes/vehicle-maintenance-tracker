import 'package:flutter/material.dart';
import '../../core/large_display.dart';
import '../records/check_step.dart';
class StepTile extends StatefulWidget {
  final CheckStep step; final ValueChanged<CheckStep> onChanged; final VoidCallback onDelete;
  const StepTile({super.key,required this.step,required this.onChanged,required this.onDelete});
  @override State<StepTile> createState()=>_StepTileState();
}
class _StepTileState extends State<StepTile> {
  late final title=TextEditingController(text:widget.step.title),value=TextEditingController(text:widget.step.value),notes=TextEditingController(text:widget.step.notes);
  @override void dispose(){title.dispose();value.dispose();notes.dispose();super.dispose();}
  void change({bool?d,bool?na}){final n=na??widget.step.notApplicable;final dn=n?false:(d??widget.step.done);widget.onChanged(widget.step.copyWith(title:title.text,done:dn,notApplicable:n,value:value.text,notes:notes.text));}
  void info(){if(widget.step.description.isEmpty)return;showDialog(context:context,builder:(_)=>AlertDialog(title:Text(widget.step.title),content:Text(widget.step.description),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Close'))]));}
  @override Widget build(BuildContext c){final n=widget.step.notApplicable;final big=biggerTextButtonsEnabled;final iconSize=big?26.0:24.0;return Card(child:ExpansionTile(leading:Row(mainAxisSize:MainAxisSize.min,children:[Checkbox(value:n?false:widget.step.done,onChanged:n?null:(x)=>change(d:x)),TextButton(onPressed:()=>change(na:!n),style:TextButton.styleFrom(minimumSize:big?const Size(64,52):null,padding:big?const EdgeInsets.symmetric(horizontal:14):null),child:Text('N/A',style:TextStyle(fontSize:big?16:14,color:n?Colors.orange:Colors.grey)))]),title:Text(widget.step.title,style:TextStyle(decoration:n?TextDecoration.lineThrough:null,color:n?Colors.grey:null)),trailing:Row(mainAxisSize:MainAxisSize.min,children:[if(widget.step.description.isNotEmpty)IconButton(icon:Icon(Icons.info_outline,size:iconSize),onPressed:info),IconButton(icon:Icon(Icons.delete_outline,size:iconSize),onPressed:widget.onDelete)]),childrenPadding:const EdgeInsets.fromLTRB(16,0,16,16),children:[TextField(controller:title,enabled:!n,decoration:const InputDecoration(labelText:'Title')),TextField(controller:value,enabled:!n,decoration:const InputDecoration(labelText:'Value')),TextField(controller:notes,enabled:!n,maxLines:2,decoration:const InputDecoration(labelText:'Notes'))]));}
}
