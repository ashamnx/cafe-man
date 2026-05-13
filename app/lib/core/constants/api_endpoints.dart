class ApiEndpoints {
  static const String baseUrl = 'https://cafe.ashamnx.dev';
  static const String apiBase = '$baseUrl/api/v1';

  // Auth
  static const String register = '$apiBase/auth/register';
  static const String login = '$apiBase/auth/login';
  static const String refresh = '$apiBase/auth/refresh';
  static const String selectOrg = '$apiBase/auth/select-org';
  static const String logout = '$apiBase/auth/logout';
  static const String me = '$apiBase/auth/me';

  // Dashboard
  static const String dashboard = '$apiBase/dashboard';

  // Ingredients
  static const String ingredients = '$apiBase/ingredients';
  static String ingredient(String id) => '$ingredients/$id';
  static String ingredientHistory(String id) => '$ingredients/$id/history';
  static String ingredientRecipes(String id) => '$ingredients/$id/recipes';
  static const String ingredientCostTrends = '$ingredients/cost-trends';
  static const String ingredientCategories = '$ingredients/categories';

  // Units
  static const String units = '$apiBase/units';

  // Vendors
  static const String vendors = '$apiBase/vendors';
  static String vendor(String id) => '$vendors/$id';

  // Bills
  static const String bills = '$apiBase/bills';
  static const String billUpload = '$bills/upload';
  static const String billManual = '$bills/manual';
  static String bill(String id) => '$bills/$id';
  static String billMapItem(String billId, String itemId) =>
      '$bills/$billId/map/$itemId';
  static String billCreateIngredient(String billId, String itemId) =>
      '$bills/$billId/create-ingredient/$itemId';
  static String billApply(String id) => '$bills/$id/apply';

  // Recipes
  static const String recipes = '$apiBase/recipes';
  static const String recipeCategories = '$recipes/categories';
  static String recipe(String id) => '$recipes/$id';
  static String recipeIngredients(String id) => '$recipes/$id/ingredients';
  static String recipeIngredient(String recipeId, String riId) =>
      '$recipes/$recipeId/ingredients/$riId';
  static String recipeUtilityCosts(String id) => '$recipes/$id/utility-costs';
  static String recipeUtilityCost(String recipeId, String ucId) =>
      '$recipes/$recipeId/utility-costs/$ucId';

  // Sales
  static const String sales = '$apiBase/sales';
  static String sale(String id) => '$sales/$id';
  static String saleItems(String id) => '$sales/$id/items';
  static String saleItem(String saleId, String itemId) =>
      '$sales/$saleId/items/$itemId';
  static String saleApply(String id) => '$sales/$id/apply';

  // Wastage
  static const String wastage = '$apiBase/wastage';

  // Stock Movements
  static const String stockMovements = '$apiBase/stock-movements';

  // Alerts
  static const String alerts = '$apiBase/alerts';
  static String alertRead(String id) => '$alerts/$id/read';

  // Users
  static const String users = '$apiBase/users';
  static const String userInvite = '$users/invite';
  static String userRole(String id) => '$users/$id/role';
  static String userResetPassword(String id) => '$users/$id/reset-password';
  static String userRemove(String id) => '$users/$id';

  // Roles
  static const String roles = '$apiBase/roles';
  static String role(String id) => '$roles/$id';

  // Audit Log
  static const String auditLog = '$apiBase/audit-log';

  // Images (served from public /images/ proxy, no auth needed)
  static String imageUrl(String key) => '$baseUrl/images/$key';
}
