import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/Bloc_observer.dart';
import 'package:todo_list/todo_app/home_layout.dart';



void main(){
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }

}