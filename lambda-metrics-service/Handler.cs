using Amazon.Lambda.Core;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using System;
using System.Collections.Generic;

[assembly:LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace ServerlessPerformanceFramework
{
    public class Handler
    {
       public AddMetricsResponse LambdaMetrics(AddMetricsRequest request)
       {
           // default to successful response until we plug in DynamoDB integration
           return new AddMetricsResponse("Lambda Metrics data persisted in DynamoDB successfully.", request, 0);
       }

       private void CreateItem(AddMetricsRequest metrics)
       {
            // TODO - remove hardocded values and take from metrics object

            AmazonDynamoDBClient client = new AmazonDynamoDBClient();

            var request = new PutItemRequest
            {
                TableName = "ServerlessFunctionMetrics",
                Item = new Dictionary<string, AttributeValue>()
            {
                { "FunctionName", new AttributeValue {
                      S = "my-service"
                  }},
                { "Timestamp", new AttributeValue {
                      S = "0000000000"
                  }},
                { "FunctionVersion", new AttributeValue {
                      S = "$LATEST"
                  }},
                { "Duration", new AttributeValue {
                      N = "20.00"
                  }},
                { "BilledDuration", new AttributeValue {
                      N = "30.00"
                  }},
                { "MemorySize", new AttributeValue {
                      N = "30.00"
                  }},
                { "MemoryUsed", new AttributeValue {
                      N = "30.00"
                  }},
                { "LanguageRuntime", new AttributeValue {
                      S = "Java"
                  }},
                { "ServerlessPlatformName", new AttributeValue {
                      S = "AWS"
                  }}
            }
            };
            client.PutItem(request);
        }
    }

    public class AddMetricsResponse
    {
      public string Message {get; set;}
      public AddMetricsRequest Request {get; set;}
      public int Status {get; set;}

      public AddMetricsResponse(string message, AddMetricsRequest request, int status){
        Message = message;
        Request = request;
        Status = status;
      }
    }

    public class AddMetricsRequest
    {
      public string FunctionName {get; set;}
      public string FunctionVersion {get; set;}
      public string Timestamp {get; set;}
      public int Duration {get; set;}
      public int BilledDuration {get; set;}
      public int MemorySize {get; set;}
      public int MemoryUsed {get; set;}
      public string LanguageRuntime {get; set;}
      public string ServerlessPlatformName {get; set;}

      public AddMetricsRequest(string functionName, 
        string functionVersion, 
        string timestamp,
        int duration,
        int billedDuration,
        int memorySize,
        int memoryUsed,
        string runtime,
        string platform) {
          FunctionName = functionName;
          FunctionVersion = functionVersion;
          Timestamp = timestamp;
          Duration = duration;
          BilledDuration = billedDuration;
          MemorySize = memorySize;
          MemoryUsed = memoryUsed;
          LanguageRuntime = runtime;
          ServerlessPlatformName = platform;
      }
    }
}
