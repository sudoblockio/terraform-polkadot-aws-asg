package test

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"log"
	"os"
	"path"
	"testing"
)

func TestTerraformStandalone(t *testing.T) {
	t.Parallel()

	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/standalone")

	cwd, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	fixturesDir := path.Join(cwd, "fixtures")


	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
		terraform.Destroy(t, terraformOptions)

		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
		aws.DeleteEC2KeyPair(t, keyPair)
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, keyPair := configureTerraformOptions(t, exampleFolder, fixturesDir)
		test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptions)
		test_structure.SaveEc2KeyPair(t, exampleFolder, keyPair)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)

		testLbEndpoints(t, terraformOptions)
	})
}


// func configureTerraformOptions(t *testing.T, exampleFolder string, fixturesDir string) (*terraform.Options, *aws.Ec2Keypair) {
//
// 	uniqueID := random.UniqueId()
// 	awsRegion := "us-east-2"
//
// 	keyPairName := fmt.Sprintf("terratest-ssh-example-%s", uniqueID)
// 	keyPair := aws.CreateAndImportEC2KeyPair(t, awsRegion, keyPairName)
//
// 	terraformOptions := &terraform.Options{
// 		TerraformDir: exampleFolder,
//
// 		// Variables to pass to our Terraform code using -var options
// 		Vars: map[string]interface{}{
// 			"aws_region":    awsRegion,
// 			"public_key":    keyPair.PublicKey,
// 		},
// 	}
//
// 	return terraformOptions, keyPair
// }


