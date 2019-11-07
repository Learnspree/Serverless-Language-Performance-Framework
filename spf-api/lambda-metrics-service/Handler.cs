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
       public async Task<APIGatewayProxyResponse> LambdaMetrics(APIGatewayProxyRequest request, ILambdaContext context)
       {
            // Uncomment for debugging: Console.WriteLine(request.Body);
            JsonSerializerSettings serSettings = new JsonSerializerSettings();
            serSettings.ContractResolver = new DefaultContractResolver();
            AddMetricsRequest metricsRequest = JsonConvert.DeserializeObject<AddMetricsRequest>(request.Body, serSettings);
            SetLanguageRuntime(metricsRequest);

            Task<int> createItemTask = CreateItem(metricsRequest);
            int result = await createItemTask;

            var response = new APIGatewayProxyResponse
            {
                StatusCode = (result == 0) ? (int)HttpStatusCode.OK : (int)HttpStatusCode.InternalServerError,
                Body =  $"{{Success: {result} }}",
                Headers = new Dictionary<string, string> {{ "Content-Type", "application/json" }}
            };

            return response;
       }

       private void SetLanguageRuntime(AddMetricsRequest metrics)
       {
            // Detect language runtime from naming convention (ending in "<languageruntimename>") if missing
            if (metrics.LanguageRuntime == null)
            {
                metrics.LanguageRuntime = "unknown";
                // verify the languageruntime name was actually provided and is in the accepted list
                // otherwise default to "unknown"
                var runtimesDelimited = System.Environment.GetEnvironmentVariable("ACCEPTED_RUNTIMES");
                var acceptedRuntimes = new List<string>(runtimesDelimited.Split(',')); 
                foreach (String runtime in acceptedRuntimes)
                {
                    if (metrics.FunctionName.EndsWith(runtime))
                    {
                        metrics.LanguageRuntime = runtime;
                        break;
                    }
                }
            }
       }

       private async Task<int> CreateItem(AddMetricsRequest metrics)
       {
            try 
            {
                var putItemData = CreatePutItemData(metrics);
                AmazonDynamoDBClient client = new AmazonDynamoDBClient();
                Task<PutItemResponse> putTask = client.PutItemAsync("ServerlessFunctionMetrics", putItemData);
                var response = await putTask;

                // return 0 for success, otherwise failure of -1
                return response.HttpStatusCode == HttpStatusCode.OK ? 0 : -1;
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
                { "RequestId", new AttributeValue {
                      S = metrics.RequestId
                  }},
                { "FunctionName", new AttributeValue {
                      S = metrics.FunctionName
                  }},
                { "Timestamp", new AttributeValue {
                      N = metrics.Timestamp
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

    public class AddMetricsRequest
    {
      public string RequestId { get; set; }
      public string FunctionName {get; set;}
      public string FunctionVersion {get; set;}
      public string Timestamp {get; set;}
      public string Duration {get; set;}
      public string BilledDuration {get; set;}
      public string MemorySize {get; set;}
      public string MemoryUsed {get; set;}
      public string LanguageRuntime {get; set;}
      public string ServerlessPlatformName {get; set;}

      public AddMetricsRequest(
        string requestId,
        string functionName, 
        string functionVersion, 
        string timestamp,
        string duration,
        string billedDuration,
        string memorySize,
        string memoryUsed,
        string runtime,
        string platform) {
          RequestId = requestId;
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
