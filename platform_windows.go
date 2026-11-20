//go:build windows

package main

import (
	"os"
	"os/exec"
	"runtime"
)

type termState struct{}

func termGet(fd int) (*termState, error) { return nil, os.ErrInvalid }

func termSet(fd int, old *termState, echo bool) error { return nil }

func isTerminal(fd uintptr) bool {
	fi, err := os.Stdin.Stat()
	return err == nil && fi.Mode()&os.ModeCharDevice != 0
}

func fsFreeAt(path string) (total, avail uint64, ok bool) { return 0, 0, false }

func unameStable() (string, error) {
	h, err := os.Hostname()
	if err != nil {
		return "", err
	}
	return "windows " + runtime.GOOS + " " + runtime.GOARCH + " " + h, nil
}

func execReplace(bin string, argv []string, env []string) error {
	cmd := exec.Command(bin, argv[1:]...)
	cmd.Env = env
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return err
	}
	os.Exit(0)
	return nil
}
