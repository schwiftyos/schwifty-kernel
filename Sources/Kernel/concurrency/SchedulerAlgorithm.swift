
enum SchedulerAlgorithm {
    case roundRobin
    case fixedPriorityPreemptive
    case multiLevelFeedbackQueue
    case completelyFair

    case earliestDeadlineFirst
    case rateMonotonic
}