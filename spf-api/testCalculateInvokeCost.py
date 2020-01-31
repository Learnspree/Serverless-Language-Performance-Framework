import unittest
import os
from decimal import *
from getruntime import calculatecost

class TestCalculateInvokeCost(unittest.TestCase):
    expectedAzureInvokeCost = '0.0000002'
    expectedAWSLambdaInvokeCost = '0.0000002'

    azureFunctionsPlatformName = 'Azure Functions'
    awsLambdaPlatformName = 'AWS Lambda'
    unknownPlatformName = 'Unknown Serverless Platform'

    # TODO - remove 'AAA' when figure out how to change test order from alphabetical
    def testCalculateAAAInvokeCostWithoutEnvVariablesSet(self):
        with self.assertRaises(KeyError):
            azureInvokeCost = calculatecost.calculateInvokeCost('Azure Functions')

    def testCalculateInvokeCostAzure(self):
        os.environ['AZURE_FUNCTIONS_INVOKE_COST'] = self.expectedAzureInvokeCost
        returnedInvokeCost = calculatecost.calculateInvokeCost(self.azureFunctionsPlatformName)
        self.assertEqual(returnedInvokeCost, Decimal(self.expectedAzureInvokeCost))

    def testCalculateInvokeCostAzure(self):
        os.environ['AWS_LAMBDA_INVOKE_COST'] = self.expectedAWSLambdaInvokeCost
        returnedInvokeCost = calculatecost.calculateInvokeCost(self.awsLambdaPlatformName)
        self.assertEqual(returnedInvokeCost, Decimal(self.expectedAWSLambdaInvokeCost))

    def testCalculateInvokeCostAzure(self):
        os.environ['AWS_LAMBDA_INVOKE_COST'] = self.expectedAWSLambdaInvokeCost
        returnedInvokeCost = calculatecost.calculateInvokeCost(self.unknownPlatformName)
        self.assertEqual(returnedInvokeCost, Decimal(self.expectedAWSLambdaInvokeCost))

if __name__ == '__main__':
    unittest.main()