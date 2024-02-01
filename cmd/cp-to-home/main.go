// Copyright (c) 2023, Roel Schut. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"github.com/go-pogo/errors"
	"io"
	"os"
	"path/filepath"
	"strings"
)

const linuxHomePrefix = "~/"

func main() {
	if len(os.Args) < 3 {
		errors.FatalOnErr(
			errors.WithExitCode(errors.Errorf("Usage: %s <src> <dest>", os.Args[0]), 1),
		)
	}

	srcPath := os.Args[1]
	destPath := os.Args[2]

	if !filepath.IsAbs(srcPath) {
		if workdir, err := os.Getwd(); err == nil {
			srcPath = filepath.Clean(filepath.Join(workdir, srcPath))
		}
	}

	if strings.HasPrefix(destPath, linuxHomePrefix) {
		destPath = destPath[len(linuxHomePrefix):]
	} else if strings.HasPrefix(destPath, "/") {
		destPath = destPath[1:]
	}

	home, err := os.UserHomeDir()
	errors.FatalOnErr(err)
	destPath = filepath.Clean(filepath.Join(home, destPath))

	src, err := os.Open(srcPath)
	errors.FatalOnErr(err)
	defer src.Close()

	dest, err := os.Create(destPath)
	errors.FatalOnErr(err)
	defer dest.Close()

	_, err = io.Copy(dest, src)
	errors.FatalOnErr(err)
	os.Stdout.WriteString("{}")
	//fmt.Fprintf(os.Stdout, `{"src":"%s","dest":"%s","written":"%d"}\n`, srcPath, destPath, written)
}
