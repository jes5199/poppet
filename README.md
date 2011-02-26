# Ideas
## Done
1. OK Run with cron
2. OK Collect "facts" (System resource)
3. OK (External node classification?)
4. OK Run programs (build a graph)
5. OK Automatically run programs for each inventory checkin
6. OK Send over network
7. OK Walk the graph
8. OK Apply resources
9. OK Provider: do something. a graph of states? Solve constraints?
10. OK Command-line save to inventory
11. OK Directory imp
12. OK Nicer json-shape error messages
13. OK System facts from existing fact whatsits.

## Sciency
1. TODO Generate report: original system state, actions performed, new system state.
2. STARTED use GPG
3. TODO Intelligent graph-walking
4. TODO Nicer DSL for defining implementors

## Tedium
0. TODO json-shape files for data types
1. TODO Don't recreate existing policy files
2. TODO Some sort of configuration file
3. TODO Command line parsing
4. TODO various other TODOs scattered around the source.
5. TODO Too much magic in Implementor::Reader
6. TODO A second System->System filter to happen on the serverside before System->Policy
7. TODO Unique filenames for timestamped files
8. TODO Associate logs with their policies

# Instructions
## Client/Server
1. run server.rb on your server # rack app, supplies upload/download access through HTTP
2. cron coordinator.rb on your server # calculates policies for inventory
3. cron announce.rb # uploads system information into inventory
4. cron client.rb   # downloads and applies policy

## Standalone
1. ruby system_facts.rb  | ruby make_policy.rb  | ruby apply.rb
