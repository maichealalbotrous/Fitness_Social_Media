# New Backend integration notes: Community and Challenges

## Community name search

The new `CommunityController` declares:

```csharp
[HttpGet("/name/{name}")]
```

Because the route starts with `/`, it is an absolute route and the actual request is:

```http
GET /name/{name}
```

Flutter now uses `/name/{name}` accordingly.

The Backend also uses `/requests/{requestId}` as an absolute route for handling membership requests. Flutter keeps this route unchanged.

Membership state must continue to be derived from the community `/members` endpoint because the lookup mapper defaults `IsMember` to `true`.

## Challenge update participant

Flutter already sends the correct contract:

```http
PUT /api/Challenge/{challengeId}/update-participant
Content-Type: application/json

5
```

The body is a raw JSON number because the Backend action receives `[FromBody] double goalParticipation`.

The new Backend service has two issues that require a Backend patch:

1. `ChallengeResponseDto` does not include `Progress`, even though the Mongo model stores it. Add `double Progress` to the DTO and include it in `MapToResponseDto`.
2. The progress update currently uses `Update.Inc(c => c.Progress, challenge.Progress)`, which increments by the cumulative value. It should use `Update.Set(c => c.Progress, challenge.Progress)` after calculating the new total.

The Flutter details page can send and display progress, but it cannot restore the correct value after a refresh until the Backend returns `Progress`.

## Recommended exception handling

Wrap `updateParticipantAsync` in the controller and return `400 Bad Request` for validation errors such as a challenge that has not started, has ended, or receives an invalid progress value. Keep `404` for a missing challenge or participant.
