using System;
using System.Net;
using Amazon.Lambda.Core;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using Amazon.Runtime;
using Amazon.Lambda.APIGatewayEvents;
using System.Collections.Generic;
using System.Threading.Tasks;
using Newtonsoft.Json; 
using Newtonsoft.Json.Serialization;

[assembly:LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace ServerlessPerformanceFramework
{
    public class Handler
    {
       //public async Task<AddMetricsResponse> LambdaMetrics(AddMetricsRequest request)
       public async Task<APIGatewayProxyResponse> LambdaMetrics(APIGatewayProxyRequest request, ILambdaContext context)
       {
            // Log entries show up in CloudWatch
            context.Logger.LogLine("Example log entry\n");

            JsonSerializerSettings serSettings = new JsonSerializerSettings();
            serSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
            AddMetricsRequest metricsRequest = JsonConvert.DeserializeObject<AddMetricsRequest>(request.Body, serSettings);

            context.Logger.LogLine("metricsRequestObjectCreated");

           Task<int> createItemTask = CreateItem(metricsRequest);
           int result = await createItemTask;
           //return new AddMetricsResponse("Lambda metrics data persisted with result: " + result, request, result);

            // TODO - change Body to just return the response code
            var response = new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body =  JsonConvert.SerializeObject(metricsRequest),
                Headers = new Dictionary<string, string> {{ "Content-Type", "application/json" }}
            };

            return response;

           /*
           Task<int> createItemTask = CreateItem(request);
           int result = await createItemTask;
           return new AddMetricsResponse("Lambda metrics data persisted with result: " + result, request, result);
           */
       }

       private async Task<int> CreateItem(AddMetricsRequest metrics)
       {
            try 
            {
                var putItemData = CreatePutItemData(metrics);
                AmazonDynamoDBClient client = new AmazonDynamoDBClient();
                Task<PutItemResponse> putTask = client.PutItemAsync("ServerlessFunctionMetrics", putItemData);
                var response = await putTask;
                return (int)response.HttpStatusCode;
            }
            catch (AmazonDynamoDBException e) { Console.WriteLine(e.Message); }
            catch (AmazonServiceException e) { Console.WriteLine(e.Message); }
            catch (Exception e) { Console.WriteLine(e.Message); }

            return 0;
        }
    
        private Dictionary<string, AttributeValue> CreatePutItemData(AddMetricsRequest metrics) 
        {
            var items = new Dictionary<string, AttributeValue>()
            {
                { "FunctionName", new AttributeValue {
                      S = metrics.FunctionName
                  }},
                { "Timestamp", new AttributeValue {
                      S = metrics.Timestamp
                  }},
                { "FunctionVersion", new AttributeValue {
                      S = metrics.FunctionVersion
                  }},
                { "Duration", new AttributeValue {
                      N = metrics.Duration
                  }},
                { "BilledDuration", new AttributeValue {
                      N = metrics.BilledDuration
                  }},
                { "MemorySize", new AttributeValue {
                      N = metrics.MemorySize
                  }},
                { "MemoryUsed", new AttributeValue {
                      N = metrics.MemoryUsed
                  }},
                { "LanguageRuntime", new AttributeValue {
                      S = metrics.LanguageRuntime
                  }},
                { "ServerlessPlatformName", new AttributeValue {
                      S = metrics.ServerlessPlatformName
                  }}
            };

            return items;
        }
    }
/*
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
    }*/

    public class AddMetricsRequest
    {
      public string FunctionName {get; set;}
      public string FunctionVersion {get; set;}
      public string Timestamp {get; set;}
      public string Duration {get; set;}
      public string BilledDuration {get; set;}
      public string MemorySize {get; set;}
      public string MemoryUsed {get; set;}
      public string LanguageRuntime {get; set;}
      public string ServerlessPlatformName {get; set;}

      public AddMetricsRequest(string functionName, 
        string functionVersion, 
        string timestamp,
        string duration,
        string billedDuration,
        string memorySize,
        string memoryUsed,
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
