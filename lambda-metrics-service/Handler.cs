using Amazon.Lambda.Core;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

[assembly:LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace ServerlessPerformanceFramework
{
    public class Handler
    {
       public async Task<AddMetricsResponse> LambdaMetrics(AddMetricsRequest request)
       {
           // default to successful response until we plug in DynamoDB integration
           Console.WriteLine("Start Lambda Metrics");
           Task<int> createItemTask = CreateItem(request);
           int result = await createItemTask;
           Console.WriteLine("End Lambda Metrics");
           return new AddMetricsResponse("Lambda Metrics data persisted in DynamoDB " + (result == 0 ? "successfully" : "failure"), request, result);
       }

       private async Task<int> CreateItem(AddMetricsRequest metrics)
       {
            // TODO - remove hardocded values and take from metrics object
            Console.WriteLine("Start CreateItem");
            AmazonDynamoDBClient client = new AmazonDynamoDBClient();

/*
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
            };*/
            var items = new Dictionary<string, AttributeValue>()
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
            };

            Console.WriteLine("Calling PutItemAsync");
            Task<PutItemResponse> putTask = client.PutItemAsync("ServerlessFunctionMetrics", items);
            Console.WriteLine("Calling await PutItem");
            var response = await putTask;
            Console.WriteLine("End CreateItem");
            return (int)response.HttpStatusCode;
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
