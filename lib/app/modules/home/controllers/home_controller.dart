import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/dummy_data.dart';

class HomeController extends GetxController {
  // Bottom Navigation state
  var selectedTab = 0.obs;

  // Category filter state
  var selectedCategory = 'Semua'.obs;
  
  final List<String> categories = ['Semua', 'Mirrorless', 'Lensa', 'Aksesoris'];

  // All products
  var allProducts = <ProductModel>[].obs;
  
  // Filtered products list
  var filteredProducts = <ProductModel>[].obs;

  // Search input and result query
  var searchQuery = ''.obs;
  var recentSearches = <String>['Sony A7 IV Body Only', 'Lensa 85mm f/1.4'].obs;

  // Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load products from Supabase
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('products').select();
      
      final List<ProductModel> loadedProducts = (response as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (loadedProducts.isNotEmpty) {
        allProducts.assignAll(loadedProducts);
        filteredProducts.assignAll(loadedProducts);
      } else {
        // Fallback to DummyData if database is empty (optional)
        allProducts.assignAll(DummyData.products);
        filteredProducts.assignAll(DummyData.products);
      }
    } catch (e) {
      print("Error fetching products: $e");
      // Fallback to DummyData if there's an error
      allProducts.assignAll(DummyData.products);
      filteredProducts.assignAll(DummyData.products);
    } finally {
      isLoading.value = false;
      applyFilters();
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    var result = allProducts.toList();

    // Apply category filter
    if (selectedCategory.value != 'Semua') {
      result = result.where((p) => p.category.toLowerCase() == selectedCategory.value.toLowerCase()).toList();
    }

    // Apply search query filter
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              p.brand.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredProducts.assignAll(result);
  }

  void addRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    if (recentSearches.contains(query)) {
      recentSearches.remove(query);
    }
    recentSearches.insert(0, query);
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
