#!/bin/bash

# CHANGE THESE
auth_email="mail@dings.de"
auth_key="*******************" # found in cloudflare account settings
zone_name="*******************"
record_name="home.dings.de"
record_identifier="*****************"
# MAYBE CHANGE THESE
ip=$(curl -s http://ipv4.icanhazip.com)
ip_file="ip.txt"
id_file="cloudflare.ids"
log_file="cloudflare.log"



# LOGGER
log() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" >> $log_file
    fi
}

# SCRIPT START
log "Check Initiated"

if [ -f $ip_file ]; then
    old_ip=$(cat $ip_file)
    if [ $ip == $old_ip ]; then
        echo "IP has not changed."
        exit 0
    fi
fi


update=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_name/dns_records/$record_identifier" \
     -H "X-Auth-Email: $auth_email" \
     -H "X-Auth-Key: $auth_key" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'$record_name'","content":"'$ip'","ttl":120,"proxied":false}')



case "$update" in 
  *"\"success\":false"*)
    message="API UPDATE FAILED. DUMPING RESULTS:\n$update"
    log "$message"
    echo -e "$message"
    exit 1;;
  *)
      message="IP changed to: $ip"
    echo "$ip" > $ip_file
    log "$message"
    echo "$message";;
esac