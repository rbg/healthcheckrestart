package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"
)

func handler(w http.ResponseWriter, r *http.Request) {
	if getRandomNumberBetweenZeroAndOne() == 0 {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "OK!")
	} else {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "FAIL")
	}
}

func getRandomNumberBetweenZeroAndOne() int {
	random := rand.New(rand.NewSource(time.Now().UnixNano()))
	return random.Intn(2)
}

func main() {
	http.HandleFunc("/healthcheck", handler)
	http.ListenAndServe(":8080", nil)
}
