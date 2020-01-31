import unittest
import os
from decimal import *
from getruntime import calculatecost

class TestCalculateFunctionCost(unittest.TestCase):
    expectedAzureGBSecondCost = '0.000016'
    expectedAWSLambdaGBSecondCost = '0.00001667'
    expectedAzureInvokeCost = '0.0000002'
    expectedAWSLambdaInvokeCost = '0.0000002'

    testBilledDuration = Decimal('100')
    testMemorySize = Decimal('128')

    azureFunctionsPlatformName = 'Azure Functions'
    awsLambdaPlatformName = 'AWS Lambda'
    unknownPlatformName = 'Unknown Serverless Platform'

    # TODO - remove 'AAA' when figure out how to change test order from alphabetical
    def testCalculateAAAFunctionCostWithoutEnvVariablesSet(self):
        with self.assertRaises(KeyError):
            azureFunctionCost = calculatecost.getCostForFunctionDuration(self.azureFunctionsPlatformName, self.testBilledDuration, self.testMemorySize)

    def testCalculateFunctionCostAzure(self):
        os.environ['AZURE_FUNCTIONS_GBSECOND_COST'] = self.expectedAzureGBSecondCost
        os.environ['AZURE_FUNCTIONS_INVOKE_COST'] = self.expectedAzureInvokeCost
        functionCost = calculatecost.getCostForFunctionDuration(self.azureFunctionsPlatformName, self.testBilledDuration, self.testMemorySize)
        self.assertEqual(functionCost, Decimal('0.0000004'))

    def testCalculateFunctionCostAWSLambda(self):
        os.environ['AWS_LAMBDA_GBSECOND_COST'] = self.expectedAWSLambdaGBSecondCost
        os.environ['AWS_LAMBDA_INVOKE_COST'] = self.expectedAWSLambdaInvokeCost
        functionCost = calculatecost.getCostForFunctionDuration(self.awsLambdaPlatformName, self.testBilledDuration, self.testMemorySize)
        self.assertEqual(functionCost, Decimal('0.000000408375'))

    def testCalculateFunctionCostUnknownPlatform(self):
        os.environ['AWS_LAMBDA_GBSECOND_COST'] = self.expectedAWSLambdaGBSecondCost
        os.environ['AWS_LAMBDA_INVOKE_COST'] = self.expectedAWSLambdaInvokeCost
        functionCost = calculatecost.getCostForFunctionDuration(self.unknownPlatformName, self.testBilledDuration, self.testMemorySize)
        self.assertEqual(functionCost, Decimal('0.000000408375'))

    def testCalculateFunctionCostAWSPerMillion(self):
        os.environ['AWS_LAMBDA_GBSECOND_COST'] = self.expectedAWSLambdaGBSecondCost
        os.environ['AWS_LAMBDA_INVOKE_COST'] = self.expectedAWSLambdaInvokeCost
        functionCost = calculatecost.getCostPerMillionForBilledDuration(self.unknownPlatformName, self.testBilledDuration, self.testMemorySize)
        self.assertEqual(functionCost, Decimal('0.408375'))        

if __name__ == '__main__':
    unittest.main()