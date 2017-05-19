#!/bin/bash

# startup file
cat << EOF >> ~/startup.sh
#!/bin/bash
# startup file
# for some reason screen doesn't start without sleep
sleep 10
EOF

# add it to cron
crontab -l | { cat; echo "@reboot bash startup.sh &"; } | crontab -
service cron restart