class Node
  attr_reader :owner_leaf
  
  def initialize(init_value)
    raise "cannot be nil" if init_value.nil?
    
    @value = init_value
    @left_leaf = nil
    @right_leaf = nil
  end
  
  def value
    @value.to_s
  end
  
  def my_index
    self.owner_leaf.index(self)
  end
  
  def last_node?
    self.my_index == (self.owner_leaf.size - 1)
  end
  
  def children
    [self.left_leaf, self.right_leaf]
  end
  
  def children=(leaves)
    self.left_leaf, self.right_leaf = leaves
  end
  
  def left_leaf
    @left_leaf
  end
  
  def left_leaf=(leaf)
    assign_parent_leaf(@left_leaf = leaf)
  end
  
  def right_leaf
    @right_leaf
  end
  
  def right_leaf=(leaf)
    assign_parent_leaf(@right_leaf = leaf)
  end
  
  def owner_leaf=(leaf)
    @owner_leaf = leaf
    
    children.each do |child_leaf|
      assign_parent_leaf(child_leaf)
    end
  end
  
  def to_s
    @value.to_s
  end
  
  def <=>(other)
    self.to_s <=> other.to_s
  end
  
  private
  
  def assign_parent_leaf(leaf)
    return if leaf.nil?
    # My child's parent_leaf is the leaf that I am in
    leaf.parent_leaf = self.owner_leaf
    return leaf
  end
end
