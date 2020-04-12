require 'fileutils'
require 'json'

module Xanthus
  class Dataverse < Repository
    attr_accessor :server
    attr_accessor :repo
    attr_accessor :token
    attr_accessor :dataset_name
    attr_accessor :author
    attr_accessor :affiliation
    attr_accessor :email
    attr_accessor :description
    attr_accessor :subject
    attr_accessor :doi

    def initialize
      super
      @server = 'default_server'
      @repo = 'default_repo'
      @token = 'default_token'
      @dataset_name = 'default_name'
      @author = 'default_author'
      @affiliation = 'default_affiliation'
      @email = 'default_email'
      @description = 'default_description'
      @subject = 'default_subject'
      @doi = 'not_set'
    end

    def dataset_json
json = %Q{
  {
    "datasetVersion": {
      "metadataBlocks": {
        "citation": {
          "fields": [
            {
              "value": "#{@dataset_name}",
              "typeClass": "primitive",
              "multiple": false,
              "typeName": "title"
            },
            {
              "value": [
                {
                  "authorName": {
                    "value": "#{@author}",
                    "typeClass": "primitive",
                    "multiple": false,
                    "typeName": "authorName"
                  },
                  "authorAffiliation": {
                    "value": "#{@affiliation}",
                    "typeClass": "primitive",
                    "multiple": false,
                    "typeName": "authorAffiliation"
                  }
                }
              ],
              "typeClass": "compound",
              "multiple": true,
              "typeName": "author"
            },
            {
              "value": [
                  { "datasetContactEmail" : {
                      "typeClass": "primitive",
                      "multiple": false,
                      "typeName": "datasetContactEmail",
                      "value" : "#{@email}"
                  },
                  "datasetContactName" : {
                      "typeClass": "primitive",
                      "multiple": false,
                      "typeName": "datasetContactName",
                      "value": "#{@author}"
                  }
              }],
              "typeClass": "compound",
              "multiple": true,
              "typeName": "datasetContact"
            },
            {
              "value": [ {
                 "dsDescriptionValue":{
                  "value": "#{@description.gsub(/\r/," ").gsub(/\n/," ")}",
                  "multiple":false,
                 "typeClass": "primitive",
                 "typeName": "dsDescriptionValue"
              }}],
              "typeClass": "compound",
              "multiple": true,
              "typeName": "dsDescription"
            },
            {
              "value": [
                "#{@subject}"
              ],
              "typeClass": "controlledVocabulary",
              "multiple": true,
              "typeName": "subject"
            }
          ],
          "displayName": "Citation Metadata"
        }
      }
    }
  }
}
      return json
    end

    def create_dataset
      Dir.chdir 'dataverse_dataset' do
        File.open('dataset.json', 'w+') do |f|
          f.write(self.dataset_json)
        end
        puts "Creating dataverse #{@dataset_name} in #{@repo} at #{@server}..."
        output = `curl -H X-Dataverse-key:#{@token} -X POST #{@server}/api/dataverses/#{@repo}/datasets --upload-file dataset.json`
        puts output # needed to escape curl output
        parsed = JSON.parse(output)
        @doi = parsed['data']['persistentId']
        puts "Dataverse #{@doi} created."
      end
    end

    def init config
      # initialize with config information
      @author = config.authors
      @affiliation = config.affiliation
      @email = config.email
      @description = config.description
      @dataset_name = config.name+'-'+Time.now.strftime("%Y-%m-%d_%H-%M")

      FileUtils.mkdir_p 'dataverse_dataset'
      self.create_dataset
      Dir.chdir 'dataverse_dataset' do
        FileUtils.mkdir_p 'repo'
        Dir.chdir 'repo' do
          self.xanthus_file
          self.readme_file config
          self.inputs_file config
        end
      end
    end

    def add_file_to_dataverse name, description, folder
      output = `curl -H X-Dataverse-key:#{@token} -X POST -F "file=@#{name}" -F 'jsonData={"description":"#{description}","directoryLabel":"#{folder}","categories":["Data"], "restrict":"false"}' "#{@server}/api/datasets/:persistentId/add?persistentId=#{@doi}"`
      puts output
    end

    def xanthus_file
      self.prepare_xanthus_file
      self.add_file_to_dataverse '.xanthus', 'xanthus file used to generate the data.', 'metadata'
    end

    def readme_file config
      self.prepare_readme_file config
      self.add_file_to_dataverse 'README.md', 'readme describing the dataset.', 'metadata'
    end

    def inputs_file config
      config.jobs.each do |name,job|
        job.inputs.each do |k, files|
          files.each do |file|
            system('cp', '-f', "../../#{file}", "#{file}")
            self.add_file_to_dataverse file, 'Job input file.', 'metadata'
          end
        end
      end
    end

  end
end
