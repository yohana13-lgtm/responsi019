import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DetailMealsPage extends StatefulWidget {
  final String mealId;

  DetailMealsPage({required this.mealId});

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<DetailMealsPage> {
  Map<String, dynamic> mealData = {};

  @override
  void initState() {
    super.initState();
    fetchMealDetails();
  }

  Future<void> fetchMealDetails() async {
    final apiUrl =
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null &&
            responseData['meals'] != null &&
            responseData['meals'].isNotEmpty) {
          setState(() {
            mealData = responseData['meals'][0];
          });
        } else {
          print('Error: No meal details found');
        }
      } else {
        print('Error: Failed to fetch meal details');
      }
    } catch (error) {
      print('Error fetching meal details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mealData['strMeal'] ?? 'Meal Detail'),
        backgroundColor: Color(0xff7ddb26),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMealImage(),
            SizedBox(height: 20),
            _buildDetail('Category', mealData['strCategory']),
            _buildDivider(),
            _buildDetail('Area', mealData['strArea']),
            SizedBox(height: 20),
            _buildSectionTitle('Ingredients:'),
            _buildDivider(),
            _buildIngredientsList(mealData),
            SizedBox(height: 20),
            _buildSectionTitle('Instructions:'),
            _buildDivider(),
            _buildDetail('Instructions', mealData['strInstructions']),
            SizedBox(height: 20),
            _buildWatchTutorialButton(mealData['strYoutube']),
          ],
        ),
      ),
      backgroundColor: Color(0xfffaffc9),
    );
  }

  Widget _buildMealImage() {
    return Image.network(
      mealData['strMealThumb'] ?? '',
      height: 200,
      fit: BoxFit.cover,
    );
  }

  Widget _buildDetail(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value ?? '',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return SizedBox(height: 10, child: Divider(color: Colors.grey));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildIngredientsList(Map<String, dynamic> mealData) {
    List<Widget> ingredientsWidgets = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = mealData['strIngredient$i'];
      final measure = mealData['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty) {
        ingredientsWidgets.add(
          Text(
            '- $ingredient: $measure',
            style: TextStyle(fontSize: 14),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredientsWidgets,
    );
  }

  Widget _buildWatchTutorialButton(String? youtubeLink) {
    return ElevatedButton(
      onPressed: () {
        _launchTutorial(youtubeLink);
      },
      style: ElevatedButton.styleFrom(
        primary: Color(0xfffbc101),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_fill,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Watch Tutorial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchTutorial(String? youtubeLink) async {
    if (youtubeLink != null && await canLaunch(youtubeLink)) {
      await launch(youtubeLink);
    } else {
      throw 'Could not launch $youtubeLink';
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      home: DetailMealsPage(mealId: '52771'),
    ),
  );
}
