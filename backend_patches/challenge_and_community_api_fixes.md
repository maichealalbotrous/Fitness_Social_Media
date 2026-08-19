# Backend fixes required for Challenge and Community APIs

## 1. Challenge update participant

In `Services/ChallengeSerivce.cs`, inside `updateParticipantAsync`, both update branches currently execute:

```csharp
_challenges.UpdateOne(c => c.Id == challengeId,
    Builders<Challenge>.Update.Inc(c => c.Goal, challenge.Goal));
```

This increments `Goal` and can corrupt the original challenge target. Replace the entire update operation in both branches with:

```csharp
_challenges.UpdateOne(
    c => c.Id == challengeId,
    Builders<Challenge>.Update.Set(c => c.Progress, challenge.Progress));
```

The Flutter request is already correct for the controller contract:

```http
PUT /api/Challenge/{challengeId}/update-participant
Content-Type: application/json

5
```

The request body must be a raw JSON number, not `{ "progress": 5 }`.

## 2. Community search by name

In `CommunityController.cs`, two routes currently use the same template:

```csharp
[HttpGet("{id}")]
[HttpGet("{name}")]
```

The second route must be explicit and must call the name service:

```csharp
[HttpGet("name/{name}")]
public async Task<IActionResult> GetByName(string name)
{
    var community = await _communityService.GetCommunityByNameAsync(name);
    if (community == null)
        return NotFound(new { message = "No Community found." });

    return Ok(community);
}
```

Flutter calls the resulting endpoint as:

```http
GET /api/Community/name/{name}
```

The current Flutter Community datasource already uses this explicit route.

## 3. Error handling recommendation

The Challenge controller should also translate service validation exceptions into HTTP 400 responses instead of allowing them to become HTTP 500 responses:

```csharp
try
{
    var result = await _challengeService.updateParticipantAsync(
        challengeId, userId, goalParticipation);
    return Ok(new { message = result });
}
catch (InvalidOperationException ex)
{
    return BadRequest(new { message = ex.Message });
}
```

This preserves the existing `404` response for a missing challenge or participant while returning useful validation messages for challenges that have not started, have ended, or receive invalid progress values.
