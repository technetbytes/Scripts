#####################################################################
#																	#
#						Name = 	"CouchDB curl script"				#
#						Version = "0.1"								#
#						Created By = Yotera Inc.	 				#
#																	#
#  This script used for couchdb manipulation only.					#
#####################################################################


#!/bin/bash

CTURLENCODED="Content-Type:application/x-www-form-urlencoded"
CTJSON="Content-Type:application/json"
CTXML="Content-Type:application/xml"
CT=$CTURLENCODED

TEMPHEADERS="Headers.txt"
red='\033[0;31m'
green='\033[0;32m'
NC='\033[0m' 				# No Color

#Global Variables
gpassword=""
gusername=""
ghttpmethod="POST"
gdatabase=""
ghostname="127.0.0.1:5984"

function quit {
	echo "Application exit(0) ..."	
	exit 0
}

function sessioncreation {
	
	echo -e "${red}Enter information for session creation${NC}"
	echo -e "======================================"

	echo -e "${red}Enter couchdb IP address with PORT${NC}"
	read hostname
	echo -e "${red}Enter database name${NC}"
	read database

	if [ ! -z "$hostname" ]
	then
		ghostname=$hostname 	#="127.0.0.1:5984"
	fi

	if [ ! -z "$database" ]
	then
		gdatabase=$database		#="indybuild_objects"
	fi
	
	if [ $2!="nosession" ]; 
	then

		echo -e "${red}Enter http method${NC}"
		read httpmethod
		echo -e "${red}Enter username${NC}"
		read username
		echo -e "${red}Enter password${NC}"
		read password

		if [ ! -z "$httpmethod" ]
		then
			ghttpmethod=$httpmethod	#="POST"
		fi

		if [ ! -z "$username" ]
		then
			gusername=$username		#="ABBA"
		fi

		if [ ! -z "$password" ]
		then
			gpassword=$password		#="dancing-queen"
		fi

	################################################################################################
	echo "connecting to server ...."
	session_req="curl -$1X $ghttpmethod http://$ghostname/_session -H $CT -d name=$gusername&password=$gpassword -D $TEMPHEADERS"
	#echo $session_req
	session_res=`$session_req`
	echo -e "${green}session created in temp Hearder file${NC}"
	echo -e "===================================="
	################################################################################################

	fi
}

function changehttpmethod {		
	echo -e "${red}You are currently using $ghttpmethod method, do you want to change it [Y/N]${NC}"
	read userwants
	if test "$userwants" == "Y"
	then
	#	echo -e "${red}Enter http method[GET,POST,PUT,DELETE]${NC}"
	#	read httpmethod
	#	echo "Now $httpmethod method will be used"		
	echo -e "${red}Enter http method[GET,POST,PUT]${NC}"
	read httpmethod
		if [[ "$httpmethod" == "POST" || "$httpmethod" == "GET" || "$httpmethod" == "PUT" ]]
		then							
			ghttpmethod=$httpmethod			
			echo "Now $ghttpmethod method will be used"
			echo -e "==========================="		
		else
			echo "Unable to change http method"
			quit		
		fi
	fi		
}

function contenttypetojson {
	echo -e "${red}You are currently using $CT content-type, do you want to change into JSON [J] or XML [X]${NC}"
	read userwants
	if test "$userwants" == "J" 
	then
		CT=$CTJSON
		echo "content-type change to JSON"
	elif test "$userwants" == "X"
	then
		CT=$CTXML
		echo "content-type change to XML"
	fi
}

function uploadjsondocument {
	echo -e "${red}Now create documents in the database using bulk operation...${NC}"
	echo -e "${red}Now enter json document file path${NC}"
	read docPath

	if [ -z "$docPath" ]		
	then	
		#@$HOME/Documents/dvd_views.json
		echo "No json document path is entered ..."
		echo "Application exit(0) ..."	
		exit 0
	fi
	data_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase/_bulk_docs -b $TEMPHEADERS -H $CT -T $docPath"
	#echo $data_request
	response=`$data_request`
	echo $response 
}

function createnewdb {
	echo -e "${red}Now creating database ...${NC}"
	db_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase -b $TEMPHEADERS -H $CT"
	#echo $db_request
	response=`$db_request`
	echo $response
}

function uploaddesigndocument {
	echo -e "${red}Now enter design document file path${NC}"
	read docPath

	if [ -z "$docPath" ]		
	then	
		#@$HOME/Documents/dvd_views.json
		echo "No design document path is entered ..."
		echo "Application exit(0) ..."	
		exit 0
	fi

	echo -e "${red}Now enter design document name${NC}"
	read designDocName

	if [ -z "$designDocName" ]		
	then
		echo "No design document name is entered"
		echo "Application exit(0) ..."	
		exit 0	
	fi	


	if [ $2 = "nosession" ]; 
	then
		db_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase/_design/$designDocName -d @$docPath"	

	else
		db_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase/_design/$designDocName -b $TEMPHEADERS -d @$docPath"	
	fi	

	#echo $db_request
	response=`$db_request`
	echo $response

	#db_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase/_design/$designDocName -b $TEMPHEADERS -d @$docPath"	
	#echo $db_request
	#response=`$db_request`
	#echo $response
}

