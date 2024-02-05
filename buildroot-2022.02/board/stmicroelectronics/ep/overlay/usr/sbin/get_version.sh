#!/bin/bash

# echo 5.19.0.A010924
# uname -a | awk '{print $3$8$9$12}'

date="$(uname -a | awk '{print $9}')"
month="$(uname -a | awk '{print $8}')"
year="$(uname -a | awk '{print $12}')"

case "$month" in
	"Jan")
	month="1"
	;;
	
	"Feb")
	month="2"
	;;
	
	"Mar")
	month="3"
	;;
	
	"Apr")
	month="4"
	;;
	
	"May")
	month="5"
	;;
	
	"Jun")
	month="6"
	;;
	
	"Jul")
	month="7"
	;;
	
	"Aug")
	month="8"
	;;
	
	"Sep")
	month="9"
	;;
	
	"Oct")
	month="10"
	;;
	
	"Nov")
	month="11"
	;;
	
	"Dec")
	month="12"
	;;
esac;
numyear=$((year - 2000))
ver="B0100.$month.$date.$numyear"
echo $ver
