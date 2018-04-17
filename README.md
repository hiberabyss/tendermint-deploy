# What are they

* `docker` contains some dockerfiles for building necessary docker images
* `docker-compose-local` is about how to setup multiple tendermint nodes in local via docker-compose
    * Pre-Requirement:
        * `jq` needs to be installed with `brew install jq` or `sudo apt-get install jq`
        * For Mac user, `gnu-sed` needs to be installed with `brew install gnu-sed`
    * Run `./init_data.sh` first;
    * Replace each node's ID in `docker-compose.yml` file
* `k8s` is about how to setup tendermint cluster via kubernetes
    * use `make` to start
    * use `make destroy` to delete the tendermint cluster
