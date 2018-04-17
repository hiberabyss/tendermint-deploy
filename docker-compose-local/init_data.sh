#!/bin/bash
#
# Description: init tendmint node data
# Author: Hongbo Liu
# Email: hbliu@freewheel.com
# CreatTime: 2018-04-09 17:34:35 EDT

rm -rf *data

node_cnt=4
tendermint_img="tendermint/tendermint:0.17.1"

init() {
    SED=sed
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        SED=gsed
        if ! which gsed &> /dev/zero ; then
            brew install gnu-sed
        fi

        if ! which jq &> /dev/zero; then
            brew install jq
        fi
    else
        if ! which jq &> /dev/zero; then
            sudo apt-get install jq -y
        fi
    fi
}
init

default_genesis="./node1_data/config/genesis.json"

for (( i = 1; i <= $node_cnt; i++ )); do
    docker run --rm -v `pwd`/node${i}_data:/tendermint $tendermint_img init
    node_id=$(docker run --rm -v `pwd`/node${i}_data:/tendermint $tendermint_img show_node_id)
    echo "Node$i ID: $node_id"
    $SED -i "s/[0-9a-f]\{40\}@tm_node$i/$node_id@tm_node$i/g" ./docker-compose.yml

    if [[ $i != 1 ]]; then
        echo $(cat $default_genesis | jq ".validators |= .+ $(cat node${i}_data/config/genesis.json | jq '.validators')") > $default_genesis
    fi
done

for (( i = 2; i <= $node_cnt; i++ )); do
    cp -f $default_genesis ./node${i}_data/config/genesis.json
done
