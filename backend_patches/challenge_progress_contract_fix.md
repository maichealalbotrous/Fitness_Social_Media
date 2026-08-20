# Challenge progress contract fix

The endpoint receives a raw JSON number because the controller signature is:

```csharp
[HttpPut("{challengeId}/update-participant")]
public async Task<IActionResult> UpdateParticipant(
    string challengeId,
    [FromBody] double goalParticipation)
```

Correct request:

```http
PUT /api/Challenge/{challengeId}/update-participant
Content-Type: application/json

30
```

Incorrect request:

```json
{
  "challengeId": "...",
  "value": 30
}
```

The service must update the participant's `GoalParticipation` to the received value and set the challenge aggregate progress to the newly calculated value. Do not increment using the cumulative value:

```csharp
Update.Inc(c => c.Progress, challenge.Progress)
```

Use a replacement/set operation instead:

```csharp
Update.Set(c => c.Progress, challenge.Progress)
```

The response DTO must expose progress:

```csharp
public record ChallengeResponseDto(
    string? Id,
    string CreatorId,
    string CommunityId,
    string Name,
    string Description,
    DateTime StartDate,
    DateTime EndDate,
    double Goal,
    double Progress
);
```

Also include `challenge.Progress` in the mapper. Without this field, Flutter can successfully send the update but every subsequent `GET /api/Challenge/{challengeId}` returns a response without progress, so the UI falls back to zero.

Flutter now sends the raw number and applies an optimistic local update after a successful response. Once the Backend DTO includes `Progress`, it can safely refresh details from the server as well.
