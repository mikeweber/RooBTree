require File.dirname(__FILE__) + '/spec_helper'
require 'roo_b_tree'

describe Leaf do
  it "should be able to add a Node when it has room" do
    leaf = Leaf.new
    node = Node.new(5)
    
    leaf.size.should < Leaf::MAX_SIZE
    expect {
      leaf << node
    }.to change(leaf, :size).by(1)
  end
  
  it "should split the node when it's full and adding a node" do
    leaf = Leaf.new
    max_value = nil
    Leaf::MAX_SIZE.times do |i|
      max_value = i
      leaf << Node.new(i)
    end
    
    leaf.should_receive(:split!)
    leaf << Node.new(max_value + 1)
  end
  
  context "when a leaf is full and adding a new node" do
    context "and the leaf has a parent" do
      it "should add the median node to the parent node" do
        init_values = []
        Leaf::MAX_SIZE.times do |i|
          init_values << i
        end
        parent = Leaf.new([Node.new(init_values.min - 1)])
        leaf = Leaf.new(init_values.collect { |v| Node.new(v) })
        leaf.parent_leaf = parent
        leaf.parent_leaf.should_not be_nil
        leaf.should be_all { |node| (node.left_leaf.nil? || node.left_leaf.empty?) && (node.right_leaf.nil? || node.right_leaf.empty?) }
        leaf.parent_leaf.should_receive(:<<).with(leaf[Leaf::MAX_SIZE / 2])
        
        expect {
          leaf.send(:split!, new_node = Node.new(init_values.max + 1))
        }.to change(leaf.parent_leaf, :size).by(1)
        
        leaf.parent_leaf.first.left_leaf.should_not be_nil
        leaf.parent_leaf.first.left_leaf.first.value.should == init_values.first
        leaf.parent_leaf.first.right_leaf.should_not be_nil
        leaf.parent_leaf.first.right_leaf.first.value.should == (init_values + [new_node.value])[(Leaf::MAX_SIZE / 2) + 1]
      end
    end
    context "and the leaf is root" do
      it "should put the median node in a new leaf and make it the root"
    end
  end
end
