// Copyright (c) 2023, Roel Schut. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"encoding/json"
	"flag"
	"github.com/go-pogo/errors"
	"os"
	"strings"
)

func main() {
	subnet := "10.0.0.1/24"

	fs := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fs.StringVar(&subnet, "subnet", subnet, "subnet(s) (cidr) to scan (comma separated list)")
	errors.FatalOnErr(fs.Parse(os.Args[1:]))

	res, err := scanSubnet(strings.Split(subnet, ","), fs.Args())
	errors.FatalOnErr(err)

	// wanneer res < args, vraag om input?
	// of arp -a | grep mac via proxmox host

	out, err := json.Marshal(res)
	errors.FatalOnErr(err)
	_, _ = os.Stdout.Write(out)
}
