require 'leaf'
require 'node'

class RooBTree
  def initialize(initial_values = [])
    @root = Leaf.new([], self)
    initial_values.each do |value|
      self << value
    end
  end
  
  def <<(value)
    return if value.nil?
    
    new_node = Node.new(value)
    @root << new_node
    
    return new_node
  end
  
  def find_insertion_leaf(value, leaf = @root)
    return false if leaf.nil?
    
    # if the new value is larger than any value in the leaf, recurse on the right most leaf
    insertion_leaf = if value > leaf.max
      find_insertion_leaf(value, leaf.last.right_leaf)
    else
      # otherwise walk through the nodes until you find a stored value larger than the value that's
      # being added. Then add it to that leaf's left leaf.
      node_index = 0
      node_value = leaf[node_index]
      while (value > node_value)
        node_value = leaf[node_index += 1]
      end
      leaf[node_index].left_leaf
    end
    
    # if the recursive function returns false, it means that a child leaf that was recursed on didn't
    # actually exist, so use the leaf that was passed in originally
    return insertion_leaf || leaf
  end
  
  def root=(leaf)
    @root = leaf
  end
  
  def remove(value)
    
  end
  
  def exists?(value)
    
  end
  
  def explain_nodes
    puts @root.recursive_explanation
  end
  
  def to_s
    "[#{@root.full_array.join(', ')}]"
  end
end

class ClassMismatch < Exception; end
class NoRoomAtTheInn < Exception; end
