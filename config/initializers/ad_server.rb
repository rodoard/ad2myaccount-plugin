require 'recursive_open_struct'
Rails.application.config.ad_server = RecursiveOpenStruct.new (
  YAML.load(File.read(File.join(Rails.root, 'config', 'ad_server.yml')))
                                                             )