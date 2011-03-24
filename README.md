# Ideas
## Vital
1. TODO Propagate errors to the server and to logs
2. STARTED use GPG
3. TODO Wrapper scripts for common command lines

## Sciency
5. TODO A non-ruby DSL for writing policies
7. TODO Transient resources (frontier walking?)
8. TODO Multi-resource Imp API ("Install all these packages")
9. TODO Cross-machine coordination
10. TODO Farm out policy-making

## Tedium
0. TODO various other TODOs scattered around the source.
1. TODO json-shape files for data types
2. TODO Don't recreate existing policy files
3. TODO Command line parsing
6. TODO A second System->System filter to happen on the serverside before System->Policy
7. TODO Unique filenames for timestamped files
8. TODO Find more ways to sort files in public/
9. TODO Model changelog entries as Structs

# Instructions
## Client/Server
1. run server.rb on your server # rack app, supplies upload/download access through HTTP
2. cron coordinator.rb on your server # calculates policies for inventory
3. cron announce.rb # uploads system information into inventory
4. cron client.rb   # downloads and applies policy

## Standalone
1. ruby system_facts.rb  | ruby make_policy.rb  | ruby apply.rb
