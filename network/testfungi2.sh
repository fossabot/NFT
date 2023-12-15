#!/bin/bash

C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

# subinfoln echos in blue color
function infoln() {
  echo -e "${C_YELLOW}${1}${C_RESET}"
}

function subinfoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

# add PATH to ensure we are picking up the correct binaries
export PATH=${HOME}/fabric-samples/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config

# Chaincode config variable

# CHANNEL_NAME="mychannel"
CC_NAME="fungi"
CHANNEL_NAME="mychannel"




ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

PEER_CONN_PARMS="--peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses localhost:11051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt"


## test the 계좌조회("admin") for org1
infoln "계좌조회 테스트(admin) on peer0.org1..."

set -x
peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"BalanceOf", "Args":["x509::CN=org1admin,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=fabric-ca-server,OU=Fabric,O=Hyperledger,ST=North Carolina,C=US"]}' >&log.txt
{ set +x; } 2>/dev/null
cat log.txt




## test the 먹이기 for org1
infoln "먹이기 테스트 on peer0.org1..."

set -x
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS -c '{"function":"Feed", "Args":["0","0"]}' >&log.txt
{ set +x; } 2>/dev/null
cat log.txt

sleep 3

## test the 버섯소유자조회("nomame") for org1
infoln "버섯소유자조회 테스트(noname) on peer0.org1..."

set -x
peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"OwnerOf", "Args":["1"]}' >&log.txt
{ set +x; } 2>/dev/null
cat log.txt

sleep 3

## test the 버섯판매 for org1
infoln "판매 테스트 on peer0.org1..."

set -x
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS -c '{"function":"TransferFrom", "Args":["x509::CN=org1admin,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=fabric-ca-server,OU=Fabric,O=Hyperledger,ST=North Carolina,C=US","cloudshin","0"]}' >&log.txt
{ set +x; } 2>/dev/null
cat log.txt

sleep 3

## test the 버섯소유자조회("testfungus1") for org1
infoln "버섯소유자조회 테스트(testfungus1) on peer0.org1..."

set -x
peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function":"OwnerOf", "Args":["0"]}' >&log.txt
{ set +x; } 2>/dev/null
cat log.txt