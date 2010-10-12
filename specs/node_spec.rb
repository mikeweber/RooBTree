require File.dirname(__FILE__) + '/spec_helper'
require 'roo_b_tree'

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
  
  it "should know what leaf it's in" do
    leaf = Leaf.new
    node = Node.new(1)
    node.owner_leaf.should be_nil
    leaf << node
    node.owner_leaf.should == leaf
  end
  
  it "should know what leaf it's in when it's initialized in a Leaf" do
    leaf = Leaf.new([node = Node.new(1)])
    leaf.should_not be_empty
    leaf.first.should == node
    node.owner_leaf.should == leaf
  end
  
  it "should know its position within the leaf it belongs in" do
    leaf = Leaf.new
    leaf.should be_empty
    node = Node.new(2)
    leaf << node
    leaf.full?.should be_false
    node.my_index.should == 0
    leaf << Node.new(1)
    node.my_index.should == 1
  end
  
  it "should know when it's the last node in the leaf" do
    leaf = Leaf.new
    Leaf::MAX_SIZE.times do |i|
      leaf << Node.new(i)
      leaf.last.should be_last_node
      if i == 0
        leaf.first.should be_last_node
      else
        leaf.first.should_not be_last_node
      end
    end
  end
  
  it "should know the child leaf to its left" do
    node = Node.new(1)
    leaf = Leaf.new([Node.new(0)])
    
    node.left_leaf.should be_nil
    node.left_leaf = leaf
    node.left_leaf.should_not be_nil
    node.left_leaf.should_not be_empty
    node.left_leaf.first.value.should == 0
  end
  
  it "should know the child leaf to its right" do
    node = Node.new(1)
    leaf = Leaf.new([Node.new(2)])
    
    node.right_leaf.should be_nil
    node.right_leaf = leaf
    node.right_leaf.should_not be_nil
    node.right_leaf.should_not be_empty
    node.right_leaf.first.value.should == 2
  end
  
  it "should let any assigned children leaves know which leaf the child leaf belongs to" do
    parent = Leaf.new([Node.new(1)])
    child_leaf = Leaf.new([Node.new(0)])
    parent.parent_leaf.should be_nil
    child_leaf.parent_leaf.should be_nil
    parent.first.left_leaf = child_leaf
    
    child_leaf.parent_leaf.should == parent
    parent.parent_leaf.should be_nil
  end
  
  it "should update the child leaves' parent leaf whenever it moves to a new leaf" do
    node = Node.new(1)
    parent = Leaf.new([node])
    other_parent = Leaf.new([Node.new(2)])
    child_leaf = Leaf.new([Node.new(0)])
    parent.parent_leaf.should be_nil
    child_leaf.parent_leaf.should be_nil
    node.left_leaf = child_leaf
    
    child_leaf.parent_leaf.should == parent
    parent.parent_leaf.should be_nil
    
    # Now move the node to a new leaf
    other_parent << node
    node.owner_leaf.should == other_parent
    # The left_leaf should be the same child
    node.left_leaf.should == child_leaf
    node.left_leaf.parent_leaf.should == other_parent
  end
end
