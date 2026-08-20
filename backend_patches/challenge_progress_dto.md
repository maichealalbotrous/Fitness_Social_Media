# Challenge progress persistence patch

The Flutter client sends the participant progress endpoint as a raw JSON number, for example `30` with `Content-Type: application/json`, because the current .NET action binds to `double`.

The endpoint must persist the value for the authenticated participant, not overwrite the challenge owner's goal. The service should resolve the current user from the JWT, locate that user's participant record inside the challenge, and update only that record's progress. It should reject updates after progress reaches the goal and return the updated participant progress in the response.

The response returned by the challenge details / fetch-by-goal endpoints must include the authenticated participant's persisted progress. Recommended DTO fields are `challengeId`, `participantId`, `userId`, `goal`, `progress`, and `isCompleted`. The `progress` field should be numeric (`double`) and populated from the participant record. If the endpoint returns a challenge collection, each item must be mapped using the current user's participant record rather than the challenge creator's goal value.

After applying the backend change, verify with an authenticated request:

```bash
curl -X PUT http://localhost:5024/api/Challenge/{challengeId}/update-participant \
  -H "Authorization: Bearer {JWT}" \
  -H "Content-Type: application/json" \
  -d '30'
```

Then call the challenge details/fetch-by-goal endpoint with the same JWT and confirm that `progress` remains `30` after restarting the API and Flutter application.
