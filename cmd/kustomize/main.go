// Copyright (c) 2023, Roel Schut. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/go-pogo/errors"
	"os"
	"os/exec"
	"strings"
)

type result struct {
	Dir       string `json:"dir"`
	Manifests string `json:"manifests"`
}

func main() {
	errors.FatalOnErr(run())
}

func run() error {
	if len(os.Args) < 2 {
		return errors.New("no arguments")
	}

	args := []string{"kustomize"}
	if os.Args[1] == "--" {
		args = append(args, os.Args[2:]...)
	} else {
		args = append(args, os.Args[1:]...)
	}

	var buf bytes.Buffer
	cmd := exec.Command("kubectl", args...)
	cmd.Stderr = &buf

	b, err := cmd.Output()
	if err != nil {
		return errors.Wrap(err, buf.String())
	}

	if i := index(args, "-o"); i > 0 {
		b, err = os.ReadFile(args[i+1])
		if err != nil {
			return errors.WithStack(err)
		}
	}

	out, err := json.Marshal(result{
		Manifests: fmt.Sprintf("# kubectl %s\n\n%s", strings.Join(args, " "), string(b)),
	})
	if err != nil {
		return errors.WithStack(err)
	}

	_, err = os.Stdout.Write(out)
	if err != nil {
		return errors.WithStack(err)
	}

	return nil
}

func index(list []string, item string) int {
	for i, v := range list {
		if v == item {
			return i
		}
	}
	return -1
}
