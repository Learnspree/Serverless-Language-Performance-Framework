package com.learnspree;

import java.util.Map;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class EmptyJava11Handler implements RequestHandler<Map<String,Object>, Response>  {

	@Override
	public Response handleRequest(Map<String,Object> input, Context context) {
		return new Response("Empty Java 11 Test Function Completed.");
	}
}
