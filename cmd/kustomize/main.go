// Copyright (c) 2023, Roel Schut. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
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
	if len(os.Args) < 2 {
		panic("no arguments")
	}

	args := []string{"kustomize"}
	if os.Args[1] == "--" {
		args = append(args, os.Args[2:]...)
	} else {
		args = append(args, os.Args[1:]...)
	}

	b, err := exec.Command("kubectl", args...).Output()
	errors.FatalOnErr(err)

	out, err := json.Marshal(result{
		Manifests: fmt.Sprintf("# kubectl %s\n\n%s", strings.Join(args, " "), string(b)),
	})
	errors.FatalOnErr(err)
	_, _ = os.Stdout.Write(out)
}
