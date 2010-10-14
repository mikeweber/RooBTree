require 'leaf'
require 'node'

class RooBTree
  attr_accessor :root
  
  def initialize(initial_values = [])
    @root = Leaf.new([], self)
    initial_values.each do |value|
      self << value
    end
  end
  
  def <<(value)
    return nil if value.nil?
    return nil unless leaf = find_insertion_leaf(value.to_s)
    
    new_node = Node.new(value)
    leaf << new_node
  
    return new_node
  end
  
  def size
    self.root.full_array.size
  end
  
  def exists?(value)
    !self.find(value).nil?
  end
  
  def find(value)
    @root.find(value.to_s)
  end
  
  def to_s
    "[#{@root.full_array.join(', ')}]"
  end
  
  private
  
  # recursively determine which leaf to add this value to. returning false means the method lead to a dead end 
  # i.e. a child leaf was passed in that didn't actually exist. returning nil means the value was found and 
  # shouldn't be added to the Tree.
  def find_insertion_leaf(value, leaf = @root)
    return false if leaf.nil?
    return leaf if leaf.empty?
    
    # walk through the nodes until you find a stored value larger than the value that's
    # being added. Then add it to that leaf's left leaf. If the value is larger than all
    # of the values in this leaf, test the right leaf of the last node.
    node_index = 0
    node_value = leaf[node_index].value
    while (node_value && value > node_value && node_index < leaf.size)
      if node = leaf[node_index += 1]
        node_value = node.value
      end
    end
    
    insertion_leaf = if node_value == value # don't allow duplicate values to be added
      nil
    elsif node_index < leaf.size
      find_insertion_leaf(value, leaf[node_index].left_leaf)
    else
      find_insertion_leaf(value, leaf.last.right_leaf)
    end
    
    # if the recursive function returns false, it means that a child leaf that was recursed on didn't
    # actually exist, so use the leaf that was passed in originally
    # Return nil if insertion_leaf is nil. Otherwise insertion_leaf can either be a Leaf, or false.
    return insertion_leaf.nil? ? nil : (insertion_leaf || leaf)
  end
end

class ClassMismatch < Exception; end
class NoRoomAtTheInn < Exception; end
