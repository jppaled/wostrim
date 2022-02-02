#! /bin/bash

function jsonValue() {
    KEY=$1
    num=$2
    awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

function getJsonValue() {
    grep -o '"'$1'":"[^"]*' | cut -d'"' -f4
}

