#!/bin/bash

if ps -eo pid,cmd | grep yandexdisk_logger.sh | grep -v grep | grep -v $$ > /dev/null; then
  exit 1
fi

LOG_DIR="/var/packages/YandexDisk/var/logs"
LOG_INTERVAL=60

mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_DIR}/status_history.log"
LAST_STATUS_FILE="${LOG_DIR}/last_status.log"

[ -f "$LOG_FILE" ] || touch "$LOG_FILE"
[ -f "$LAST_STATUS_FILE" ] || touch "$LAST_STATUS_FILE"

while true; do
  CURRENT_TIME=$(date "+%d.%m.%Y - %H:%M:%S")
  CURRENT_OUTPUT=$(yandex-disk status)
  LAST_STATUS=$(<"$LAST_STATUS_FILE")

  if [[ "$LAST_STATUS" == "Error: daemon not started" ]]; then
      if [[ $(tail -n 1 "$LOG_FILE") != "" ]]; then
          sed -i '$ d' "$LOG_FILE"
      fi

      echo "[$CURRENT_TIME] DAEMON NOT STARTED" >> "$LOG_FILE"
      echo "$CURRENT_OUTPUT" > "$LAST_STATUS_FILE"

      if [[ "$CURRENT_OUTPUT" != "$LAST_STATUS" ]]; then
          if [ -s "$LOG_FILE" ]; then
              echo "" >> "$LOG_FILE"
          fi
          {
              echo "[$CURRENT_TIME]"
              echo "$CURRENT_OUTPUT"
              echo ""
          } >> "$LOG_FILE"

          echo "$CURRENT_OUTPUT" > "$LAST_STATUS_FILE"
      fi

  else

      if [[ "$CURRENT_OUTPUT" != "$LAST_STATUS" ]]; then
          if [ -s "$LOG_FILE" ]; then
              echo "" >> "$LOG_FILE"
          fi
          {
              echo "[$CURRENT_TIME]"
              echo "$CURRENT_OUTPUT"
              echo ""
          } >> "$LOG_FILE"

          echo "$CURRENT_OUTPUT" > "$LAST_STATUS_FILE"
      else
          if [[ $(tail -n 1 "$LOG_FILE") != "" ]]; then
              sed -i '$ d' "$LOG_FILE"
          fi
          echo "[$CURRENT_TIME] STATUS UNCHANGED" >> "$LOG_FILE"
      fi
  fi

  sleep "$LOG_INTERVAL"
done
