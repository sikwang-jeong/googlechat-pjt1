# Card Interaction — Requirements

## Overview
Google Chat Card v2 interactive message system.

## Requirements
- R1: Send Card v2 messages with header, sections, and widgets
- R2: Support TextParagraph, DecoratedText, TextInput, SelectionInput, DateTimePicker, ButtonList widgets
- R3: Handle button click events (`CARD_CLICKED`)
- R4: Open and submit dialogs
- R5: Receive events via HTTP endpoint (`POST /webhook/chat`)
- R6: Support card update strategies: sync update, async REST, new message
