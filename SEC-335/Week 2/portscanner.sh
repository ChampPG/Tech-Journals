#!/bin/bash

if [[ -z $1 && -z $2 ]] ; then
    echo "No host or port file supplied"
    exit 1
elif [[ -z $1 ]] ; then
    echo "No host file supplied"
    exit 1
elif [[ -z $2 ]] ; then
    echo "No port file supplied"
    exit 1
fi

hostfile=$1
portfile=$2

if [[ $3 -eq 1 ]]; then
  echo "-- Host file format check --"
  for host in $(cat $hostfile); do
    if [[ $host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$host is formated properly"
    else
      echo "$host is not the correct format"
    fi
  done

  echo ""

  echo "-- Port file format check --"
  for port in $(cat $portfile); do
    if [[ $port =~ ^(0|6[0-5][0-5][0-3][0-5]|[1-5][0-9][0-9][0-9][0-9]|[1-9][0-9]{0,3})$ ]]; then
      echo "$port is formated properly"
    else
      echo "$port is not the correct format"
    fi
  done

  echo ""

  echo "-- Open port checker --"
fi
echo "host,port"
for host in $(cat $hostfile); do
  for port in $(cat $portfile); do
    timeout .1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && echo "$host,$port"
  done
done
