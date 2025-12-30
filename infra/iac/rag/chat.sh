#!/bin/bash

# RAG Knowledge Base Chat Script with Session Management
# Usage: 
#   ./chat.sh "your question"           # Start new session
#   ./chat.sh "follow-up question" -s   # Continue previous session

set -e

# Session file to store session ID
SESSION_FILE=".chat_session"

# Check if input text is provided
if [ -z "$1" ]; then
  echo "Usage: $0 \"your question\" [-s]"
  echo ""
  echo "Options:"
  echo "  -s    Continue previous session (maintains conversation context)"
  echo ""
  echo "Examples:"
  echo "  $0 \"会社の設立日はいつですか？\"              # New session"
  echo "  $0 \"その会社の本店所在地は？\" -s            # Continue session"
  exit 1
fi

INPUT_TEXT="$1"
CONTINUE_SESSION="${2:-}"

# Get Knowledge Base ID from Terraform outputs
KB_ID=$(terraform output -raw knowledge_base_id 2>/dev/null)

if [ -z "$KB_ID" ]; then
  echo "Error: Could not get Knowledge Base ID from Terraform outputs"
  echo "Make sure you are in the correct directory and Terraform has been applied"
  exit 1
fi

# Determine session ID
if [ "$CONTINUE_SESSION" = "-s" ] && [ -f "$SESSION_FILE" ]; then
  SESSION_ID=$(cat "$SESSION_FILE")
  echo "=== Continuing Session ==="
else
  SESSION_ID="session-$(uuidgen | tr '[:upper:]' '[:lower:]')"
  echo "$SESSION_ID" > "$SESSION_FILE"
  echo "=== New Session Started ==="
fi

echo "Knowledge Base ID: $KB_ID"
echo "Session ID: $SESSION_ID"
echo "Question: $INPUT_TEXT"
echo "========================"
echo ""

# Build the command with optional session-id
if [ "$CONTINUE_SESSION" = "-s" ]; then
  # Continue existing session
  aws bedrock-agent-runtime retrieve-and-generate \
    --input "{\"text\":\"$INPUT_TEXT\"}" \
    --retrieve-and-generate-configuration "{
      \"type\": \"KNOWLEDGE_BASE\",
      \"knowledgeBaseConfiguration\": {
        \"knowledgeBaseId\": \"$KB_ID\",
        \"modelArn\": \"arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0\"
      }
    }" \
    --session-id "$SESSION_ID" \
    --region us-east-1 \
    --query 'output.text' \
    --output text
else
  # Start new session (first call creates the session)
  RESPONSE=$(aws bedrock-agent-runtime retrieve-and-generate \
    --input "{\"text\":\"$INPUT_TEXT\"}" \
    --retrieve-and-generate-configuration "{
      \"type\": \"KNOWLEDGE_BASE\",
      \"knowledgeBaseConfiguration\": {
        \"knowledgeBaseId\": \"$KB_ID\",
        \"modelArn\": \"arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0\"
      }
    }" \
    --region us-east-1 \
    --output json)
  
  # Extract and save session ID
  NEW_SESSION_ID=$(echo "$RESPONSE" | jq -r '.sessionId')
  if [ -n "$NEW_SESSION_ID" ] && [ "$NEW_SESSION_ID" != "null" ]; then
    echo "$NEW_SESSION_ID" > "$SESSION_FILE"
  fi
  
  # Display response
  echo "$RESPONSE" | jq -r '.output.text'
fi

echo ""
echo ""
echo "Tip: Use './chat.sh \"your follow-up question\" -s' to continue this conversation"

