from decimal import *
import os

def getCostForFunctionDuration(serverlessPlatform, billedDuration, memorySize):
    try:
        cost = 0.0

        gbSecondCost = calculateGBSecondCost(serverlessPlatform)
        invokeCost = calculateInvokeCost(serverlessPlatform)

        billedGigabits = memorySize / 1024
        billedSeconds = billedDuration / 1000
        gigabitSeconds = billedGigabits * billedSeconds
        gigabitSecondsCost = gigabitSeconds * gbSecondCost
        cost = invokeCost + gigabitSecondsCost

    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return cost

def getCostPerMillionForBilledDuration(serverlessPlatform, billedDuration, memorySize):
    try:
        cost = getCostForFunctionDuration(serverlessPlatform, billedDuration, memorySize)
        cost = cost * 1000000

    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return cost

def calculateGBSecondCost(serverlessPlatform):
    try:
        if serverlessPlatform == 'Azure Functions':
            gbSecondCost = Decimal(os.environ['AZURE_FUNCTIONS_GBSECOND_COST'])
        else:
            gbSecondCost = Decimal(os.environ['AWS_LAMBDA_GBSECOND_COST'])
    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return gbSecondCost

def calculateInvokeCost(serverlessPlatform):
    try:
        if serverlessPlatform == 'Azure Functions':
            invokeCost = Decimal(os.environ['AZURE_FUNCTIONS_INVOKE_COST'])
        else:
            invokeCost = Decimal(os.environ['AWS_LAMBDA_INVOKE_COST'])
    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return invokeCost   

# // TODO - call out to the AWS Pricing API ?
# // TODO - create separate lambda to listen on SNS topic for price changes and store pricing value somewhere?
