
@safe
struct Job {
    var next:UnsafeMutablePointer<Job>?
    var schedulerPriv:UnsafeMutableRawPointer?
}