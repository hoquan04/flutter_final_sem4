import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_final_sem4/data/model/review.dart';
import 'api_constants.dart';

class ReviewService {
  // Lấy tất cả reviews
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.reviewUrl}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          List<dynamic> reviewsJson = jsonData['data'];
          return reviewsJson.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting all reviews: $e');
      return [];
    }
  }

  // Lấy reviews theo productId
  static Future<List<Review>> getReviewsByProductId(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.reviewUrl}/product/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          List<dynamic> reviewsJson = jsonData['data'];
          return reviewsJson.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting reviews by product: $e');
      return [];
    }
  }

  // Lấy reviews theo userId
  static Future<List<Review>> getReviewsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.reviewUrl}/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          List<dynamic> reviewsJson = jsonData['data'];
          return reviewsJson.map((json) => Review.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting reviews by user: $e');
      return [];
    }
  }

  // Lấy điểm trung bình
  static Future<double> getAverageRating(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.reviewUrl}/average/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as num).toDouble();
        }
      }
      return 0.0;
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }

  // Lấy reviews phân trang
  static Future<Map<String, dynamic>> getReviewsPage({
    int pageNow = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.reviewUrl}/page?pageNow=$pageNow&pageSize=$pageSize'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final pagedData = jsonData['data'];
          return {
            'reviews': (pagedData['data'] as List).map((json) => Review.fromJson(json)).toList(),
            'pageNow': pagedData['pageNow'],
            'pageSize': pagedData['pageSize'],
            'totalPage': pagedData['totalPage'],
            'totalCount': pagedData['totalCount'],
          };
        }
      }
      return {
        'reviews': <Review>[],
        'pageNow': 1,
        'pageSize': pageSize,
        'totalPage': 0,
        'totalCount': 0,
      };
    } catch (e) {
      print('Error getting reviews page: $e');
      return {
        'reviews': <Review>[],
        'pageNow': 1,
        'pageSize': pageSize,
        'totalPage': 0,
        'totalCount': 0,
      };
    }
  }

  // Tìm kiếm reviews
  static Future<Map<String, dynamic>> searchReviews({
    String? searchKeyword,
    int pageNow = 1,
    int pageSize = 10,
  }) async {
    try {
      String url = '${ApiConstants.reviewUrl}/search?pageNow=$pageNow&pageSize=$pageSize';
      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        url += '&searchKeyword=${Uri.encodeComponent(searchKeyword)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final pagedData = jsonData['data'];
          return {
            'reviews': (pagedData['data'] as List).map((json) => Review.fromJson(json)).toList(),
            'pageNow': pagedData['pageNow'],
            'pageSize': pagedData['pageSize'],
            'totalPage': pagedData['totalPage'],
            'totalCount': pagedData['totalCount'],
          };
        }
      }
      return {
        'reviews': <Review>[],
        'pageNow': 1,
        'pageSize': pageSize,
        'totalPage': 0,
        'totalCount': 0,
      };
    } catch (e) {
      print('Error searching reviews: $e');
      return {
        'reviews': <Review>[],
        'pageNow': 1,
        'pageSize': pageSize,
        'totalPage': 0,
        'totalCount': 0,
      };
    }
  }

  // Tạo review mới
  static Future<bool> createReview({
    required int productId,
    required int userId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.reviewUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': productId,
          'userId': userId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error creating review: $e');
      return false;
    }
  }

  // Cập nhật review
  static Future<bool> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.reviewUrl}/$reviewId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  // Xóa review
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.reviewUrl}/$reviewId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }
}