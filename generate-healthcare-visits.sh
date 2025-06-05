#!/bin/bash

# Kafka configuration
TOPIC="healthcare-visits"
BROKER="localhost:9092"
KAFKA_PRODUCER="/opt/kafka/bin/kafka-console-producer.sh"  # Adjust if needed

# Output file
OUTFILE="/tmp/healthcare_visit.json"

# Chapter codes
CHAPTER_CODES=("Z" "I" "K" "S" "J" "N" "O" "C" "G" "F" "OTHER")

while true; do
    # Random values
    patient_id=$(( RANDOM % 1024 ))
    facility_id=$(( RANDOM % 64 ))
    diagnosis_code_dim=$(( RANDOM % 500 ))

    # Current timestamp (epoch seconds)
    now_epoch=$(date +%s)

    # Full 7-day range in seconds = 604800
    # Use two RANDOMs to simulate a better 31-bit random number
    offset_seconds=$(( (RANDOM << 15 | RANDOM) % 604800 ))

    # Subtract to get visit_end_ts in the past week
    visit_end_epoch=$(( now_epoch - offset_seconds ))
    visit_end_ts=$(date -u -d "@$visit_end_epoch" +"%Y-%m-%dT%H:%M:%SZ")

    # Pick a random duration: 10 to 120 minutes before end
    visit_duration_sec=$(( (RANDOM % 111 + 10) * 60 ))  # 600 to 7200 sec
    visit_start_epoch=$(( visit_end_epoch - visit_duration_sec ))
    visit_start_ts=$(date -u -d "@$visit_start_epoch" +"%Y-%m-%dT%H:%M:%SZ")

    chapter_code=${CHAPTER_CODES[$RANDOM % ${#CHAPTER_CODES[@]}]}
    triage_level=$(( RANDOM % 5 + 1 ))

    # Build JSON and write to file
    echo "{\"patient_id\": $patient_id, \"facility_id\": $facility_id, \"visit_start_ts\": \"$visit_start_ts\", \"visit_end_ts\": \"$visit_end_ts\", \"chapter_code\": \"$chapter_code\", \"triage_level\": $triage_level, \"diagnosis_code_dim\": $diagnosis_code_dim}  " > "$OUTFILE"

    # Publish to Kafka from file
    cat "$OUTFILE" | "$KAFKA_PRODUCER" --bootstrap-server "$BROKER" --topic "$TOPIC"

    sleep 1
done
