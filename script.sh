#!/bin/bash

# Set your Telegram Bot API details
BOT_TOKEN="<YOUR_BOT_TOKEN>"
CHAT_ID="<YOUR_CHAT_ID>"
THREAD_ID="<YOUR_THREAD_ID>"

# Path to the file containing domains
DOMAINS_FILE="domains.txt"

# Read each domain from the file and process it
while IFS= read -r DOMAIN; do
    # Calculate expiration date in seconds since epoch
    EXPIRATION_DATE=$(whois "$DOMAIN" | awk -F: '/Expiration/ { print $2 }' | date -f - +"%s")

    # Calculate current date in seconds since epoch
    CURRENT_DATE=$(date +"%s")

    # Calculate the threshold date (7 days before expiration)
    THRESHOLD_DATE=$(date -d "7 days" +"%s")

    # Check if the domain is within the 7-day threshold
    if [ "$EXPIRATION_DATE" -lt "$THRESHOLD_DATE" ]; then
        # Domain is within 7 days of expiration, send message to Telegram
        MESSAGE="Domain $DOMAIN needs to be renewed. Expiration date: $(date -d "@$EXPIRATION_DATE" +"%Y-%m-%d")"
        
        # Use curl to send a message to the Telegram bot
        curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$MESSAGE&reply_to_message_id=$THREAD_ID"
    fi
done < "$DOMAINS_FILE"
