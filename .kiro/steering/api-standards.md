# API Standards

## Response Format

### Card response
```json
{
  "cardsV2": [{ "cardId": "...", "card": { "header": {}, "sections": [] } }]
}
```

### Text response
```json
{ "text": "message" }
```

### Dialog open
```json
{
  "actionResponse": {
    "type": "DIALOG",
    "dialogAction": { "dialog": { "body": {} } }
  }
}
```

### Dialog close
```json
{
  "actionResponse": {
    "type": "DIALOG",
    "dialogAction": { "actionStatus": "OK" }
  }
}
```

## HTTP Status Codes
- `200` — success
- `401` — JWT verification failed
- `400` — disallowed query or bad request
- `502` — upstream (on-premise) error from Cloud Run

## Card Builder Note
Card Builder input: `card` body only (no `cardsV2` wrapper).
API response: full `cardsV2` wrapper required.
