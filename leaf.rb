class Leaf
  instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }
  
  MAX_SIZE = 2
  @nodes = []
  
  def initialize(nodes = [], tree = nil)
    raise(ClassMismatch, "Cannot assign a leaf anything other than an array of nodes") unless nodes.is_a?(Array) && (nodes.empty? || nodes.all? { |node| node.is_a?(Node) })
    
    @tree = tree
    (nodes || []).each do |node|
      self << node
    end
  end
  
  def parent_leaf
    @parent_leaf
  end
  
  def parent_leaf=(leaf)
    @parent_leaf = leaf
  end
  
  def tree
    @tree || (self.parent_leaf.tree unless self.parent_leaf.nil?)
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
      if next_node = self[index]
        node_value = next_node.value
        while (node.value > node_value && index < @nodes.size)
          index += 1
          if next_node = self[index]
            node_value = next_node.value
          end
        end
      end
      @nodes.insert(index, node)
      node.owner_leaf = self
      if index > 0
        # Unless this node is the first Node in the Leaf, this Node should take over the responsibility of tracking
        # the previous Node's right leaf as the new Node's left leaf. The position stays the same, but the ownership
        # stays consistent. All Nodes own the child Leaf to their left, unless they're the last Node in the Leaf. In
        # that case, they're allowed to track a child Leaf to their right.
        node.left_leaf ||= @nodes[index - 1].right_leaf
      end
    else
      median_node = split!(node)

      if self.parent_leaf
        self.parent_leaf << median_node
      else
        new_root = Leaf.new([median_node], self.tree)
        self.tree.root = new_root
      end
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
    median_node.children = [Leaf.new(temp_left_nodes, self.tree), Leaf.new(temp_right_nodes, self.tree)]
    
    return median_node
  end
end
