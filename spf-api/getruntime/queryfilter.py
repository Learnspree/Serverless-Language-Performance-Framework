import decimal
import json
from decimal import *
from boto3.dynamodb.conditions import Key, Attr

def getMemoryFromQueryString(eventQueryParams):
    try:
        if eventQueryParams is None:
            # default to 128
            return Decimal(128) 
        
        return Decimal(eventQueryParams['memory'])
    except KeyError as keyError:
        # if memory missing, default to 128
        return Decimal(128)         
    except Exception as e:
        print("Error getting memory from query string: %s" % e) 
        raise           

def getDynamoFilterExpression(eventQueryParams):
    try:
        if eventQueryParams is None:
            return None 
        
        filterExp = None
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'state', 'State')
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'platform', 'ServerlessPlatformName')
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'memory', 'MemorySize')
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'functionname', 'FunctionName')
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'region', 'Region')
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'zone', 'Zone')

        # datetime filters for start/end date are in UNIX epoch timestamp format as in nodejs Date.now() method
        # e.g. 1518951734319
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'startdate', 'Timestamp')
        filterExp = combineFilterExpressionFromQueryString(filterExp, eventQueryParams, 'enddate', 'Timestamp')
    except Exception as e:
        print("Generic error: %s" % e) 
        raise           

    return filterExp

def combineFilterExpressionFromQueryString(filterExp, queryParams, queryParamKey, dynamoTableColumnName):
    if queryParamKey not in queryParams:
        return filterExp

    # convert numeric fields from string to float for dynamodb query on Number (N)
    queryParamValue = queryParams[queryParamKey]
    if queryParamValue.isnumeric():
        print('queryParamKey: ', queryParamKey)
        print('queryParamValue: ', queryParamValue)
        queryParamValue = Decimal(queryParamValue)

    # default to "equals" comparison
    newFilterExp = Key(dynamoTableColumnName).eq(queryParamValue)

    # use <= or >= if looking at date ranges
    if queryParamKey.find("startdate") > -1:
        newFilterExp = Attr(dynamoTableColumnName).gte(queryParamValue)
    elif queryParamKey.find("enddate") > -1:
        newFilterExp = Attr(dynamoTableColumnName).lte(queryParamValue)
            
    if filterExp is None:
        filterExp = newFilterExp
    else:
        filterExp = filterExp & newFilterExp

    return filterExp