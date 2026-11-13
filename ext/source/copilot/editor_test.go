package copilot

import (
	"context"
	"os/exec"
	"path/filepath"
	"testing"
	"time"
)

func TestLuaSideWithAFakeCopilot(t *testing.T) {
	bin, err := exec.LookPath("nvim")
	if err != nil {
		t.Skip("nvim is not installed")
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Minute)
	defer cancel()
	script := filepath.Join("testdata", "copilot_test.lua")
	if out, err := exec.CommandContext(ctx, bin, "--clean", "-l", script).CombinedOutput(); err != nil {
		t.Fatalf("%s: %v\n%s", script, err, out)
	}
}
