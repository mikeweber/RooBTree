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
    self.tree = leaf.is_a?(RooBTree) ? leaf : leaf.tree unless leaf.nil?
    @parent_leaf = leaf
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
      puts "leaf has room"
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
      @nodes.insert(index, node)
      node.owner_leaf = self
    else
      split!(node)
    end
    
    return node
  end
  
  def recursive_explanation
    ([self.explanation, '\n'] + @child_leaves.collect { |leaf| leaf.recursive_explanation }).join()
  end
  
  def explanation
    "[#{self.values.join('|')}]"
  end
  
  def recursive_html_explanation
    s = "<ul>"
    self.each do |node|
      s << node.left_leaf.recursive_html_explanation if node.left_leaf
      s << "<li>#{node.value}</li>"
      s << node.right_leaf.recursive_html_explanation if node.last_node? && node.right_leaf
    end
    s << "</ul>"
    
    return s
  end
  
  def html_explanation
    "<ul>" + self.collect { |node| "<li>#{node.value}<li>" }.join + "</ul>"
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
  
  private
  
  def split!(new_node)
    temp_leaf = (self + [new_node]).sort_by { |node| node.value }
    median_node_index = (temp_leaf.size / 2)
    left_node_end = median_node_index - 1
    right_node_start = median_node_index + 1
    
    median_node, temp_left_nodes, temp_right_nodes = [temp_leaf[median_node_index], temp_leaf[0..left_node_end], temp_leaf[right_node_start..-1]]
    median_node.left_leaf = Leaf.new(temp_left_nodes)
    median_node.right_leaf = Leaf.new(temp_right_nodes)
    
    if self.parent_leaf
      self.parent_leaf << median_node
      raise [median_node.value, 
        self.parent_leaf.first.value, 
        self.parent_leaf.first.left_leaf, 
        self.parent_leaf.first.right_leaf].inspect
    else
      @nodes = [median_node]
      self.tree.root = self
    end
    
    return median_node
  end
end
