using System;

static int ExecutionCounter = 0;
public static void Run(TimerInfo myTimer, TraceWriter log)
{
    ExecutionCounter++;
    log.Info(((ExecutionCounter > 1) ? "Warm" : "Cold") + " Start");
}