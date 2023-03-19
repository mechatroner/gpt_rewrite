#!/usr/bin/env bash

api_key=""
prompt=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --api_key) api_key="$2"; shift ;;
        --prompt) prompt="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$api_key" ]]; then
    echo "Error: --api_key flag is empty"
    exit 1
fi

if [[ -z "$prompt" ]]; then
    echo "Error: --prompt flag is empty"
    exit 1
fi


curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $api_key" \
  -d "{
    \"model\": \"code-davinci-002\",
    \"prompt\": \"$prompt\",
    \"presence_penalty\": 0.5,
    \"max_tokens\": 500,
    \"temperature\": 0
  }"

