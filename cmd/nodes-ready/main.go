// Copyright (c) 2023, Roel Schut. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"context"
	"github.com/go-pogo/errors"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {
	ctx, cancelFn := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancelFn()
	errors.FatalOnErr(run(ctx, os.Args[1:]))
	_, _ = os.Stdout.WriteString(`{"ready":"true","time":"` + time.Now().String() + `"}`)
}

func run(ctx context.Context, nodes []string) error {
	for {
		if err := ctx.Err(); err != nil {
			return err
		}

		time.Sleep(10 * time.Second)
		var ready int

		b, err := exec.Command("kubectl", "get", "nodes").Output()
		if err != nil {
			continue
		}

		lines := strings.Split(string(b), "\n")
		for _, line := range lines[1:] {
			if line == "" {
				continue
			}

			i := strings.IndexRune(line, ' ')
			if !contains(nodes, line[:i]) {
				continue
			}

			for ; i < len(line) && line[i] == ' '; i++ {
			}

			status := line[i : i+strings.IndexRune(line[i:], ' ')]
			if status == "Ready" {
				ready++
			}
		}

		if ready == len(nodes) {
			break
		}
	}
	return nil
}

func contains(list []string, str string) bool {
	for _, s := range list {
		if s == str {
			return true
		}
	}
	return false
}
