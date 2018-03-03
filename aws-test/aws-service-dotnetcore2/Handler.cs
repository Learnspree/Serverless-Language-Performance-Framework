using Amazon.Lambda.Core;
using System;

[assembly:LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace ServerlessPerformanceFramework
{
    public class Handler
    {
       public Response EmptyTestDotNetCore2()
       {
           return new Response("Empty Performance Test Response");
       }
    }

    public class Response
    {
       public string Message {get; set;}

       public Response(string message){
         Message = message;
       }
    }
}
