---
name: learn-eventmodelers-api
description: Teaches an agent everything about the eventmodelers platform API — all endpoints, their purpose, request payloads, response shapes, authentication, and element types.
---

# Eventmodelers Platform API

**Base URL**: `http://localhost:3000`

```bash
TOKEN=<supabase-jwt>   API_TOKEN=<x-token>   BASE=http://localhost:3000
ORG=<orgId>   BOARD=<boardId>   NODE=<nodeId>
```

**Auth**: `Authorization: Bearer $TOKEN` (users) · `x-token: $API_TOKEN` (agents) · `x-user-id: $USER_ID` (node mutations)

---

## Boards

```bash
curl $BASE/api/boards -H "Authorization: Bearer $TOKEN"
curl -X DELETE $BASE/api/org/$ORG/boards/$BOARD -H "Authorization: Bearer $TOKEN"
curl $BASE/api/org/$ORG/boards/$BOARD/events -H "Authorization: Bearer $TOKEN"
curl "$BASE/api/org/$ORG/boards/$BOARD/events/search?name=OrderPlaced" -H "Authorization: Bearer $TOKEN"
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/bucket -H "Authorization: Bearer $TOKEN"

# Post board events (nodes / comments / edges)
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/events \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '[{"eventType":"node:created","nodeId":"<uuid>","boardId":"'$BOARD'","timestamp":1234567890}]'
```

---

## Comments

```bash
curl $BASE/api/org/$ORG/boards/$BOARD/nodes/$NODE/comments -H "Authorization: Bearer $TOKEN"

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/nodes/$NODE/comments \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"text":"Needs clarification","type":"TASK","author":"alice"}'
# type: COMMENT | TASK | QUESTION — returns 201 {"id":"<commentId>"}

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/nodes/$NODE/comments/$CID/resolve \
  -H "Authorization: Bearer $TOKEN"

curl -X DELETE $BASE/api/org/$ORG/boards/$BOARD/nodes/$NODE/comments/$CID \
  -H "Authorization: Bearer $TOKEN"
```

---

## Chapters & Timelines

```bash
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/chapters \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{}'

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/timelines/$TL/columns \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"index":2}'

curl -X DELETE $BASE/api/org/$ORG/boards/$BOARD/timelines/$TL/columns/$COL \
  -H "Authorization: Bearer $TOKEN"

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/timelines/$TL/lanes \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"type":"swimlane","label":"Domain Events"}'
# type: actor | interaction | swimlane | spec | feedback

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/timelines/$TL/cells/$CELL/drop \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nodeId":"<uuid>","nodeType":"EVENT"}'
# swimlane→EVENT  interaction→COMMAND/READMODEL  actor→SCREEN/AUTOMATION
```

---

## Nodes

```bash
curl "$BASE/api/org/$ORG/boards/$BOARD/nodes?type=EVENT" -H "Authorization: Bearer $TOKEN"
curl $BASE/api/org/$ORG/boards/$BOARD/nodes/$NODE -H "Authorization: Bearer $TOKEN"

# Create/update node
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/nodes/events \
  -H "Authorization: Bearer $TOKEN" -H "x-user-id: $USER_ID" -H "Content-Type: application/json" \
  -d '[{"id":"<uuid>","eventType":"node:created","nodeId":"<uuid>","boardId":"'$BOARD'","timestamp":1234567890,"meta":{"type":"EVENT","title":"OrderPlaced"},"chapterId":"<id>","cellName":"B2"}]'
# eventType: node:created | node:changed | node:deleted
```

---

## Slices

```bash
# type: state-change (SCREEN+COMMAND+EVENT) | state-view (SCREEN+READMODEL+EVENT) | automation (AUTOMATION+COMMAND+EVENT)
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/timelines/$TL/slices \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"type":"state-change","nodes":{"swimlane":{"title":"OrderPlaced"}}}'
```

---

## Specifications (GWT)

```bash
curl -X POST "$BASE/api/org/$ORG/boards/$BOARD/contexts/Ordering/slices/PlaceOrder/scenarios" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"id":"<uuid>","title":"Happy path","given":["<eventId>"],"when":["<commandId>"],"then":["<eventId2>"]}'
# given: EVENT ids · when: COMMAND id (empty if then=READMODEL) · then: EVENT ids OR one READMODEL

curl "$BASE/api/org/$ORG/boards/$BOARD/contexts/Ordering/spec-info" -H "Authorization: Bearer $TOKEN"
```

