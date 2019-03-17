module Xanthus
  class Script
    attr_accessor :script


    def initialize array, config
      script = ''
      array.each do |t|
        v = eval(config.scripts[t])
        if v.kind_of?(Array)
          v.each do |w|
            script+=w+"\n"
          end
        else
          script+=v
        end
      end
      script_to_clean = script
      script = ''
      script_to_clean.each_line do |s|
        script += s.strip + "\n" unless s=="\n"
      end
      script = script.gsub "\n\n", "\n"
      @script = script
    end

    def to_s
      @script
    end
  end
end
