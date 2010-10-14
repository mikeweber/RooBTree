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
    
    # Let the node know which leaf it's in
    node.owner_leaf = self
    # Reassign ownership of child leaves
    reassign_children(node, index)
    
    if @nodes.size > Leaf::MAX_SIZE
      median_node = split!

      if self.parent_leaf
        self.parent_leaf << median_node
      else
        new_root = Leaf.new([median_node], self.tree)
        self.tree.root = new_root
      end
    end
    
    return node
  end
  
  def find(value)
    return nil if self.empty?
    # walk through the nodes until you find a stored value equal to the value passed in.
    # If none is found in this leaf, stop when a value larger than the search value
    # is found. Then search this node's left leaf. If the value is larger than all
    # of the values in this leaf, search the last node's right leaf.
    node = self[node_index = 0]
    while (node && value >= node.value && node_index < self.size)
      return node.value if node.value == value
      
      node = self[node_index += 1]
    end
    
    if node_index < self.size
      node.left_leaf.find(value) if node.left_leaf
    else
      self.last.right_leaf.find(value) if self.last.right_leaf
    end
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
  
  def reassign_children(node, index)
    if index > 0
      # Unless this node is the first Node in the Leaf, this Node should take over the responsibility of tracking
      # the previous Node's right leaf as the new Node's left leaf (unless the node already has a left leaf of its own). The position stays the same, but the ownership
      # stays consistent. All Nodes own the child Leaf to their left, unless they're the last Node in the Leaf. In
      # that case, they're allowed to track a child Leaf to their right.
      node.left_leaf ||= @nodes[index - 1].right_leaf
      @nodes[index - 1].right_leaf = nil
    end
    # if there is a node to right, set that node's left_leaf to this node's right leaf
    if index + 1 < self.size
      @nodes[index + 1].left_leaf = node.right_leaf
      node.right_leaf = nil
    end
  end
  
  def median_node_index
    @nodes.size / 2
  end
  
  def left_leaf_end
    median_node_index - 1
  end
  
  def right_leaf_start
    median_node_index + 1
  end
  
  def split!
    median_node, temp_left_nodes, temp_right_nodes = [@nodes[median_node_index], @nodes[0..left_leaf_end], @nodes[right_leaf_start..-1]]
    # before assigning the median node the children leaves, hand over the median node's left leaf to the node to the left
    temp_left_nodes.last.right_leaf = median_node.left_leaf unless temp_left_nodes.empty?
    median_node.children = [Leaf.new(temp_left_nodes, self.tree), Leaf.new(temp_right_nodes, self.tree)]
    
    return median_node
  end
end
