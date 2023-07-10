DIR="/home/ec2-user/efs/angelo"
STATUS=$(systemctl is-active httpd.service)
NAME=$(systemctl status httpd | head -n 1 | awk '{print $2}')
DATE=$(date +"%m/%d/%Y")
DAY=$(date +"%A")
HOURS=$(date +"%H:%M:%S")
INFORMATION="
--------log information--------------------------
        $DATE - $DAY
        $HOURS
        The service '$NAME' is currently $STATUS
"

if [[ "$STATUS" == "active" ]]; then
        if [[ -d $DIR  ]];then
                if [[ -f "$DIR/log_inactive.txt" ]]; then
                        rm -rf "$DIR/log_inactive.txt"
                fi
                if [[ -f "$DIR/log_active.txt"  ]]; then
                        echo "$INFORMATION" > "$DIR/log_active.txt"
                else
                        touch "$DIR/log_active.txt"
                        echo "$INFORMATION" > "$DIR/log_active.txt"
                fi
        else
                touch "$DIR" ; touch "$DIR/log_active.txt"
                echo "$INFORMATION" > "$DIR/log_active.txt"
        fi
else
        if [[ -d $DIR  ]];then
                if [[ -f "$DIR/log_active.txt" ]]; then
                        rm -rf "$DIR/log_active.txt"
                fi
                if [[ -f "$DIR/log_inactive.txt"  ]]; then
                        echo "$INFORMATION" > "$DIR/log_inactive.txt"
                else
                        touch "$DIR/log_inactive.txt"
                        echo "$INFORMATION" > "$DIR/log_inactive.txt"
                fi
        else
                touch "$DIR" ; touch "$DIR/log_inactive.txt"
                echo "$INFORMATION" > "$DIR/log_inactive.txt"
        fi
fi
if [[ -f "$DIR/log_file.txt" ]]; then
        echo "$NAME - $DATE - $DAY - $HOURS - $STATUS" >> "$DIR/log_file.txt"
else
        touch "$DIR/log_file.txt"
        echo "$NAME - $DATE - $DAY - $HOURS - $STATUS" >> "$DIR/log_file.txt"
fi
exit 0