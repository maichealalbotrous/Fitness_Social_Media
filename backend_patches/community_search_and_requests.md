# Community search and requests backend patch

The new controller currently defines both `GET /api/Community/{id}` and `GET /api/Community/{name}`. These routes collide. Keep the ID route and change the name route to an explicit route:

```csharp
[HttpGet("by-name/{name}")]
public async Task<IActionResult> GetByName(string name)
{
    var community = await _communityService.GetCommunityByNameAsync(name);
    if (community == null)
        return NotFound(new { message = "No Community found." });
    return Ok(community);
}
```

The Flutter client should then use:

```text
GET /api/Community/by-name/{name}
```

The requests endpoint is already:

```text
GET /api/Community/{communityId}/requests
```

and returns request objects containing `id`, `communityId`, `userId`, `username`, and `imageUrl`.

The Flutter client currently targets the screenshot route for name lookup until this explicit backend route is applied. After applying the patch, change the Flutter path to `/api/Community/by-name/{name}`.
