import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/grocery_item.dart';
import '../data/categories.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

   var _enteredName ='';

   int _enteredQuantity =0;

    Category _selectedCategory = categories[Categories.fruit]!;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(9),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  label: Text('Name'),
                ),
                maxLength: 50,
                onSaved: (newValue){
                    _enteredName=newValue!;
                },
                validator: (String? value){
                  if(value==null||
                      value.isEmpty||
                      value.trim().length<=1 ||
                      value.trim().length>50){
                    return 'must be between 1 and 50 chars';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: '1',
                        onSaved: (newValue){
                            _enteredQuantity=int.parse(newValue!);
                        },
                        keyboardType: TextInputType.number,
                        validator: (String? value){
                          if(value==null||
                              value.isEmpty||
                              int.tryParse(value)==null||
                              int.tryParse(value)! <= 0){
                            return 'must be a valid, positive number';
                          }
                          return null;
                        },
                      ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                      child:DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for(final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                                child:Row(
                                  children: [
                                    Container(
                                      height: 16,
                                      width: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 6,),
                                    Text(category.value.title),
                                  ],
                                )
                            )
                        ],
                        onChanged: (Category? value) {
                          setState(() {
                            _selectedCategory=value!;
                          });
                        },
                      ) ,
                  )
                ],
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading?null: () async{
                      if(_formKey.currentState!.validate()){
                        setState(() {
                          _formKey.currentState!.save();
                        });
                        isLoading=true;
                        final Uri url=Uri.parse('https://shop-cd3e9-default-rtdb.firebaseio.com/shopping-list.json');
                        final  http.Response res = await http.post(
                            url,
                            headers: {'Content-Type':'application/json'},
                          body: json.encode({
                              'name':_enteredName,
                              'quantity':_enteredQuantity,
                              'category':_selectedCategory.title

                          }),
                        );
                        final Map<String,dynamic> resData = json.decode(res.body);
                        if(res.statusCode==200){
                          Navigator.of(context).pop(
                            GroceryItem(id: resData['name'], name: _enteredName, quantity: _enteredQuantity, category: _selectedCategory)
                          );
                        }
                      }
                    },
                    child: isLoading?SizedBox(child: CircularProgressIndicator(),):Text('Add Item'),
                  ),
                  TextButton(
                      onPressed: isLoading?null:(){
                        _formKey.currentState!.reset();
                      },
                      child: Text('Reset'),
                  ),
                  ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
