from boto3 import client as boto3_client
from datetime import datetime
from threading import Thread
import json

threads = []

class myThread(Thread):

    def __init__(self, functionName):
        Thread.__init__(self)
        print('Init thread for', functionName)
        self.functionName = functionName
        print('Self function name:', functionName)
    
    def run(self):
        print('Invoking ', self.functionName)
        lambda_client = boto3_client('lambda')
        invoke_response = lambda_client.invoke(FunctionName=self.functionName,
                                                InvocationType='Event')
        print('Invoke Response: ', invoke_response)        

def burst_invoker(event, context):
    try:
        print('Event Count: ', event['invokeCount'])
        print('Event Target: ', event['targetFunctionName'])

        # putting in a hard limit for safety
        if event['invokeCount'] > 10:
            return

        try:
            for x in range(event['invokeCount']):
                t = myThread(event['targetFunctionName'])
                print('appending thread')
                threads.append(t)

            # start all threads
            for thread in threads:
                print('starting thread')
                print('starting thread', thread.functionName)
                thread.start()

            # make sure that all threads have finished
            for thread in threads:
                thread.join()
        except Exception as e:
            print("Generic error: %s" % e)  

        print('done')        
    except Exception as e:
        print("Generic error: %s" % e)  