$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'open3'
require 'tempfile'  


module Abc
  VERSION = '0.0.1'
  class DependencyException < StandardError; end
  class InvalidInputException < StandardError; end
  
  class << self
    
    def abcm2ps_path
      determine_dependencies
      @abcm2ps_path
    end
    
    def gs_path
      determine_dependencies
      @gs_path
    end
    
    def to_png(identifier, notation)
      output = convert(notation)
      match = output.match(/Output written on (.*) \(/)
      raise InvalidInputException.new("Supplied input is not valid abc notation") unless match
      
      output = ps_to_png identifier, File.expand_path(match[1])
      match = output.match(/fail (.*)\(/)
      raise InvalidInputException.new("PNG creation not confirmed" + output) if match
      
      return output
    end
    
    def convert(notation)
      determine_dependencies
      output = ""
      Open3.popen3("#{@abcm2ps_path} -") do |stdin, stdout, stderr|
        stdin.puts(notation)
        stdin.close
        # abcm2ps uses stderr for all output
        output << stderr.read
      end
      return output
    end
    
    def ps_to_png(identifier, inputfilename)
      #GHOSTSCRIPT MANUAL PDF ==> http://noodle.med.yale.edu/latex/gs/gs5man_e.pdf
      #GHOSTSCRIPT CONVERT TO PNG COMMAND ==> gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dGraphicsAlphaBits=4 -sOutputFile=#{outputname} #{inputname}
      output = ""
      inputname = inputfilename
      outputname = "temp.png"
      Open3.popen3("gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -dGraphicsAlphaBits=4 -sOutputFile=#{outputname} #{inputname}") do |stdin, stdout, stderr|
        stdin.close
        output << stderr.read << "\n " + stdout.read
      end
      
      x = Tempfile.new(identifier + ".png")
      File.open(outputname) do |input_file|
        x.write input_file.readlines
      end

      x.rewind
      x.close
      return x.path #This is the temporary file's location on the system. #TODO: does this need to be destroy/released by system? where?
    end
    
    private
    
    def determine_dependencies
      return if @abcm2ps_path && @gs_path
      abcm2ps_path = `which abcm2ps`.strip
      gs_path = `which gs`.strip
      
      raise DependencyException.new("Dependency abcm2ps not found") if abcm2ps_path == ""
      raise DependencyException.new("Dependency gs not found") if gs_path == ""
      @abcm2ps_path = abcm2ps_path
      @gs_path = gs_path
      
    end
    
  end
  
end