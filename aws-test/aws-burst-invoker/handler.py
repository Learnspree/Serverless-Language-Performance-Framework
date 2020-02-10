from boto3 import client as boto3_client
from datetime import datetime
from threading import Thread
import json

threads = []
lambda_client = boto3_client('lambda')

class myThread(Thread):

    def __init__(self, functionName):
        Thread.__init__(self)
        self.functionName = functionName
    
    def run(self):
        invoke_response = lambda_client.invoke(FunctionName=self.functionName,
                                                InvocationType='Event')

def burst_invoker(event, context):
    try:
        print('Event Count: ', event['invokeCount'])
        for y in event['targetFunctionName']:
            print(f"Event Target: {y}")

        # putting in a hardcoded limit for safety to ensure we don't go wild calling lambdas
        if event['invokeCount'] > 10:
            return

        try:
            for functionToInvoke in event['targetFunctionName']:
                local_threads = []
                for x in range(event['invokeCount']):
                    #print('Target Function: ', functionToInvoke)
                    t = myThread(functionToInvoke)
                    local_threads.append(t)
                    threads.append(t)

                # start all threads
                for thread in local_threads:
                    thread.start()

                # make sure that all threads have finished
                for thread in threads:
                    thread.join()
        except Exception as e:
            print("Threading error: %s" % e)  

        print('done')        
    except Exception as e:
        print("Generic error: %s" % e)  