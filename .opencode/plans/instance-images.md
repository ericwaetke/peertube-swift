# Plan: Real Instance Images

## Goal
Fetch and display real instance avatars (images) for `InstanceIndicator` across the application, and include `InstanceIndicator` next to usernames in the video comments.

## Steps

### 1. Update TubeSDK
- Modify `TubeSDK`'s `ServerConfig.swift` to include `public let avatars: [ActorImage]?` inside `InstanceInfo`. This enables decoding the instance's avatars from the `/api/v1/config` endpoint.

### 2. Implement Background Instance Sync
- Update `PeertubeDependency` in `PeertubeOrchastrator.swift` with a new method: `syncInstanceInfo(host: String) async -> Instance?`.
- This method will:
  - Check the database for an existing instance with an `avatarUrl`.
  - If missing, execute `INSERT OR IGNORE` so we don't violate foreign keys.
  - Fetch the `ServerConfig` from the PeerTube API.
  - Update the instance in the DB with its `name` and `avatarUrl`.

### 3. Fix Database Overwrites
- In `Feed.swift`, `VideoDetails.swift`, and `VideoChannel.swift`, instances are currently saved via `Instance.upsert { Instance(host: ...) }`. This uses `ON CONFLICT REPLACE` which erases the existing `name` and `avatarUrl` fields.
- Replace these operations with calls to the new `syncInstanceInfo` method (running asynchronously where needed) to safely persist the database instance while retaining its fetched metadata.

### 4. Update UI Components
- **VideoCard**: Pass `row.instance?.avatarUrl` into the `InstanceIndicator`.
- **VideoChannel**: Pass `store.state.instance?.avatarUrl` into the `InstanceIndicator`.
- **VideoComments**:
  - Add `var instanceAvatars: [String: String] = [:]` to `VideoCommentsFeature.State`.
  - When `commentsLoaded` fires, loop over all unique hosts from the comments (`comment.account?.host`) and populate `instanceAvatars` via `syncInstanceInfo` or a direct DB lookup.
  - In `VideoCommentsView`, display `InstanceIndicator(instanceName: host, instanceImage: store.state.instanceAvatars[host])` next to the user's name.

## End Result
- `InstanceIndicator` will display actual instance logos instead of the fallback `laser.burst` icon.
- `InstanceIndicator` will appear in the comments section to clearly identify which instance a user is from.
