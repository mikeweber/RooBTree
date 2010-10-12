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
    tree = RooBTree.new
    leaf = tree.root
    max_value = nil
    Leaf::MAX_SIZE.times do |i|
      max_value = i
      leaf << Node.new(i)
    end
    
    median_node = Node.new(max_value + 1)
    leaf.should_receive(:split!).and_return(median_node)
    leaf << Node.new(median_node)
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
        
        new_node = Node.new(init_values.max + 1)
        nodes = leaf.to_a + [new_node]
        median_node = leaf.send(:split!, new_node)
        median_node.value.should == nodes[nodes.size / 2].value
        median_node.right_leaf.should_not be_nil
        median_node.left_leaf.should_not be_nil
        median_node.left_leaf.values.should == nodes[0..(nodes.size / 2 - 1)].collect { |node| node.value.to_s }
        median_node.right_leaf.values.should == nodes[(nodes.size / 2 + 1)..-1].collect { |node| node.value.to_s }
      end
    end
    
    context "and the leaf is root" do
      it "should put the median node in a new leaf and make it the root" do
        init_values = []
        Leaf::MAX_SIZE.times do |i|
          init_values << i
        end
        tree = RooBTree.new(init_values)
        leaf = tree.root
        leaf.parent_leaf.should be_nil
        leaf.tree.should == tree
        leaf.should be_all { |node| (node.left_leaf.nil? || node.left_leaf.empty?) && (node.right_leaf.nil? || node.right_leaf.empty?) }
        tree.root.should == leaf
        
        new_node = Node.new(init_values.max + 1)
        leaf_values = (leaf.values + [new_node.value.to_s]).sort
        leaf << new_node
        tree.root.should_not == leaf
        root = tree.root
        root.size.should == 1
        root.first.left_leaf.should_not be_nil
        root.first.left_leaf.values.should == leaf_values[0..(Leaf::MAX_SIZE / 2 - 1)]
        root.first.right_leaf.should_not be_nil
        root.first.right_leaf.values.should == leaf_values[(Leaf::MAX_SIZE / 2 + 1)..-1]
      end
    end
  end
end
