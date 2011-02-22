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

## Sciency
1. TODO Generate report: original system state, actions performed, new system state.
2. STARTED use GPG
3. TODO Intelligent graph-walking
4. TODO Nicer DSL for defining implementors

## Tedium
1. TODO Don't recreate existing policy files
2. TODO Some sort of configuration file
3. TODO Command line parsing
4. TODO System facts from existing fact whatsits.
5. TODO Nicer json-shape error messages
6. TODO various other TODOs scattered around the source.

# Instructions
## Client/Server
1. run server.rb on your server # rack app, supplies upload/download access through HTTP
2. cron coordinator.rb on your server # calculates policies for inventory
3. cron announce.rb # uploads system information into inventory
4. cron client.rb   # downloads and applies policy

## Standalone
1. ruby system_facts.rb  | ruby make_policy.rb  | ruby apply.rb
