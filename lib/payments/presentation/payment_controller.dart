import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_controller.g.dart';

@riverpod
class PaymentController extends _$PaymentController {
  static final payMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> pay({
    required String activityId,
    required int amountInPaise,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
  }) async {
    await ref.read(paymentRepositoryProvider).processPayment(
      activityId: activityId,
      amountInPaise: amountInPaise,
      description: description,
      userName: userName,
      userEmail: userEmail,
      userContact: userContact,
    );
  }
}