---

## Images / Sketches

```bash
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/images/$IMG \
  -H "Authorization: Bearer $TOKEN" -F "file=@image.png"

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/images/$IMG/sketch \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"elements":[{"type":"rectangle","x":1,"y":1,"w":10,"h":5}],"semanticDescription":"Login form"}'

curl -X POST $BASE/api/org/$ORG/boards/$BOARD/image-nodes/$NODE/sketch \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"chapterId":"<id>","cellName":"A1","description":{"elements":[]}}'
```

---

## Slice Data

```bash
curl "$BASE/api/org/$ORG/boards/$BOARD/slicedata?contextName=Ordering" -H "Authorization: Bearer $TOKEN"
curl $BASE/api/org/$ORG/boards/$BOARD/slicedata/slices -H "Authorization: Bearer $TOKEN"
```

---

## Snapshots  (max 3 · 30d · 50MB)

```bash
curl $BASE/api/snapshots -H "Authorization: Bearer $TOKEN"
curl -X POST $BASE/api/snapshots -H "Authorization: Bearer $TOKEN" \
  -F "payloadFile=@board.json" -F "name=my-snapshot" -F "retention=7"
curl -X PATCH $BASE/api/snapshots/$SID/share -H "Authorization: Bearer $TOKEN"
curl -X DELETE $BASE/api/snapshots/$SID -H "Authorization: Bearer $TOKEN"
```

---

## Prompts & Agent

```bash
# Submit prompt (bearer)
curl -X POST $BASE/api/org/$ORG/prompts \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"prompt":"Add OrderShipped event","board_id":"'$BOARD'","timeline_id":"<id>","node_id":"<id>","comment_id":"<id>"}'

# Dequeue next prompt (agent)
curl $BASE/api/org/$ORG/prompts/next -H "x-token: $API_TOKEN"

# Delete processed prompt (agent)
curl -X DELETE $BASE/api/org/$ORG/prompts/$PID -H "x-token: $API_TOKEN"

# Cancel own prompt (user)
curl -X DELETE $BASE/api/org/$ORG/prompts/$PID/user -H "Authorization: Bearer $TOKEN"

# Realtime token (agent)
curl $BASE/api/org/$ORG/prompts/realtime-token -H "x-token: $API_TOKEN"

# Heartbeat
curl -X POST $BASE/api/agent-alive \
  -H "Authorization: Bearer $REALTIME_JWT" -H "Content-Type: application/json" \
  -d '{"token":"'$API_TOKEN'"}'

# Check agent alive (user)
curl $BASE/api/org/$ORG/boards/$BOARD/agent-alive -H "Authorization: Bearer $TOKEN"
```

---

## Extensions

```bash
curl $BASE/api/org/$ORG/boards/$BOARD/extensions -H "Authorization: Bearer $TOKEN"
curl -X PUT $BASE/api/org/$ORG/boards/$BOARD/extensions/git \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"enabled":true}'
```

---

## User Management

```bash
# Commands → {ok, next_expected_stream_version, last_event_global_position}
curl -X POST $BASE/api/creategroup -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"groupId":"<uuid>","name":"My Team"}'
curl -X POST $BASE/api/inviteuser -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"groupId":"<uuid>","email":"user@example.com","invitationId":"<uuid>"}'
curl -X POST $BASE/api/acceptinvite -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"userId":"<uuid>","groupId":"<uuid>","invitationId":"<uuid>"}'
curl -X POST $BASE/api/assignrole -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"userId":"<uuid>","groupId":"<uuid>","role":"admin"}'

# Read models (add ?_id= to filter)
curl $BASE/api/query/group-details-lookup -H "Authorization: Bearer $TOKEN"
curl $BASE/api/query/open-invites -H "Authorization: Bearer $TOKEN"
curl $BASE/api/query/user-group-assignments -H "Authorization: Bearer $TOKEN"
curl $BASE/api/query/users-to-assign-to-groups -H "Authorization: Bearer $TOKEN"
```

---

## Utility

```bash
curl $BASE/api/user -H "Authorization: Bearer $TOKEN"   # current user
curl $BASE/swagger.json                                  # OpenAPI spec
curl -X POST $BASE/api/org/$ORG/boards/$BOARD/import-config \
  -H "Authorization: Bearer $TOKEN" -F "file=@config.json"
```