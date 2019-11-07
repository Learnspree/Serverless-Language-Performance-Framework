package com.learnspree;

import java.util.Map;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class EmptyJava8Handler implements RequestHandler<Map<String,Object>, Response>  {

	private static int INVOKE_COUNT = 0;

	@Override
	public Response handleRequest(Map<String,Object> input, Context context) {
		System.out.println(String.format("RequestId: %s State: %s", context.getAwsRequestId(), ((INVOKE_COUNT++ > 0) ? "Warm" : "Cold")));
		return new Response("Empty Java 8 Test Function Completed.");
	}
}
