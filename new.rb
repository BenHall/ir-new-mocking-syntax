require 'rubygems'
require 'C:\Program Files\Reference Assemblies\Microsoft\Framework\v3.5\System.Web.Abstractions.dll'
require 'caricature'
include Caricature
class Stubber
  def self.http_request()
    isolation = isolate(System::Web::HttpRequestBase)
    isolation.when_receiving(:application_path).return("~/test")
    isolation
  end
end

def get_slice_start(return_string)
   marker = '("'
   pos = return_string.index marker
   pos + marker.length
end

def get_slice_end(return_string, start)
   marker = '")'
   pos = return_string.index marker
   pos - start 
end

def get_return_value(return_string)
  slice_start = get_slice_start return_string
  slice_end = get_slice_end return_string, slice_start
  return_string.slice slice_start, slice_end
end

def get_objectname(class_as_string)
   class_as_string.split('.')[0]
end

def get_method(class_as_string)
  class_as_string.split('.')[1]
end

def create_isolation(class_as_string)
  obj_namespace = get_objectname(class_as_string)
  
  isolate eval(obj_namespace)
end

def set_method_isolation(isolation, method_call)
  method_to_call = get_method method_call
  value_to_return = get_return_value method_call

  isolation.when_receiving(method_to_call.intern).return(eval(value_to_return))
end

def stub(definition)
  isolation = create_isolation definition
  
  definition.split('&&').each do |d|
    set_method_isolation isolation, d
  end
  isolation
end



puts Stubber.http_request.application_path

class Abc
   def pri
    puts 'priiiii'
   end
end


x = stub 'System::Web::HttpRequestBase.application_path.return("Abc.new")'
puts x
puts x.application_path
x.application_path.pri


x = stub 'System::Web::HttpRequestBase.application_path.return("123")'
puts x.application_path

stubbed = stub 'System::Web::HttpRequestBase
            .application_path.return("123") &&
            .file_path.return("456")'
puts stubbed
puts stubbed.application_path
puts stubbed.file_path



 
require 'rubygems'
require 'parse_tree'
require 'parse_tree_extensions'
require 'ruby2ruby'
 
def mock(&block)
  puts block.to_ruby
  block.to_ruby.gsub(/[{}]/, '').gsub(/proc/, '').strip
end

