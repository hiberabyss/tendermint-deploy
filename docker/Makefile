all: tmnode_img tmnode_server

tmnode_server: tmnode_server.go
	docker run --rm -it -v `pwd`:/tmp/tmnode -w "/tmp/tmnode" golang bash -c "go build $<"

tmnode_img: ./Dockerfile-tmnode tmnode_server
	docker build -t hbliu/tendermint -f ./Dockerfile-tmnode .
