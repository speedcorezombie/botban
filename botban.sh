#!/bin/bash
/usr/bin/lynx --dump http://`hostname`/server-status --width 255 | sort -k12| grep -v 127.0.0| egrep "wp-login.php H|administrator/index.php HTT"| awk '{print $11}' |  sort -u > list
for a in `cat list`; do echo $a ` geoiplookup $a`; done | grep Ru | awk '{print $1}' > ru
RU=`wc -l ru | awk '{print $1}'`
LIST=`wc -l list | awk '{print $1}'`
echo "ru: $RU"
echo "list: $LIST"
if [ ${RU} -gt 0 ]; then
        for a in `cat ru`;do
                sed -i '/'$a'/d' list;
                /sbin/iptables -I bad-http -s $a -j DROP;
        done ;
fi
sed -i 's/\.[0-9]*$/\.0/' list
if [ ${LIST} -gt 0 ]; then
        for a in `cat list`; do
                /sbin/iptables -I bad-http -s $a/24 -j DROP;
        done;
fi
/sbin/service httpd restart
