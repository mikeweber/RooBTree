require File.dirname(__FILE__) + '/spec_helper'
require 'node'

describe Node do
  it "should sort by value" do
    nodes = (values = %w(d b c a)).collect do |value|
      Node.new(value)
    end
    
    nodes.sort.collect { |node| node.value }.should == values.sort
  end
  
  it "should sort as if the values are strings" do
    nodes = (values = %w(2 10 1 3)).collect do |value|
      Node.new(value)
    end
    
    nodes.sort.collect { |node| node.value }.should == values.sort
  end
end
