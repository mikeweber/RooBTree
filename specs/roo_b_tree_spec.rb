require File.dirname(__FILE__) + '/spec_helper'
require 'roo_b_tree'
require 'benchmark'

describe RooBTree do
  it "should correctly order any added elements" do
    tree = RooBTree.new
    test_values = %w(g b s z r m y n l x h w j v a c f p q u d k i o t)
    added_values = []
    test_values.each do |value|
      # begin
        tree << value
        added_values << value
        tree.to_s.should == "[#{added_values.sort.join(', ')}]"
      # rescue => e
      #   raise e.message + ' for value ' + value
      # end
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
  
  it "should be able to find a given value" do
    tree = RooBTree.new(%w(g b s z r m y n l x h w j v a c f p q u d k i o t))
    tree.find('t').should == 't'
    tree.find('a').should == 'a'
    tree.exists?('j').should be_true
    tree.find('echo').should be_nil
    tree.exists?('sierra').should be_false
  end
  
  # The whole point of this project is to be able to look up values faster than a flat array
  it "should be able to lookup values faster than a normal array" do
    test_array = []
    100_000.times do |i|
      test_array << i
    end
    tree = RooBTree.new(test_array)
    search_array = (test_array + %w(these are not in either of the arrays)).sort { rand }
    
    Benchmark.bm do |b|
      test_count = 100_000
      b.report("Array") do
        test_count.times do |i|
          test_array.find(search_array[i % search_array.size])
        end
      end
      
      b.report("RooBTree") do
        test_count.times do |i|
          tree.find(search_array[i % search_array.size])
        end
      end
    end
  end
end
