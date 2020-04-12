module Xanthus
  class Repository

    def initialize
    end

    def prepare_xanthus_file
      script = ''
      File.readlines('../../.xanthus').each do |line|
        script += line unless line.include?('github.token') || line.include?('dataverse.token')

        # remove github token
        script += "\t\t# github.token = 'REMOVED'\n" unless !line.include? 'github.token'
        # remove dataverse token
        script += "\t\t# dataverse.token = 'REMOVED'\n" unless !line.include? 'dataverse.token'
      end
      File.open('.xanthus', 'w+') do |f|
        f.write(script)
      end
    end

    def prepare_readme_file config
      File.open('README.md', 'w+') do |f|
        f.write(config.to_readme_md)
      end
    end
  end
end
