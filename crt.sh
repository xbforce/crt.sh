#!/usr/bin/bash

# https://github.com/xbforce
# https://twitter.com/xbforce

# This tool grabs subdomains from https://crt.sh

if [[ -z $1 ]]; then
    echo "[*] Grab subdomains from https://crt.sh"
    echo "[*] Usage: $0 <domains.txt>"
    exit 0
fi

exit_code=$!


domains=$1

echo "! Depends on how big your domains' list is, it may take some time to complete the task."
echo "! Check subdomain_crt directory to see the results."

for domain in $(cat $1); do

    if [[ ! -d subdomain_crt ]]; then
        mkdir subdomain_crt && cd subdomain_crt && mkdir $domain && cd $domain
    else
        cd subdomain_crt
        if [[ ! -d $domain ]]; then
            mkdir $domain && cd $domain
        else
            cd $domain
        fi
    fi

    curl -L --silent --max-time 180 --url "https://crt.sh/?q=$domain" | grep "<TD>" | grep -v "=" | sed 's/ //g' | sed 's/<\<BR\>>/\n/g' | sed -E -e 's/[</TD>]//g' | sed 's/[*]//' | sed 's/^[.]//' | sed '/^[[:space:]]*$/d' | grep $domain > tmp_results_crt.txt &&

    # It can be contained some subdomains that are missed in the above command:
    curl -L --silent --max-time 180 --url "https://crt.sh/?q=$domain" | grep "<BR>" | sed 's/ //g' | sed 's/<\<BR\>>/\n/g' | sed -E -e 's/[</TD>]//g' | sed 's/[*]//' | sed 's/^[.]//' | sed '/^[[:space:]]*$/d' | grep $domain | sort -u -d >> tmp_results_crt.txt &&

    sort -u -d tmp_results_crt.txt > crt_$domain.txt &&
    rm tmp_results_crt.txt &&

    cd ../..

done

wait $exit_code
