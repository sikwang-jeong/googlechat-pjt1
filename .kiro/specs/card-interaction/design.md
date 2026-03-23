# Card Interaction — Design

## Card JSON Structure

### Card Builder input (card body only)
```json
{
  "header": { "title": "...", "subtitle": "...", "imageUrl": "...", "imageType": "CIRCLE" },
  "sections": [{ "header": "...", "widgets": [] }]
}
```

### API response (with cardsV2 wrapper)
```json
{ "cardsV2": [{ "cardId": "main-card", "card": { "header": {}, "sections": [] } }] }
```

## Widget Patterns
```json
{ "textParagraph": { "text": "text <b>bold</b>" } }
{ "decoratedText": { "startIcon": { "knownIcon": "EMAIL" }, "text": "...", "topLabel": "...", "bottomLabel": "..." } }
{ "textInput": { "name": "field", "label": "Label", "type": "SINGLE_LINE", "hintText": "hint" } }
{ "selectionInput": { "name": "field", "label": "Label", "type": "DROPDOWN", "items": [{ "text": "A", "value": "a", "selected": false }] } }
{ "dateTimePicker": { "name": "field", "label": "Label", "type": "DATE_AND_TIME" } }
```

## Button with Dialog
```json
{
  "text": "Open Dialog",
  "onClick": { "action": { "function": "open_dialog", "interaction": "OPEN_DIALOG" } }
}
```

## Endpoints
- `POST /webhook/chat` — button clicks, messages, space events
- `POST /webhook/chat/dialog` — dialog form submissions
- `GET /health` — health check
