import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/todo_app/cubit/cubit.dart';
import 'package:todo_list/todo_app/cubit/states.dart';
import 'package:todo_list/todo_app/reused_components.dart';


class HomeScreen extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener:(context,state)=>{
          if(state is AppInsertDatabaseState)
          {
            Navigator.pop(context),
          }
        } ,
        builder:(context,state){
          AppCubit cubit= AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text('Todo List'),
            ),
            body: cubit.screens[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if ( formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text,
                    );
                    timeController.text="";
                    titleController.text="";
                    dateController.text="";
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(
                        20.0,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              label: 'tasks name',
                              prefix:Icons.title,
                              type: TextInputType.text,
                              validate: (String? value){
                                if(value!.isEmpty) {
                                  print('11111111111111111111111111111111') ;
                                  return 'filed are required';
                                }
                                else {
                                  print('2222222222222222222222222222222222222');
                                  return null;
                                }
                              },
                            ),

                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Task date',
                                  prefix: Icon(Icons.watch_later_outlined,),
                                ),
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text =
                                      value!.format(context).toString();
                                  print(value);
                                });
                              },
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              controller: dateController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: 'Task Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                ),
                              ),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse("2022-12-12"),
                                ).then((value) {
                                  dateController.text =
                                      DateFormat.yMMMd().format(value!);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 20.0,
                  )
                      .closed
                      .then((value) {
                        cubit.changeBottomSheet(isSheet: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheet(isSheet: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeCurrentIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
