package main

import (
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"github.com/ardanlabs/conf"
	"github.com/dimfeld/httptreemux/v5"
)

var build = "develop"

func main() {
	g := runtime.GOMAXPROCS(0)
	log.Printf("starting service :Procs ;[%d]", build, g)
	defer log.Println("service ended", build)
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown
	log.Println("stopping service", build)
	conf.String("test")
	httptreemux.New()

}
