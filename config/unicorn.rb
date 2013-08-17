worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

timeout 15

rewindable_input true
