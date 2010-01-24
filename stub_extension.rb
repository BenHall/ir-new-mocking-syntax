require 'rubygems'
require 'C:\Program Files\Reference Assemblies\Microsoft\Framework\v3.5\System.Web.Abstractions.dll'
require 'caricature'
include Caricature


module Stubber
  def get_slice_start(return_string)
     marker = '"'
     pos = return_string.index marker
     pos + marker.length
  end

  def get_slice_end(return_string, start)
     marker = '"'
     pos = return_string.rindex marker
     pos - start
  end

  def get_return_value(return_string)
    slice_start = get_slice_start return_string
    slice_end = get_slice_end return_string, slice_start
    return_string.slice slice_start, slice_end
  end

  def get_method(class_as_string)
    method = class_as_string.split(' == ')[0]
    without_ending = get_method_name method
    arguments = get_arguments method
    return [without_ending, arguments]
  end

  def get_method_name(method)
    name = method.gsub /\(.*\)/, ''
    name = method if name.nil?
    name
  end

  def get_arguments(method)
    has_arguments =  !(method =~ /\(*\)/).nil?
    arguments = nil
    arguments = /\((.*?)\)/.match(method)[1].intern if(has_arguments)
    arguments = :any if arguments == :*
    return arguments
  end

  def create_isolation(class_as_string)
    isolate class_as_string
  end

  def set_method_isolation(isolation, method_call)
    method_to_call = get_method method_call
    value_to_return = get_return_value method_call

    puts method_to_call[0]
    puts method_to_call[1]
    puts value_to_return
    isolation.when_receiving(method_to_call[0].intern).with(method_to_call[1]).return(eval("value_to_return"))
  end

  def create_stub(cls, definition)
    isolation = create_isolation cls
    definition.split('and').each do |d|
      set_method_isolation isolation, d
    end
    isolation
  end

  def ensure_received(cls, definition)
     method_to_call = get_method definition
     cls.did_receive?(method_to_call[0].intern).with(method_to_call[1])
  end
end

class Object
  include Stubber
  def stub(definition)
    return Stubber::create_stub(self, definition)
  end

  def received?(definition)
    return Stubber::ensure_received(self, definition)
  end
end


s = System::Web::HttpRequestBase.stub 'application_path ==  "test"'

puts s
puts s.application_path
puts s.received?('application_path ==  "test"')



