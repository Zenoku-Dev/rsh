//go:build !windows

package main

import (
	"bytes"
	"syscall"

	"golang.org/x/sys/unix"
)

type termState = unix.Termios

func termGet(fd int) (*termState, error) {
	return unix.IoctlGetTermios(fd, unix.TCGETS)
}

func termSet(fd int, old *termState, echo bool) error {
	t := *old
	if !echo {
		t.Lflag &^= unix.ECHO
	}
	return unix.IoctlSetTermios(fd, unix.TCSETS, &t)
}

func isTerminal(fd uintptr) bool {
	_, err := unix.IoctlGetTermios(int(fd), unix.TCGETS)
	return err == nil
}

func fsFreeAt(path string) (total, avail uint64, ok bool) {
	var st unix.Statfs_t
	if err := unix.Statfs(path, &st); err != nil {
		return 0, 0, false
	}
	return st.Blocks * uint64(st.Bsize), st.Bavail * uint64(st.Bsize), true
}

func unameStable() (string, error) {
	var uts syscall.Utsname
	if err := syscall.Uname(&uts); err != nil {
		return "", err
	}
	cn := make([]byte, 65)
	for i, c := range uts.Sysname {
		if c == 0 {
			break
		}
		cn[i] = byte(c)
	}
	rel := make([]byte, 65)
	for i, c := range uts.Release {
		if c == 0 {
			break
		}
		rel[i] = byte(c)
	}
	maj := make([]byte, 65)
	for i, c := range uts.Version {
		if c == 0 {
			break
		}
		maj[i] = byte(c)
	}
	return string(cn[:bytes.IndexByte(cn, 0)]) + " " + string(rel[:bytes.IndexByte(rel, 0)]) + " " + string(maj[:bytes.IndexByte(maj, 0)]), nil
}

func execReplace(bin string, argv []string, env []string) error {
	return syscall.Exec(bin, argv, env)
}
