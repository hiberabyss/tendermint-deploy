#!/bin/bash
#
# Description: init tendmint node data
# Author: Hongbo Liu
# Email: hbliu@freewheel.com
# CreatTime: 2018-04-09 17:34:35 EDT

node_cnt=4
tendermint_img="hbliu/tendermint"

is_osx () {
    [[ "$OSTYPE" =~ ^darwin ]] || return 1
}

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

    if is_osx; then
        rm -rf *data
    else
        sudo rm -rf *data
    fi
}
init

default_genesis="./node1_data/config/genesis.json"

for (( i = 1; i <= $node_cnt; i++ )); do
    if ! is_osx; then
        mkdir -p node${i}_data
        chmod 777 node${i}_data
    fi

    docker run --rm -v `pwd`/node${i}_data:/tendermint $tendermint_img init

    if ! is_osx; then
        sudo chmod -R 777 node${i}_data
    fi

    node_id=$(docker run --rm -v `pwd`/node${i}_data:/tendermint $tendermint_img show_node_id)
    echo "Node$i ID: $node_id"
    $SED -i "s/[0-9a-f]\{40\}@tm_node$i/$node_id@tm_node$i/g" ./docker-compose.yml

    if [[ $i != 1 ]]; then
        echo $(cat $default_genesis | jq ".validators |= .+ $(cat node${i}_data/config/genesis.json | jq '.validators')") > $default_genesis
    fi

    echo $(cat $default_genesis | jq ".validators[$i-1].name = \"tm_node$i\" ") > $default_genesis
done

for (( i = 2; i <= $node_cnt; i++ )); do
    cp -f $default_genesis ./node${i}_data/config/genesis.json
done
