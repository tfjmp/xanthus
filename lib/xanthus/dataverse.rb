require 'fileutils'

module Xanthus
  class Dataverse
    attr_accessor :server
    attr_accessor :repo
    attr_accessor :token
    attr_accessor :dataset_name
    attr_accessor :author
    attr_accessor :affiliation
    attr_accessor :email
    attr_accessor :description
    attr_accessor :subject

    def initialize
      @server = 'default_server'
      @repo = 'default_repo'
      @token = 'default_token'
      @dataset_name = 'default_name'
      @author = 'default_author'
      @affiliation = 'default_affiliation'
      @email = 'default_email'
      @description = 'default_description'
      @subject = 'default_subject'
    end

    def dataset_json
json = %Q{
  {
    "datasetVersion": {
      "metadataBlocks": {
        "citation": {
          "fields": [
            {
              "value": "#{@dataset_name}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}",
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

    def generate_dataset
      Dir.chdir 'dataverse_dataset' do
        File.open('dataset.json', 'w+') do |f|
          f.write(self.dataset_json)
        end
        system('curl', '-H', "X-Dataverse-key:#{@token}", '-X', 'POST', "#{@server}/api/dataverses/#{@repo}/datasets", '--upload-file', 'dataset.json')
      end
    end

    def init config
      # initialize with config information
      @author = config.authors
      @affiliation = config.affiliation
      @email = config.email
      @description = config.description
      @dataset_name = config.name

      FileUtils.mkdir_p 'dataverse_dataset'
      self.generate_dataset
    end

  end
end
