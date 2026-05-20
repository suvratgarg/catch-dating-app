import 'package:catch_dating_app/clubs/data/club_callable_dtos.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/schema_contracts.g.dart'
    as schema_contracts;
import 'package:catch_dating_app/events/data/event_callable_dtos.dart';
import 'package:catch_dating_app/locations/data/places_callable_dtos.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/payments/data/payment_callable_dtos.dart';
import 'package:catch_dating_app/reviews/data/review_callable_dtos.dart';
import 'package:catch_dating_app/safety/data/safety_callable_dtos.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_callable_dtos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  group('callable request DTO contracts', () {
    test('event request DTOs match generated payload schemas', () {
      final details = EventDetailsCallableDto(
        startTimeMillis: DateTime.utc(2026, 6, 1, 6).millisecondsSinceEpoch,
        endTimeMillis: DateTime.utc(2026, 6, 1, 7).millisecondsSinceEpoch,
        meetingPoint: 'Cubbon Park gate',
        startingPointLat: 12.9763,
        startingPointLng: 77.5929,
        locationDetails: 'Meet beside the main entrance.',
        photoUrl: 'https://catchdates.com/events/cubbon.jpg',
        distanceKm: 5,
        pace: 'easy',
        description: 'Easy morning social run.',
      );
      final constraints = EventConstraintsCallableDto(
        minAge: 21,
        maxAge: 45,
        maxMen: null,
        maxWomen: null,
      );
      final eventFormat = <String, Object?>{
        'version': 1,
        'activityKind': 'socialRun',
        'interactionModel': 'pacePods',
      };

      _expectValid(
        'CreateEventCallablePayload',
        CreateEventCallableRequest(
          eventId: 'event-1',
          clubId: 'club-1',
          details: details,
          capacityLimit: 24,
          priceInPaise: 49900,
          currency: 'INR',
          constraints: constraints,
          eventPolicy: null,
          eventFormat: eventFormat,
          inviteCode: 'CATCH_2026',
        ).toJson(),
      );
      _expectValid(
        'UpdateEventCallablePayload',
        UpdateEventCallableRequest(
          eventId: 'event-1',
          fields: details.toJson(),
        ).toJson(),
      );
      _expectValid(
        'EventIdCallablePayload',
        EventIdCallableRequest('event-1', inviteCode: 'CATCH_2026').toJson(),
      );
      _expectValid(
        'CancelEventCallablePayload',
        const CancelEventCallableRequest(
          eventId: 'event-1',
          reason: 'Unsafe weather.',
        ).toJson(),
      );
      _expectValid(
        'DeleteEventCallablePayload',
        const EventIdCallableRequest('event-1').toJson(),
      );
      _expectValid(
        'MarkEventAttendanceCallablePayload',
        const MarkEventAttendanceCallableRequest(
          eventId: 'event-1',
          userId: 'runner-1',
        ).toJson(),
      );
      _expectValid(
        'SelfCheckInAttendanceCallablePayload',
        const SelfCheckInAttendanceCallableRequest(
          eventId: 'event-1',
          latitude: 12.9763,
          longitude: 77.5929,
        ).toJson(),
      );
    });

    test('club request DTOs match generated payload schemas', () {
      _expectValid(
        'CreateClubCallablePayload',
        const CreateClubCallableRequest(
          clubId: 'club-1',
          name: 'Cubbon Runners',
          description: 'Weekly social runs.',
          location: 'bengaluru',
          area: 'Cubbon Park',
          imageUrl: null,
          instagramHandle: 'cubbonrunners',
          phoneNumber: null,
          email: 'hello@example.com',
        ).toJson(),
      );
      _expectValid(
        'UpdateClubCallablePayload',
        const UpdateClubCallableRequest(
          clubId: 'club-1',
          fields: {
            'name': 'Cubbon Morning Runners',
            'tags': ['social', 'beginner'],
          },
        ).toJson(),
      );
      _expectValid(
        'ClubMembershipCallablePayload',
        const ClubIdCallableRequest('club-1').toJson(),
      );
      _expectValid(
        'DeleteClubCallablePayload',
        const ClubIdCallableRequest('club-1').toJson(),
      );
      _expectValid(
        'SetClubNotificationPreferenceCallablePayload',
        const SetClubNotificationPreferenceCallableRequest(
          clubId: 'club-1',
          enabled: true,
        ).toJson(),
      );
    });

    test('payment request DTOs match generated payload schemas', () {
      _expectValid(
        'EventIdCallablePayload',
        const EventBookingCallableRequest(
          eventId: 'event-1',
          inviteCode: 'CATCH_2026',
        ).toJson(),
      );
      _expectValid(
        'EventIdCallablePayload',
        const CreateRazorpayOrderCallableRequest(
          eventId: 'event-1',
          inviteCode: 'CATCH_2026',
        ).toJson(),
      );
      _expectValid(
        'VerifyRazorpayPaymentCallablePayload',
        const VerifyRazorpayPaymentCallableRequest(
          paymentId: 'pay_9A33XWu170gUtm',
          orderId: 'order_9A33XWu170gUtm',
          signature: 'abc123',
        ).toJson(),
      );
    });

    test('places request DTOs match generated payload schemas', () {
      _expectValid(
        'PlacesAutocompleteCallablePayload',
        const PlacesAutocompleteCallableRequest(
          input: 'Cubbon Park',
          sessionToken: 'session-token-1',
          countryIsoCode: 'IN',
          bias: LocationCoordinate(12.9763, 77.5929),
        ).toJson(),
      );
      _expectValid(
        'PlaceDetailsCallablePayload',
        const PlaceDetailsCallableRequest(
          placeId: 'ChIJ2dGMjMMEdkgRqVqkuXQkj7c',
          sessionToken: 'session-token-1',
        ).toJson(),
      );
    });

    test(
      'review, safety, and profile DTOs match generated payload schemas',
      () {
        _expectValid(
          'CreateEventReviewCallablePayload',
          const CreateEventReviewCallableRequest(
            clubId: 'club-1',
            eventId: 'event-1',
            rating: 5,
            comment: 'Thoughtful route and good pacing.',
          ).toJson(),
        );
        _expectValid(
          'UpdateEventReviewCallablePayload',
          const UpdateEventReviewCallableRequest(
            reviewId: 'review-1',
            rating: 4,
            comment: 'Updated after reflection.',
          ).toJson(),
        );
        _expectValid(
          'DeleteEventReviewCallablePayload',
          const ReviewIdCallableRequest('review-1').toJson(),
        );
        _expectValid(
          'BlockUserCallablePayload',
          const BlockUserCallableRequest(
            targetUserId: 'runner-2',
            source: 'profile',
          ).toJson(),
        );
        _expectValid(
          'UnblockUserCallablePayload',
          const UnblockUserCallableRequest(targetUserId: 'runner-2').toJson(),
        );
        _expectValid(
          'ReportUserCallablePayload',
          const ReportUserCallableRequest(
            targetUserId: 'runner-2',
            source: 'profile',
            reasonCode: 'spam',
            contextId: 'profile-runner-2',
            notes: 'Repeated spam messages.',
          ).toJson(),
        );

        final updateProfilePayload = UpdateUserProfileCallableRequest(
          fields: {
            'name': 'Runner One',
            'dateOfBirth': DateTime.utc(1994, 5, 20),
            'height': 176,
          },
        ).toJson();
        _expectValid('UpdateUserProfileCallablePayload', updateProfilePayload);
        expect(
          (updateProfilePayload['fields']!
              as Map<String, Object?>)['dateOfBirth'],
          isA<int>(),
        );
      },
    );
  });

  group('callable response DTO contracts', () {
    test('response parsers accept data that matches generated schemas', () {
      final createClubResponse = <String, Object?>{'clubId': 'club-1'};
      final attendanceResponse = <String, Object?>{'attended': true};
      final razorpayOrderResponse = <String, Object?>{
        'orderId': 'order_9A33XWu170gUtm',
        'amount': 49900,
        'currency': 'INR',
      };
      final placesAutocompleteResponse = <String, Object?>{
        'predictions': [
          {
            'placeId': 'ChIJ2dGMjMMEdkgRqVqkuXQkj7c',
            'description': 'Cubbon Park, Bengaluru, Karnataka, India',
            'mainText': 'Cubbon Park',
            'secondaryText': 'Bengaluru, Karnataka, India',
          },
        ],
      };
      final placeDetailsResponse = <String, Object?>{
        'place': {
          'placeId': 'ChIJ2dGMjMMEdkgRqVqkuXQkj7c',
          'displayName': 'Cubbon Park',
          'formattedAddress': 'Cubbon Park, Bengaluru, Karnataka, India',
          'latitude': 12.9763,
          'longitude': 77.5929,
        },
      };

      _expectValid('CreateClubCallableResponse', createClubResponse);
      expect(
        CreateClubCallableResponse.fromCallableData(createClubResponse).clubId,
        'club-1',
      );
      _expectValid('MarkEventAttendanceCallableResponse', attendanceResponse);
      expect(
        MarkEventAttendanceCallableResponse.fromCallableData(
          attendanceResponse,
        ).attended,
        isTrue,
      );
      _expectValid('RazorpayOrderCallableResponse', razorpayOrderResponse);
      expect(
        RazorpayOrderCallableResponse.fromCallableData(
          razorpayOrderResponse,
        ).amountInPaise,
        49900,
      );
      _expectValid(
        'PlacesAutocompleteCallableResponse',
        placesAutocompleteResponse,
      );
      expect(
        PlacesAutocompleteCallableResponse.fromCallableData(
          placesAutocompleteResponse,
        ).predictions.single.mainText,
        'Cubbon Park',
      );
      _expectValid('PlaceDetailsCallableResponse', placeDetailsResponse);
      expect(
        PlaceDetailsCallableResponse.fromCallableData(
          placeDetailsResponse,
        ).place.location,
        const LocationCoordinate(12.9763, 77.5929),
      );
    });
  });
}

void _expectValid(String schemaName, Object? payload) {
  final schema = schema_contracts.schemaContractsByName[schemaName];
  expect(schema, isNotNull, reason: 'Missing generated schema $schemaName');
  final result = JsonSchema.create(schema!).validate(payload);
  expect(
    result.isValid,
    isTrue,
    reason: '$schemaName rejected $payload: ${result.errors}',
  );
}