function createdocumentindb {
	echo -e "${red}Now enter json${NC}"
	read json

	if [ -z "$json" ]		
	then		
		echo "Only valid json execpted ..."
		echo "Application exit(0) ..."	
		exit 0
	fi

	json_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase -H $CT -b $TEMPHEADERS -d $json"	
	echo $json_request
	response=`$json_request`
	echo $response
}

function updateattribute {
	echo -e "${red}Now enter design document name${NC}"
	read designdoc

	if [ -z "$designdoc" ]		
	then		
		echo "design document name execpted ..."
		echo "Application exit(0) ..."	
		exit 0
	fi

	echo -e "${red}Now enter update function name${NC}"
	read function

	if [ -z "$function" ]		
	then		
		echo "update function name execpted ..."
		echo "Application exit(0) ..."	
		exit 0
	fi	
	
	updatefun_request="curl -$1X $ghttpmethod http://$ghostname/$gdatabase/_design/$designdoc/_update/$function -b $TEMPHEADERS"	
	echo $updatefun_request
	response=`$updatefun_request`
	echo $response
}

#Main bash execution
clear

if test "$1" == "-u"	#Session + Upload JSON document	
	then
		echo -e "To Upload JSON document enter database connectivity information. If anyone of the parameter is empty default value will be set: \n"

		#session creation		
		sessioncreation "$2"
		#change http method to GET,POST,PUT
		changehttpmethod
		#change http context-type to json
		contenttypetojson
		#upload json document for bulk operation
		uploadjsondocument "$2"

elif test "$1" == "-d"	#session creation + database creation
	then			
		echo -e "To create new database, please enter couchdb host address. If anyone of the parameter is empty default value will be set: \n"

		#session creation		
		sessioncreation "$2"
		#change http method to GET,POST,PUT
		changehttpmethod
		#create new database
		createnewdb "$2"

elif test  "$1" == "-dd" #session + upload design document	
	then
		echo -e "Please enter information for couchdb document upload. If anyone of the parameter is empty default value will be set: \n"

		#session creation		
		sessioncreation "$2"
		#change http method to GET,POST,PUT
		changehttpmethod
		#upload design document file
		uploaddesigndocument "$2"

elif test  "$1" == "-j" #session + user json object	
	then
		echo -e "To create document in the database, please enter information. If anyone of the parameter is empty default value will be set: \n"

		#session creation		
		sessioncreation "$2"
		#change http method to GET,POST,PUT
		changehttpmethod
		#change http context-type to json
		contenttypetojson
		#user enter json for new document
		createdocumentindb "$2"

elif test  "$1" == "-uns" #upload json object with no session
	then
		echo -e "Please enter information for couchdb document upload. If anyone of the parameter is empty default value will be set: \n"

		#session creation		
		sessioncreation "$2" "nosession"
		#change http method to GET,POST,PUT
		changehttpmethod		
		#upload design document file
		uploaddesigndocument "$2" "nosession"

elif test  "$1" == "-uf" 
	then
		echo -e "Please enter information for couchdb update attribute function call. If anyone of the parameter is empty default value will be set: \n"

		#session creation		
		sessioncreation "$2"
		#change http method to GET,POST,PUT
		changehttpmethod
		#call update attribute function
		updateattribute "$2"

elif test "$1" == "-luf"
	then
		#session creation		
		sessioncreation "$2"
	while true; do
		#change http method to GET,POST,PUT
		changehttpmethod
		#call update attribute function
		updateattribute "$2"
	done

elif test "$1" == "-ldd"
	then
		#session creation		
		sessioncreation "$2"
	while true; do
		#change http method to GET,POST,PUT
		changehttpmethod
		#upload design document file
		uploaddesigndocument "$2"
	done

elif test "$1" == "-h"
	then
	echo "-j --- 1. create session + 2. user define json object"	
	echo "-uf --- 1. create session + 2. call update attribute function"	
	echo "-u --- 1. create session + 2. upload json document"
	echo "-d --- 1. create session + 2. database creation"
	echo "-dd --- 1. create session + 2. upload design document"
	echo "-uns --- 1. upload json object with no session"
	echo "-luf --- 1. create session + 2. call update attribute function + 3. in a circle"
	echo "-ldd --- 1. create session + 2. upload design document + 3. in a circle"
	echo "-h --- view help"
fi