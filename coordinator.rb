require 'lib/storage'
require 'lib/execute'

settings = {
  "inventory" => 'public/inventory',
  "policy" => 'public/policy',
}

Dir.glob(File.join(settings["inventory"], "*")) do |inventory_filename|
  basename = File.basename(inventory_filename)
  policy_filename = File.join(settings["policy"], basename)
  if ! File.exist?(policy_filename)
    output = Poppet::Execute.execute( "ruby make_policy.rb #{ inventory_filename.inspect }" )
    Poppet::Storage.file(policy_filename) do |f|
      f.print(output)
    end
  end
end
