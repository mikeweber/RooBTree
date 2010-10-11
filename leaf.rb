class Leaf
  instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }
  
  attr_accessor :tree
  attr_reader :parent_leaf
  
  MAX_SIZE = 2
  @nodes = []
  
  def initialize(nodes = [], tree = nil)
    raise(ClassMismatch, "Cannot assign a leaf anything other than an array of nodes") unless nodes.is_a?(Array) && (nodes.empty? || nodes.all? { |node| node.is_a?(Node) })
    
    self.tree = tree unless tree.nil?
    @nodes = nodes
  end
  
  def parent_leaf
    @parent_leaf
  end
  
  def parent_leaf=(leaf)
    self.tree = self.parent_leaf.is_a?(RooBTree) ? self.parent_leaf : self.parent_leaf.tree unless self.parent_leaf.nil?
  end
  
  def values
    self.collect { |node| node.to_s }
  end
  
  def has_room?
    !self.full?
  end
  
  def full?
    self.size >= MAX_SIZE
  end
  
  def <<(node)
    raise(ClassMismatch, "Only nodes can be added to leaves") unless node.is_a?(Node)
    
    if self.has_room?
      index = 0
      if next_leaf = self[index]
        leaf_value = next_leaf.value
        while (node.value > leaf_value && index < @nodes.size)
          puts "checking nodes..."
          index += 1
          if next_leaf = self[index]
            puts "found a node for index #{index}"
            leaf_value = next_leaf.value
          end
        end
      end
      self.insert(index, node)
    else
      self.split!(node)
    end
    
    node.owner_leaf = self
    
    return node
  end
  
  def split!(new_node)
    temp_leaf = (self + [new_node]).sort_by { |node| node.value }
    median_node_index = (temp_leaf.size / 2)
    right_node_start = median_node_index + 1
    left_node_end = median_node_index - 1
    
    median_node, temp_left_leaf, temp_right_leaf = [temp_leaf[median_node_index], temp_leaf[0..left_node_end], temp_leaf[right_node_start..-1]]
    median_node.left_leaf = Leaf.new(temp_left_leaf)
    median_node.right_leaf = Leaf.new(temp_right_leaf)
    
    if self.parent_leaf
      self.parent_leaf << median_node
    else
      self.tree.root = self
    end
    
    return median_node
  end
  
  def recursive_explanation
    ([self.explanation, '\n'] + @child_leaves.collect { |leaf| leaf.recursive_explanation }).join()
  end
  
  def explanation
    "[#{self.values.join('|')}]"
  end
  
  def full_array
    arr = []
    
    self.each do |node|
      arr += node.left_leaf.full_array if node.left_leaf
      arr << node
      arr += node.right_leaf.full_array if node.last_node? && node.right_leaf
    end
    
    return arr
  end
  
  protected
  
  def method_missing(name, *args, &block)
    target.send(name, *args, &block)
  end
  
  def target
    @nodes ||= []
  end
end
