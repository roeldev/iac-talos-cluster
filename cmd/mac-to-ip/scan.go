// Copyright (c) 2023, Roel Schut. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"bufio"
	"bytes"
	"github.com/go-pogo/errors"
	"os/exec"
	"strings"
)

const (
	foundHost = "Nmap scan report for "
	foundMac  = "MAC Address: "
)

func scanSubnet(cidr []string, targetMacs []string) (map[string]string, error) {
	b, err := exec.Command("nmap", append([]string{"-sn"}, cidr...)...).Output()
	if err != nil {
		return nil, errors.WithStack(err)
	}

	scan := bufio.NewScanner(bytes.NewBuffer(b))
	scan.Split(bufio.ScanLines)

	hasTargets := len(targetMacs) > 0
	result := make(map[string]string)

	var foundHostLine string
	for scan.Scan() {
		line := scan.Text()
		if strings.HasPrefix(line, foundHost) {
			foundHostLine = line
			continue
		}
		if !strings.HasPrefix(line, foundMac) {
			continue
		}

		line = strings.TrimPrefix(line, foundMac)
		line = strings.SplitN(line, " ", 2)[0]
		if hasTargets && !contains(targetMacs, line) {
			continue
		}

		foundHostLine = strings.TrimPrefix(foundHostLine, foundHost)
		result[line] = foundHostLine // macaddr => ip
	}

	return result, nil
}

func contains(list []string, str string) bool {
	for _, test := range list {
		if test == str {
			return true
		}
	}
	return false
}
