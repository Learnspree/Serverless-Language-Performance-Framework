using System;

static int ExecutionCounter = 0;
public static void Run(TimerInfo myTimer, TraceWriter log)
{
    ExecutionCounter++;
    log.Info(((ExecutionCounter > 1) ? "Warm" : "Cold") + " Start");
    if (ExecutionCounter <= 1) {
        throw new Exception("Cold start detected - ignore results for warm-start test function");
    }
}