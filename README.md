# Ideas
## Vital
1. TODO More data in report. (Commands executed, time elapsed)
2. STARTED use GPG
3. TODO Multiple implementors for the same type
4. Wrapper scripts for common command lines

## Sciency
4. TODO Nicer DSL for defining implementors
5. TODO A DSL for writing policies
7. TODO Transient resources (frontier walking?)
8. TODO Multi-resource Imp API ("Install all these packages")
9. TODO Cross-machine coordination
10. TODO Farm out policy-making

## Tedium
0. TODO various other TODOs scattered around the source.
1. TODO json-shape files for data types
2. TODO Don't recreate existing policy files
3. TODO Command line parsing
4. TODO do_rules is too clever
5. TODO Too much magic in Implementor::Reader.
6. TODO A second System->System filter to happen on the serverside before System->Policy
7. TODO Unique filenames for timestamped files
8. TODO Find more ways to sort files in public/

# Instructions
## Client/Server
1. run server.rb on your server # rack app, supplies upload/download access through HTTP
2. cron coordinator.rb on your server # calculates policies for inventory
3. cron announce.rb # uploads system information into inventory
4. cron client.rb   # downloads and applies policy

## Standalone
1. ruby system_facts.rb  | ruby make_policy.rb  | ruby apply.rb
