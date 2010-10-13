require File.dirname(__FILE__) + '/spec_helper'
require 'roo_b_tree'

describe RooBTree do
  it "should correctly order any added elements" do
    tree = RooBTree.new
    test_values = %w(g b m n h j a c f d k i)
    added_values = []
    test_values.each do |value|
      begin
        tree << value
        added_values << value
        tree.to_s.should == "[#{added_values.sort.join(', ')}]"
      rescue => e
        raise e.message + ' for value ' + value
      end
    end
  end
  
  it "should not add duplicate values" do
    tree = RooBTree.new
    tree.size.should == 0
    tree << 0
    tree.size.should == 1
    tree << 0
    tree.size.should == 1
    tree << 1
    tree.size.should == 2
  end
end
