class Module
  # By extending Module with a configure class method we ensure
  # that we can always configure a program through this interface,
  # even if it lacks any other interface with which to do so.
  #
  # This is a bit experimental.
  # 
  def configure(&block)
    block.call  # module_eval(&block)
  end
end

