# Summary
Poppet is to Puppet as Sinatra is to Rails. Poppet is a Configuration Management Microframework.

In Poppet, most things are small scripts that accept well-formed JSON on STDIN and output JSON on STDOUT, because Unix + Structure = Awesome.

# Instructions
## Client/Server
1. run server.rb on your server # rack app, supplies upload/download access through HTTP
2. cron coordinator.rb on your server # calculates policies for inventory
3. cron announce.rb # uploads system information into inventory
4. cron client.rb   # downloads and applies policy

## Standalone
1. ruby system_facts.rb  | ruby make_policy.rb  | ruby apply.rb

# Development
Please submit Pull Requests via Github, because that UI is pretty good actually.

# Ideas/Goals
## Vital
1. TODO Propagate errors to the server and to logs
2. STARTED use GPG
3. TODO Wrapper scripts for common command lines

## Sciency
1. Figure out how to test all this stuff.
2. Simplify object constuction by keeping metadata separate from objects
3. Model imperative sections of policy
4. Use other projects' implementations of complex system calls
5. TODO A non-ruby DSL for writing policies
7. TODO Transient resources
11. TODO Optional resources
8. TODO Multi-resource Imp API ("Install all these packages")
9. TODO Cross-machine coordination
10. TODO Farm out policy-making

## Tedium
0. TODO various other TODOs scattered around the source.
1. TODO json-shape files for data types
2. TODO Don't recreate existing policy files
3. TODO Command line parsing (probably Trollop)
6. TODO A second System->System filter to happen on the serverside before System->Policy
7. TODO Unique filenames for timestamped files
8. TODO Find more ways to sort files in public/
9. TODO Model changelog entries as Structs
10. TODO detect cycles in graphs
11. TODO detect references to non-existent resources
12. TODO nudged_by should work
