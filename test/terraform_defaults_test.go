package test

// import (
// 	"github.com/gruntwork-io/terratest/modules/aws"
// 	"github.com/gruntwork-io/terratest/modules/terraform"
// 	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
// 	"log"
// 	"os"
// 	"path"
// 	"testing"
// )
//
// func TestTerraformDefaults(t *testing.T) {
// 	t.Parallel()
//
// 	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/defaults")
//
// 	cwd, err := os.Getwd()
// 	if err != nil {
// 		log.Println(err)
// 	}
// 	fixturesDir := path.Join(cwd, "fixtures")
//
//
// 	defer test_structure.RunTestStage(t, "teardown", func() {
// 		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
// 		terraform.Destroy(t, terraformOptions)
//
// 		keyPair := test_structure.LoadEc2KeyPair(t, exampleFolder)
// 		aws.DeleteEC2KeyPair(t, keyPair)
// 	})
//
// 	test_structure.RunTestStage(t, "setup", func() {
// 		terraformOptions, keyPair := configureTerraformOptions(t, exampleFolder, fixturesDir)
// 		test_structure.SaveTerraformOptions(t, exampleFolder, terraformOptions)
// 		test_structure.SaveEc2KeyPair(t, exampleFolder, keyPair)
//
// 		terraform.InitAndApply(t, terraformOptions)
// 	})
//
// 	test_structure.RunTestStage(t, "validate", func() {
// 		terraformOptions := test_structure.LoadTerraformOptions(t, exampleFolder)
//
// 		testLbEndpoints(t, terraformOptions)
// 	})
// }
