import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/model/CheckoutResponseDto.dart';
import 'package:flutter_final_sem4/data/service/CheckoutService.dart';

class CheckoutRepository {
  final CheckoutService _service = CheckoutService();

  Future<CheckoutResponseDto> checkout(CheckoutRequestDto dto) async {
    final json = await _service.checkout(dto);
    return CheckoutResponseDto.fromJson(json); // ✅ gọi đúng
  }
}
