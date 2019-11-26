#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo
echo -e "$RED==== Keypairs generation (Machine A) ====$NC"
echo

echo -e "    $GREEN===>$NC Generating private key for machine A using the RSA algorithm"
sleep 1
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:3 -out privkey-A.pem

echo -en "    $YELLOW===>$NC View generated private key? (Y/n): "
read choice
case "$choice" in
	N|n) ;;
	*) openssl pkey -in privkey-A.pem -text | less ;;
esac

echo -e "    $GREEN===>$NC Extracting the public key for machine A from the generated private key"
sleep 1
openssl pkey -in privkey-A.pem -out pubkey-A.pem -pubout

echo -en "    $YELLOW===>$NC View extracted public key? (Y/n): "
read choice
case "$choice" in
	N|n) ;;
	*) openssl pkey -in pubkey-A.pem -pubin -text | less ;;
esac

echo
echo -e "$RED==== Keypairs generation (Machine B) ====$NC"
echo

echo -e "    $GREEN===>$NC Generating private key for machine B using the RSA algorithm"
sleep 1
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -pkeyopt rsa_keygen_pubexp:3 -out privkey-B.pem

echo -en "    $YELLOW===>$NC View generated private key? (Y/n): "
read choice
case "$choice" in
	N|n) ;;
	*) openssl pkey -in privkey-B.pem -text | less ;;
esac

echo -e "    $GREEN===>$NC Extracting the public key for machine B from the generated private key"
sleep 1
openssl pkey -in privkey-B.pem -out pubkey-B.pem -pubout

echo -en "    $YELLOW===>$NC View extracted public key? (Y/n): "
read choice
case "$choice" in
	N|n) ;;
	*) openssl pkey -in pubkey-B.pem -pubin -text | less ;;
esac

echo
echo -e "$RED==== Machine A ====$NC"
echo

echo -e "    $GREEN===>$NC Creating the plain text message to send"
sleep 2
$EDITOR message.txt

echo -e "    $GREEN===>$NC Generating sha1 hash for the plain text message"
sleep 1
openssl dgst -sha1 message.txt

echo -e "    $GREEN===>$NC Encrypting the message"
sleep 1
openssl pkeyutl -encrypt -in message.txt -pubin -inkey pubkey-B.pem -out ciphertext.bin

echo -en "    $YELLOW===>$NC View the encrypted payload? (Y/n): "
read choice
case "$choice" in
	N|n) ;;
	*) less ciphertext.bin ;;
esac

echo -e "    $GREEN===>$NC Generating signature"
sleep 1
openssl dgst -sha1 -sign privkey-A.pem -out signature.bin ciphertext.bin

echo -en "    $YELLOW===>$NC View the generated signature? (Y/n): "
read choice
case "$choice" in
	N|n) ;;
	*) less signature.bin ;;
esac

echo
echo -e "$RED==== Machine B ====$NC"
echo

echo -e "    $GREEN===>$NC Verifying the signature"
sleep 1
openssl dgst -sha1 -verify pubkey-A.pem -signature signature.bin ciphertext.bin

echo -e "    $GREEN===>$NC Decrypting the cipher text"
sleep 1
openssl pkeyutl -decrypt -in ciphertext.bin -inkey privkey-B.pem -out received-message.txt

echo -e "    $GREEN===>$NC Reading the recieved message"
sleep 2
less received-message.txt
