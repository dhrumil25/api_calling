import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<dynamic> products = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/category/$category'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];
      });
    } else {
      throw Exception('Failed to load products by category');
    }
  }

  Future<void> searchProducts(String query) async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/search?q=$query'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];
      });
    } else {
      throw Exception('Failed to search products');
    }
  }

  void navigateToCategoriesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Product List'),
        actions: [
          Padding(
            padding:  EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: navigateToCategoriesPage,
              child: Text('Categories'),
            ),
          ),  Padding(
            padding:  EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
                } ,
              child: Text('add product'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                String query = value.trim();
                if (query.isNotEmpty) {
                  searchProducts(query);
                } else {
                  fetchProducts(); // If search field is empty, fetch all products
                }
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    fetchProducts(); // Clear search and fetch all products
                  },
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(productId: products[index]['id']),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display image thumbnail
                          Image.network(
                            products[index]['thumbnail'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          // Display product details
                          Text(
                            products[index]['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Price: \$${products[index]['price']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/categories'));
    if (response.statusCode == 200) {
      setState(() {
        categories = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProductList(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryProductList extends StatefulWidget {
  final String category;

  CategoryProductList({required this.category});

  @override
  _CategoryProductListState createState() => _CategoryProductListState();
}

class _CategoryProductListState extends State<CategoryProductList> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory(widget.category);
  }

  Future<void> fetchProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/category/$category'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];
      });
    } else {
      throw Exception('Failed to load products by category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products in ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(productId: products[index]['id']),
                ),
              );
            },
            child: Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display image thumbnail
                    Image.network(
                      products[index]['thumbnail'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    // Display product details
                    Text(
                      products[index]['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Price: \$${products[index]['price']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  ProductDetailsScreen({required this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map<String, dynamic>? productDetails;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/${widget.productId}'));
    if (response.statusCode == 200) {
      setState(() {
        productDetails = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load product details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: productDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Display carousel slider of images
        CarouselSlider(
        options: CarouselOptions(
        height: 200.0,
          enlargeCenterPage: true,
          autoPlay: true,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          viewportFraction: 0.8,
        ),
          items: (productDetails!['images'] as List<dynamic>).map
            ((item) {
            return Container(
              child: Center(
                child: Image.network(
                  item,
                  fit: BoxFit.cover,
                  width: 1000,
                ),
              ),
            );
          }).toList(),

        ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productDetails!['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Description: ${productDetails!['description']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Price: \$${productDetails!['price']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Discount: ${productDetails!['discountPercentage']}%',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rating: ${productDetails!['rating']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Stock: ${productDetails!['stock']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Brand: ${productDetails!['brand']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Category: ${productDetails!['category']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State{
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  Future<void> addProduct() async {
    final response = await http.post(
      Uri.parse('https://dummyjson.com/products/add'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({
        'title': titleController.text,
        'description': descriptionController.text,
        'price': double.parse(priceController.text),
        'discountPercentage': double.parse(discountController.text),
        'rating': double.parse(ratingController.text),
        'stock': int.parse(stockController.text),
        'brand': brandController.text,
        'category': categoryController.text,
      }),
    );
    if (response.statusCode == 200) {
      print('Product added successfully');
    } else {
      // Error adding product
      print('Failed to add product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Discount Percentage',
              ),
            ),
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Rating',
              ),
            ),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stock',
              ),
            ),
            TextField(
              controller: brandController,
              decoration: InputDecoration(
                labelText: 'Brand',
              ),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addProduct();
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
