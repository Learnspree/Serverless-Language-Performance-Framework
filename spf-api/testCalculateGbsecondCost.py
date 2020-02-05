import unittest
import os
from decimal import *
from getruntime import calculatecost

class TestCalculateGBSecondCost(unittest.TestCase):
    expectedAzureGBSecondCost = '0.000016'
    expectedAWSLambdaGBSecondCost = '0.00001667'

    azureFunctionsPlatformName = 'Azure Functions'
    awsLambdaPlatformName = 'AWS Lambda'
    unknownPlatformName = 'Unknown Serverless Platform'

    # TODO - remove 'AAA' when figure out how to change test order from alphabetical
    def testCalculateAAAGBSecondCostWithoutEnvVariablesSet(self):
        with self.assertRaises(KeyError):
            azureGBSecondCost = calculatecost.calculateGBSecondCost('Azure Functions')

    def testCalculateGBSecondCostAzure(self):
        os.environ['AZURE_FUNCTIONS_GBSECOND_COST'] = self.expectedAzureGBSecondCost
        returnedGBSecondCost = calculatecost.calculateGBSecondCost(self.azureFunctionsPlatformName)
        self.assertEqual(returnedGBSecondCost, Decimal(self.expectedAzureGBSecondCost))

    def testCalculateGBSecondCostAzure(self):
        os.environ['AWS_LAMBDA_GBSECOND_COST'] = self.expectedAWSLambdaGBSecondCost
        returnedGBSecondCost = calculatecost.calculateGBSecondCost(self.awsLambdaPlatformName)
        self.assertEqual(returnedGBSecondCost, Decimal(self.expectedAWSLambdaGBSecondCost))

    def testCalculateGBSecondCostAzure(self):
        os.environ['AWS_LAMBDA_GBSECOND_COST'] = self.expectedAWSLambdaGBSecondCost
        returnedGBSecondCost = calculatecost.calculateGBSecondCost(self.unknownPlatformName)
        self.assertEqual(returnedGBSecondCost, Decimal(self.expectedAWSLambdaGBSecondCost))

if __name__ == '__main__':
    unittest.main()