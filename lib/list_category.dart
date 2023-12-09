import 'package:flutter/material.dart';
import 'details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal',
      home: MealPage(),
    );
  }
}

class MealPage extends StatefulWidget {
  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiUrl = 'https://www.themealdb.com/api/json/v1/1/categories.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData['categories'] != null) {
          setState(() {
            categories =
                List<Map<String, dynamic>>.from(responseData['categories']);
          });
        } else {
          print('Error: No categories found');
        }
      } else {
        print('Error: Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Categories'),
        backgroundColor: Color(0xff965dc5),
      ),
      backgroundColor: Color(0xfffaffc9),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealListPage(
                            category: category['strCategory'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10.0),
                            ),
                            child: category['strCategoryThumb'] != null
                                ? Image.network(
                                    category['strCategoryThumb'],
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Color(0xfffaffc9),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['strCategory'] ?? '',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple, // Adjust color
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                category['strCategoryDescription'] ?? '',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey, // Adjust color
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MealListPage extends StatefulWidget {
  final String category;

  MealListPage({required this.category});

  @override
  _MealListPageState createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    fetchMealsByCategory();
  }

  Future<void> fetchMealsByCategory() async {
    final apiUrl =
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null &&
            responseData['meals'] != null &&
            responseData['meals'] is List) {
          setState(() {
            meals = List<Map<String, dynamic>>.from(responseData['meals']);
          });
        } else {
          print('Error: No meals found');
        }
      } else {
        print('Error: Failed to fetch meals');
      }
    } catch (error) {
      print('Error fetching meals: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7ddb26),
        centerTitle: true,
        title: Text('${widget.category} Meals'),
      ),
      backgroundColor: Color(0xfffaffc9),
      body: _buildMealGrid(),
    );
  }

  Widget _buildMealGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return MealItem(mealData: meal);
      },
    );
  }
}

class MealItem extends StatelessWidget {
  final Map<String, dynamic> mealData;

  MealItem({required this.mealData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailMealsPage(
                mealId: mealData['idMeal'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
                child: mealData['strMealThumb'] != null
                    ? Image.network(
                        mealData['strMealThumb'],
                        fit: BoxFit.cover,
                      )
                    : Container(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                mealData['strMeal'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff171618), // Adjust color
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
