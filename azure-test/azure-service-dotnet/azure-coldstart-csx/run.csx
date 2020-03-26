using System;

static int ExecutionCounter = 0;
public static void Run(TimerInfo myTimer, TraceWriter log)
{
    ExecutionCounter++;
    log.Info(((ExecutionCounter > 1) ? "Warm" : "Cold") + " Start");
    if (ExecutionCounter > 1) {
        throw new Exception("Warm start detected - ignore results for cold-start test function");
    }
}