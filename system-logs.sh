#!/bin/bash
LOG_DIR="/var/log"
ARCHIVE_DIR="/var/log/archives"
REPORT_FILE="/tmp/log_report.txt"
MAILGUN_DOMAIN="sandbox4b818b692de14ee2baffc415eb0cfc40.mailgun.org"
MAILGUN_API_KEY="5f66487254ffc720ae5e7d64e68dfe48-e71583bb-4321a5b7"
EMAIL_TO="ashoknallam03@gmail.com"
EMAIL_FROM="SYSTEM Logs <postamster@$MAILGUN_DOMAIN>"
THRESHOLD_DAYS=30

mkdir -p "$ARCHIVE_DIR"

echo "Log Maintenace Report - $(date)" > "$REPORT_FILE"
echo "__________________________________________" >> "$REPORT_FILE"

echo "Compressing log files...." >> "$REPORT_FILE"
COMPRESS_SUCCESS=0
COMPRESS_FAIL=0

for file in "$LOG_DIR"/*.log; do
	if [ -f "$file" ]; then
		gzip -c "$file" > "$ARCHIVE_DIR/$(basename "$file").gz" 2>> "$REPORT_FILE"
		if [ $? -eq 0 ]; then
			echo " Compressed: $file" >> "$REPORT_FILE"
			COMPRESS_SUCCESS=$((COMPRESS_SUCCESS+1))
		else
			echo " failed: $file " >> "$REPORT_FILE"
			COMPRESS_FAIL=$((COMPRESS_FAIL+1))
		fi
	fi
done
echo -e "\nDeleting archives older than $THRESHOLD_DAYS days---" >> "$REPORT_FILE"
find "$ARCHIVE_DIR" -name "*.gz" -type -mtime +$THRESHOLD_DAYS -exec rm -v {} \; >> "$REPORT_FILE" 2>$1

echo -e "\nSummary: " >> "$REPORT_FILE"
echo " Suuccessful Compressions: $COMPRESS_SUCCESS " >> "$REPORT_FIAL"
echo " Failed Compressions: $COMPRESS_FAIL " >> "$REPORT_FAIL"

curl -s --user "api:$MAILGUN_API_KEY"\
	"https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages" \
    -F from="$EMAIL_FROM" \
    -F to="$EMAIL_TO" \
    -F subject="Daily Log Maintenance Report - $(date +%F)" \
    -F text="$(cat "$REPORT_FILE")"

