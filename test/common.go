package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"strconv"
	"strings"
	"testing"
	"time"
)

func testLbEndpoints(t *testing.T, terraformOptions *terraform.Options) {

	loadBalancerIp := strings.Trim(terraform.Output(t, terraformOptions, "dns_name"), "\"")

	expectedStatus := "200"
	body := strings.NewReader(`{"id":1, "jsonrpc":"2.0", "method":"system_health", "params":[]}`)
	url := fmt.Sprintf("http://%s:9933", loadBalancerIp)
	headers := make(map[string]string)
	headers["Content-Type"] = "application/json"

	description := fmt.Sprintf("curl to LB %s with error command", loadBalancerIp)
	maxRetries := 150 // 5 min
	timeBetweenRetries := 2 * time.Second

	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {

		outputStatus, _, err := http_helper.HTTPDoE(t, "POST", url, body, headers, nil)

		if err != nil {
			return "", err
		}

		if strings.TrimSpace(strconv.Itoa(outputStatus)) != expectedStatus {
			return "", fmt.Errorf("expected SSH command to return '%s' but got '%s'", expectedStatus, strconv.Itoa(outputStatus))
		}

		return "", nil
	})
}

func configureTerraformOptions(t *testing.T, exampleFolder string, fixturesDir string) (*terraform.Options, *aws.Ec2Keypair) {

	uniqueID := random.UniqueId()
	awsRegion := "us-west-2"

	keyPairName := fmt.Sprintf("terratest-ssh-example-%s", uniqueID)
	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)

	terraformOptions := &terraform.Options{
		TerraformDir: exampleFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":    awsRegion,
			"public_key":    keyPair.PublicKey,
		},
	}

	return terraformOptions, keyPair
}

