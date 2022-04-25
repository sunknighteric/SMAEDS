#!/usr/bin/env bash


#Specify  the bits
ReconList="/opt/checking/ReconList.txt"
Report="/opt/checking/Report.txt"
#you can mannully set your email subject
EmailSubject="=="
#domain admin's email address
EmailTo="XXX"
#ssmtp setting the sender email address
EmailFr="XXX"
EmailText="/opt/checking/EmailText.txt"
SendEmail="1"
DeleteTemp="1"
#use shodan need you to apply your own code
ShodanAPI="xxx"
Logfile="/opt/checking/Logfile.txt"
LogReport="/opt/checking/LogReport.txt"


#The Meat is all below.
echo "Running"


#initialize Shodan
echo "Initializing Shodan API"
shodan init ${ShodanAPI}
echo ""


#Delete some temp stuff before starting
rm -f ${Report}
rm -f ${ReconList}
rm -f ${EmailText}

#Setup Email
echo "To: ${EmailTo}">> ${EmailText}
echo "From: SMAEDS <${EmailFr}">>${EmailText}
echo "Subject: ${EmailSubject}" >>${EmailText}
echo "">>${EmailText}


#Start Writing Report
echo "Detection Report" >> ${Report}
echo "------------------" >> ${Report}

#Read the syslog for Bind9 Messages and get the IP passed from Recipient SMTP servers
#spfdemo.spftrap.com is our example domain, you need to change to your own domain name.
logtail /var/log/syslog | grep -i "spfdemo.spftrap.com" | cut -d"(" -f 2 | cut -d")" -f 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v 192.168.0.4 | sort | uniq > ${ReconList}
tail -n 100 /var/log/syslog | grep -i "spfdemo.spftrap.com" | sort | uniq >> ${Logfile}
sort -n ${Logfile} | uniq > ${LogReport}


echo "Suspicious IP" >>${Report}
cat ${ReconList}>>${Report}
echo "------------------">>${Report}
echo "">>${Report}


while read p
do
 #PLACE YOUR RECON BITS HERE
 echo "">>${Report}
 echo "">>${Report}
 echo Running Report for ${p}

 echo "The following is the IP address $p report"  >>${Report}
 echo "------------------">>${Report}
 echo "">>${Report}
 tail -n 100 /opt/AutoSPFRecon/LogReport.txt | grep $p >>${Report}
 echo "">>${Report}
 echo "IP分析">>${Report}
 shodan host $p >>${Report}

# curl "http://ipapi.ipip.net/find?addr=$p" -H "Token:9c2633649d07a43b51acfbcb3375526a0799fdd2" >>${Report}


  echo "------------------">>${Report}
 echo "Above is the IP address  $p Report.">>${Report}
done < ${ReconList}


echo "------------------"
# echo "Reoprt EOF">>${Report}
echo "" >>${Report}



# IF RECON LIST >=1 AND SENDEMAIL=1 THEN SEND EMAIL
if [ $(wc -l < ${ReconList}) -ge "1" ] && [ ${SendEmail} -eq "1" ]
then
 echo "Emailing"
 sed 's/^/\t\t/' ${Report} >> ${EmailText}
 ssmtp ${EmailTo} < ${EmailText}
else
 echo "Not Emailing, SendEmail=0 or ReconList=1"
fi



# IF DELETETEMP = 1 THEN DELETE TEMP STUFF
if [ ${DeleteTemp} -eq "1" ]
then
 echo "Cleanup"
 rm -f ${Report}
 rm -f ${ReconList}
 rm -f ${EmailText}
else
 echo "Not cleaning up, DeleteTemp=0"
fi




echo "Done"


