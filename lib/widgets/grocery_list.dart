import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_app/data/categories.dart';
import 'package:shop_app/models/grocery_item.dart';
import 'package:shop_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;


class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
   List<GroceryItem> _groceryItems=[];
   bool isLoading = true;

  _loadData() async{
    final Uri url=Uri.parse('https://shop-cd3e9-default-rtdb.firebaseio.com/shopping-list.json');
    final http.Response res = await http.get(url);

    if(res.body=='null'){
      setState(() {
        isLoading=false;
      });
      return;
    }
    final Map<String,dynamic> loadedData = json.decode(res.body);
    final List<GroceryItem> loadedItem=[];
    for(var item in loadedData.entries){
      final  category =categories.entries
          .firstWhere((element) =>
      element.value.title==item.value['category'],
      ).value;
      loadedItem.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
        )
      );
      setState(() {
        _groceryItems=loadedItem;
      });
    }

  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'No Item Added.'
      ),
    );

    if(isLoading){
      content=Center(child: Container(child: CircularProgressIndicator(),));
    }
    if(_groceryItems.isNotEmpty){
      content= ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx,index)=>Dismissible(
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (_){_removedItem(_groceryItems[index]);},
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                height: 20,
                width: 20,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Grocery'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }

  void _removedItem  (GroceryItem item) async{
    final index= _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final Uri url=Uri.parse('https://shop-cd3e9-default-rtdb.firebaseio.com/shopping-list/${item.id}.json');
   final res = await http.delete(url);
   if(res.statusCode>=400){
     setState(() {
       _groceryItems.insert(index,item);
     });
   }
  }
  _addItem() async{
      final newItem = await Navigator.of(context).push<GroceryItem>(
          MaterialPageRoute(builder: (ctx)=>NewItem(),)
      );
      if(newItem==null){
        return;
      }
      setState(() {
        _groceryItems.add(newItem);
        isLoading=false;
      });
  }

}
