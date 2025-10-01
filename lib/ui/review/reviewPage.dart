import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/review.dart';
import 'package:flutter_final_sem4/data/service/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPage extends StatefulWidget {
  final int? productId;

  const ReviewPage({Key? key, this.productId}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Review> allReviews = [];
  List<Review> filteredReviews = [];
  List<Review> displayedReviews = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  double averageRating = 0.0;
  int totalReviews = 0;
  final int reviewsPerPage = 10;
  int currentPage = 1;
  int? selectedRatingFilter;
  String? searchKeyword;

  int displayedCount = 3;
  final int incrementCount = 3;
  String productName = "";

  int totalPages = 0;
  int totalCount = 0;

  // THÊM: Thông tin user đã đăng nhập
  int? currentUserId;
  String? currentUserName;
  String? currentUserEmail;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadReviews();
    if (widget.productId != null) {
      _loadAverageRating();
    }
  }

  // THÊM: Load thông tin user từ SharedPreferences
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token != null && token.isNotEmpty) {
        setState(() {
          isLoggedIn = true;
          currentUserName = prefs.getString("fullName") ?? "Người dùng";
          currentUserEmail = prefs.getString("email");
          // TODO: Nếu API trả về userId khi login, lưu vào prefs và lấy ra ở đây
          // Tạm thời hardcode userId = 1 cho test
          currentUserId = prefs.getInt("userId");
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _loadReviews({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore || currentPage >= totalPages) return;
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        currentPage = 1;
        displayedReviews.clear();
      });
    }

    try {
      Map<String, dynamic> result;

      if (searchKeyword != null && searchKeyword!.isNotEmpty) {
        result = await ReviewService.searchReviews(
          searchKeyword: searchKeyword,
          pageNow: currentPage,
          pageSize: reviewsPerPage,
        );
      } else if (widget.productId != null) {
        List<Review> reviews = await ReviewService.getReviewsByProductId(
          widget.productId!,
        );
        result = {
          'reviews': reviews,
          'pageNow': 1,
          'pageSize': reviews.length,
          'totalPage': 1,
          'totalCount': reviews.length,
        };
      } else {
        result = await ReviewService.getReviewsPage(
          pageNow: currentPage,
          pageSize: reviewsPerPage,
        );
      }

      List<Review> reviews = result['reviews'] ?? [];

      setState(() {
        if (isLoadMore) {
          displayedReviews.addAll(reviews);
          currentPage++;
        } else {
          allReviews = reviews;
          displayedReviews = reviews;
          totalPages = result['totalPage'] ?? 0;
          totalCount = result['totalCount'] ?? 0;
          totalReviews = totalCount;
          _calculateAverageRating();
        }
        _applyFilter();
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      _showErrorSnackBar('Lỗi khi tải đánh giá: $e');
    }
  }

  Future<void> _loadAverageRating() async {
    if (widget.productId == null) return;

    try {
      double avgRating = await ReviewService.getAverageRating(
        widget.productId!,
      );
      setState(() {
        averageRating = avgRating;
      });
    } catch (e) {
      print('Lỗi khi tải điểm trung bình: $e');
    }
  }

  void _applyFilter() {
    List<Review> reviews = List.from(allReviews);

    if (selectedRatingFilter != null) {
      reviews = reviews
          .where((review) => review.rating == selectedRatingFilter)
          .toList();
    }

    setState(() {
      filteredReviews = reviews;
      displayedCount = 3;
    });
  }

  void _showMoreReviews() {
    setState(() {
      displayedCount = (displayedCount + incrementCount).clamp(
        0,
        filteredReviews.length,
      );
    });
  }

  List<Review> get reviewsToShow {
    return filteredReviews.take(displayedCount).toList();
  }

  void _calculateAverageRating() {
    if (allReviews.isEmpty) {
      averageRating = 0;
      return;
    }
    if (widget.productId == null) {
      double sum = allReviews.fold(0, (sum, review) => sum + review.rating);
      averageRating = sum / allReviews.length;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _searchReviews(String keyword) async {
    setState(() {
      searchKeyword = keyword.trim().isEmpty ? null : keyword.trim();
      selectedRatingFilter = null;
    });
    await _loadReviews();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Widget _buildStarRating(
    int rating, {
    double size = 20,
    bool showRating = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: size,
            );
          }),
        ),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            '$rating.0',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: size * 0.8),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingDistribution() {
    Map<int, int> ratingCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in allReviews) {
      ratingCount[review.rating] = ratingCount[review.rating]! + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Phân bố đánh giá',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            int star = 5 - index;
            int count = ratingCount[star] ?? 0;
            double percentage = totalReviews > 0 ? count / totalReviews : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text('$star'),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(
                  review.userDisplayName.isNotEmpty
                      ? review.userDisplayName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userDisplayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStarRating(review.rating, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(review.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
          if (review.productName != null && widget.productId == null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sản phẩm: ${review.productName}',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowMoreButton() {
    if (displayedCount >= filteredReviews.length) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: OutlinedButton.icon(
          onPressed: _showMoreReviews,
          icon: const Icon(Icons.expand_more, color: Colors.green),
          label: Text(
            'Hiển thị thêm (${filteredReviews.length - displayedCount} còn lại)',
            style: const TextStyle(color: Colors.green),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: const BorderSide(color: Colors.green),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Lọc theo đánh giá'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption('Tất cả đánh giá', null, setDialogState),
                  const Divider(),
                  ...List.generate(5, (index) {
                    int rating = 5 - index;
                    return _buildFilterOption(
                      '$rating sao',
                      rating,
                      setDialogState,
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy',  style: TextStyle(color: Colors.green),),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _applyFilter();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Áp dụng',  style: TextStyle(color: Colors.green),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(
    String title,
    int? rating,
    StateSetter setDialogState,
  ) {
    bool isSelected = selectedRatingFilter == rating;

    return ListTile(
      title: Row(
        children: [
          if (rating != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(rating, (index) {
                return const Icon(Icons.star, color: Colors.amber, size: 16);
              }),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      leading: Radio<int?>(
        value: rating,
        groupValue: selectedRatingFilter,
        onChanged: (value) {
          setDialogState(() {
            selectedRatingFilter = value;
          });
        },
      ),
      onTap: () {
        setDialogState(() {
          selectedRatingFilter = rating;
        });
      },
    );
  }

  Future<void> _createReview(int rating, String? comment) async {
    // KIỂM TRA: User phải đăng nhập
    if (!isLoggedIn || currentUserId == null) {
      _showErrorSnackBar('Vui lòng đăng nhập để viết đánh giá');
      return;
    }

    if (widget.productId == null) {
      _showErrorSnackBar('Không thể tạo đánh giá: Thiếu thông tin sản phẩm');
      return;
    }

    try {
      // SỬ DỤNG userId từ tài khoản đã đăng nhập
      bool success = await ReviewService.createReview(
        productId: widget.productId!,
        userId: currentUserId!,
        rating: rating,
        comment: comment,
      );

      if (success) {
        _showSuccessSnackBar('Cảm ơn bạn đã đánh giá sản phẩm bên mình!');
        await _loadReviews();
        await _loadAverageRating();
      } else {
        _showErrorSnackBar('Hiện tại có một vài vấn đề nên không đánh giá được!');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tạo đánh giá: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          productName.isNotEmpty
              ? 'Đánh giá - $productName'
              : 'Đánh giá sản phẩm',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadReviews(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  _buildStarRating(
                                    averageRating.round(),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalReviews đánh giá',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildRatingDistribution(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hiển thị ${filteredReviews.length} đánh giá',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (selectedRatingFilter != null)
                              Text(
                                'Lọc: ${selectedRatingFilter} sao',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            if (selectedRatingFilter != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedRatingFilter = null;
                                  });
                                  _loadReviews();
                                },
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Xóa lọc'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            OutlinedButton.icon(
                              onPressed: _showFilterDialog,
                              icon: const Icon(Icons.tune, size: 18, color: Colors.green),
                              label: const Text('Lọc', style: TextStyle(color: Colors.green)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                side: BorderSide(
                                  color: Colors.green,
                                  width: selectedRatingFilter != null ? 2 : 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (filteredReviews.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có đánh giá nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...reviewsToShow.map(
                        (review) => _buildReviewItem(review),
                      ),

                    _buildShowMoreButton(),
                  ],
                ),
              ),
            ),
      floatingActionButton: widget.productId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // KIỂM TRA đăng nhập trước khi mở dialog
                if (!isLoggedIn) {
                  _showErrorSnackBar('Vui lòng đăng nhập để viết đánh giá');
                  // TODO: Navigate to login page
                  return;
                }
                _showWriteReviewDialog();
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Viết đánh giá',  style: TextStyle(color: Colors.white),),
            )
          : null,
    );
  }

  void _showWriteReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Viết đánh giá'),
              if (currentUserName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Đăng bởi: $currentUserName',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Đánh giá của bạn:'),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                    child: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                enabled: !isSubmitting,
                decoration: const InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm của bạn...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              if (isSubmitting) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Đang gửi đánh giá...'),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.green),),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() {
                        isSubmitting = true;
                      });

                      await _createReview(
                        selectedRating,
                        commentController.text.trim().isEmpty
                            ? null
                            : commentController.text.trim(),
                      );

                      Navigator.pop(context);
                    },
              child: const Text('Gửi đánh giá',  style: TextStyle(color: Colors.green),),
            ),
          ],
        ),
      ),
    );
  }
}