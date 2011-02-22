# Ideas
1. OK Run with cron
2. OK Collect "facts" (System resource)
3. OK (External node classification?)
4. OK Run programs (build a graph)
5. OK Automatically run programs for each inventory checkin
6. OK Send over network
7. OK Walk the graph
8. OK Apply resources
9. OK Provider: do something. a graph of states? Solve constraints?
10. TODO Generate report: original system state, actions performed, new system state.
11. STARTED use GPG
12. TODO Intelligent graph-walking
12. TODO Some sort of configuration file
13. TODO Command line parsing
14. TODO System facts from existing fact whatsits.
15. TODO Nicer json-shape error messages

# Instructions (might not all be working currently)
1. run server.rb on your server # rack app, supplies upload/download access through HTTP
2. cron coordinator.rb on your server # calculates policies for inventory
3. cron announce.rb # uploads system information into inventory
4. cron client.rb   # downloads and applies policy
