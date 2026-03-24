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

## Card Update Strategy

| Situation | Strategy |
|---|---|
| `refresh_card` clicked | sync update (replace card in webhook response) |
| `run_query` executed | async REST (update card via Chat REST API after Celery completes) |
| Error occurred | sync update (return error_card immediately) |
| After dialog submission | new message (keep original card + send new message) |

## Query Result Card Structure

| Condition | Widget |
|---|---|
| 1–2 columns | `decoratedText` list — `topLabel`: column name, `text`: value |
| 3+ columns | `textParagraph` — HTML table format |
| 0 rows | `textParagraph` — "No results found." |

## Button with Dialog
```json
{
  "text": "Open Dialog",
  "onClick": { "action": { "function": "open_dialog", "interaction": "OPEN_DIALOG" } }
}
```

## Button Examples (all supported functions)
```json
{ "text": "Run Query",    "onClick": { "action": { "function": "run_query" } } }
{ "text": "Refresh",      "onClick": { "action": { "function": "refresh_card" } } }
{ "text": "Open Dialog",  "onClick": { "action": { "function": "open_dialog", "interaction": "OPEN_DIALOG" } } }
```

## Template Gallery Dialog Flow

### Entry
```
admin keyword → Admin Main Dialog → [Template Gallery] button
  → CARD_CLICKED: function=open_dialog, parameters.type=admin_template_gallery
```

### `admin_template_gallery` Dialog
- Lists all 12 templates (ID, name, description) as `decoratedText` rows
- Each row has a [Preview] button

### Preview Flow
```
[Preview] clicked
  → CARD_CLICKED: function=open_dialog, parameters.type=admin_template_preview
                  parameters.template=<template_id>
  → card_builder.build_template(name, TEMPLATE_SAMPLES[name], locale)
  → return dialog with rendered card JSON (visible to requester only)
```

### Button Definition
```json
{
  "text": "Preview",
  "onClick": {
    "action": {
      "function": "open_dialog",
      "interaction": "OPEN_DIALOG",
      "parameters": [
        { "key": "type", "value": "admin_template_preview" },
        { "key": "template", "value": "query_result" }
      ]
    }
  }
}
```

## Endpoints
- `POST /webhook/chat` — button clicks, messages, space events
- `POST /webhook/chat/dialog` — dialog form submissions
- `GET /health` — health check
