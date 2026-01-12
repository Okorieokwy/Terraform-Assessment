package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraform(t *testing.T) {
	options := &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			// Add your variables here
		},

		EnvVars: map[string]string{
			// Add your environment variables here
		},

		NoColor: true,
	}

	defer terraform.Destroy(t, options)

	initAndApply := terraform.InitAndApply(t, options)

	// Add your assertions here
	if !initAndApply {
		t.Fatal("Terraform apply failed")
	}
}