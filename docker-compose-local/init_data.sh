#!/bin/bash
#
# Description: init tendmint node data
# Author: Hongbo Liu
# Email: hbliu@freewheel.com
# CreatTime: 2018-04-09 17:34:35 EDT

rm -rf *data

docker run --rm -v `pwd`/node1_data:/tendermint tendermint/tendermint init
docker run --rm -v `pwd`/node2_data:/tendermint tendermint/tendermint init

echo "Node1 ID: $(docker run --rm -v `pwd`/node1_data:/tendermint tendermint/tendermint show_node_id)"
echo "Node2 ID: $(docker run --rm -v `pwd`/node2_data:/tendermint tendermint/tendermint show_node_id)"

cat node2_data/config/genesis.json | jq ".validators |= .+ $(cat node1_data/config/genesis.json | jq '.validators')" > final_genesis.json

cp ./final_genesis.json ./node2_data/config/genesis.json
cp ./final_genesis.json ./node1_data/config/genesis.json

# gsed -i '/auth_enc/s/true/false/' node1_data/config/config.toml
# gsed -i '/auth_enc/s/true/false/' node2_data/config/config.toml
