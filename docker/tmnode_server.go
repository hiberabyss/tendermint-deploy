package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
)

func getNodeIDHandler(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, executeCommand("tendermint", "show_node_id"))
}

func executeCommand(name string, arg ...string) string {
	cmd := exec.Command(name, arg...)
	stdout, err := cmd.StdoutPipe()

	if err != nil {
		log.Fatalf("Error when execute tendermint show_node_id, %s\n", err)
	}
	defer stdout.Close()

	if err := cmd.Start(); err != nil {
		log.Fatalf("Execute command error, %s\n", err)
	}

	cmdOut, _ := ioutil.ReadAll(stdout)

	return string(cmdOut)
}

func getPubKeyHandler(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, executeCommand("bash", "-c", "cat /tendermint/config/priv_validator.json | jq '.pub_key'"))
}


func main() {
	fmt.Println("Server started ...")
	http.HandleFunc("/node_id", getNodeIDHandler)
	http.HandleFunc("/pub_key", getPubKeyHandler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("Fail to start server, %s\n", err)
	}
}
