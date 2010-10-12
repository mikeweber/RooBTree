class Node
  attr_accessor :owner_leaf
  attr_reader :value
  
  def initialize(init_value)
    raise "cannot be nil" if init_value.nil?
    
    @value = init_value
    @left_leaf = nil
    @right_leaf = nil
  end
  
  def my_index
    self.owner_leaf.index(self)
  end
  
  def last_node?
    self.my_index == (self.owner_leaf.size - 1)
  end
  
  def left_leaf
    @left_leaf
  end
  
  def left_leaf=(leaf)
    assign_leaf(leaf)
    @left_leat = leaf
  end
  
  def right_leaf
    @right_leaf
  end
  
  def right_leaf=(leaf)
    assign_leaf(leaf)
    @right_leaf = leaf
  end
  
  def to_s
    @value.to_s
  end
  
  def <=>(other)
    self.to_s <=> other.to_s
  end
  
  private
  
  def assign_leaf(leaf)
    leaf.parent_leaf = self.owner_leaf
  end
end
