import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/todo_app/cubit/states.dart';
import '../Task_screen.dart';
import '../archived_screen.dart';
import '../done_screen.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context)=> BlocProvider.of(context);
  List<Widget> screens = [
    TaskScreen(),
    DoneScreen(),
    ArchivedScreen(),
  ];
  //                    ************************************************************************

  int currentIndex = 0;

  void changeCurrentIndex(index){
    currentIndex=index;
    emit(AppChangeBottomNavBarState());
  }
  //                     ***************************************************************

  Database? database;
  List<Map> newTasks=[];
  List<Map> doneTasks=[];
  List<Map> archivedTasks=[];
  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database) {
        print('database opened');
        getDataFromDatabase(database);
      },
    ).then((value) {
      database= value;
      emit(AppCreateDatabaseState());
    });
  }

   void insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database!.transaction((txn) async {
      txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element)
      {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async
  {
    database!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async
  {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  //               ***********************************************************************
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheet({
  required bool isSheet,
  required IconData icon,
})
{
  isBottomSheetShown=isSheet;
  fabIcon=icon;
  emit(AppChangeBottomSheetBarState());
}
}