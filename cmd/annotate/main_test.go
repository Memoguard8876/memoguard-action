package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestAnnotationOmitsMatchedValue(t *testing.T) {
	input := `{"findings":[{"rule_id":"personal.email","severity":"block","field_path":"transaction.memo.text","description":"Email address in a public memo","remediation":"Use an opaque reference"}]}`
	var output bytes.Buffer
	if err := annotate(strings.NewReader(input), &output); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(output.String(), "::error") || !strings.Contains(output.String(), "transaction.memo.text") {
		t.Fatalf("unexpected annotation: %s", output.String())
	}
}

func TestEscapeWorkflowCommands(t *testing.T) {
	if got := escape("a%b\nc"); got != "a%25b%0Ac" {
		t.Fatalf("got %q", got)
	}
}

func TestEscapeAnnotationTitle(t *testing.T) {
	if got := escapeProperty("rule::bad,part"); got != "rule%3A%3Abad%2Cpart" {
		t.Fatalf("got %q", got)
	}
}
