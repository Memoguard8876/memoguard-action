package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
)

type finding struct {
	RuleID      string `json:"rule_id"`
	Severity    string `json:"severity"`
	FieldPath   string `json:"field_path"`
	Description string `json:"description"`
	Remediation string `json:"remediation"`
}

type report struct {
	Findings []finding `json:"findings"`
}

func escape(value string) string {
	value = strings.ReplaceAll(value, "%", "%25")
	value = strings.ReplaceAll(value, "\r", "%0D")
	value = strings.ReplaceAll(value, "\n", "%0A")
	return value
}

func escapeProperty(value string) string {
	value = escape(value)
	value = strings.ReplaceAll(value, ":", "%3A")
	value = strings.ReplaceAll(value, ",", "%2C")
	return value
}

func annotate(reader io.Reader, writer io.Writer) error {
	var result report
	if err := json.NewDecoder(io.LimitReader(reader, 2<<20)).Decode(&result); err != nil {
		return fmt.Errorf("decode report: %w", err)
	}
	for _, item := range result.Findings {
		level := "warning"
		if item.Severity == "block" {
			level = "error"
		}
		message := escape(item.FieldPath + ": " + item.Description + ". " + item.Remediation)
		if _, err := fmt.Fprintf(writer, "::%s title=%s::%s\n", level, escapeProperty(item.RuleID), message); err != nil {
			return err
		}
	}
	return nil
}

func main() {
	if err := annotate(os.Stdin, os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, "MemoGuard: invalid scan report")
		os.Exit(2)
	}
}
