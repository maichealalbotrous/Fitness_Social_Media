# Backend patches for the new contract

These are **patches to apply in the .NET repository**; the Flutter repository does not modify the Backend.

## 1. Preserve challenge goal while recording progress

In `Services/ChallengeSerivce.cs`, both progress branches currently execute:

```csharp
_challenges.UpdateOne(
    c => c.Id == challengeId,
    Builders<Challenge>.Update.Inc(c => c.Goal, challenge.Goal));
```

This increments/replaces the challenge goal and is incorrect. Replace it with an increment of the stored progress:

```csharp
_challenges.UpdateOne(
    c => c.Id == challengeId,
    Builders<Challenge>.Update.Inc(c => c.Progress, goalParticipation));
```

A safer implementation is to update the participant and challenge atomically, but the minimum correction is to update `Progress`, never `Goal`.

## 2. Return progress to Flutter

`ChallengeResponseDto` currently returns `Goal` but not `Progress`, while the Flutter details and list pages render `progress / goal`. Add:

```csharp
 double Progress
```

after `Goal`, then include `challenge.Progress` in every `ChallengeResponseDto` construction, including `MapToResponseDto` and `GetChallengeByIdAsync`.

The Flutter mapper already accepts `progress`, `Progress`, `goalParticipation`, and `GoalParticipation`.

## 3. Return proper authorization errors

`ChallengeController` should catch `UnauthorizedAccessException` and return HTTP 403 instead of an unhandled 500:

```csharp
catch (UnauthorizedAccessException ex)
{
    return StatusCode(StatusCodes.Status403Forbidden,
        new { message = ex.Message });
}
```

Apply this to challenge creation and joining if the service can throw authorization exceptions.

## 4. Comments do not contain usernames by design

`CommentResponseDto` contains `AuthorId` but no username or profile picture. Therefore the Flutter client resolves each `AuthorId` through `GET /api/Users/{id}`. The Flutter implementation now loads comment profiles independently, so one missing user no longer prevents the remaining comments from receiving their names.

## 5. Media contract

The new endpoints are:

- `POST /api/Media/upload-profile-picture`, multipart field: `file`, response: `{ url, fileName }`.
- `POST /api/Media/upload-post-media`, multipart field: `files`, response: `{ count, urls }`.
- `POST /api/Auth/logout`, authorized, empty JSON object accepted.

The Flutter client is aligned with these paths and response keys.
