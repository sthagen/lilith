class FbdevFsNode < VFSNode
  getter fs

  def initialize(@fs : FbdevFS)
  end

  def open(path : Slice) : VFSNode?
    nil
  end

  def read(slice : Slice, offset : UInt32,
           process : Multiprocessing::Process? = nil) : Int32
    byte_size = FbdevState.buffer.size * sizeof(UInt32)
    if offset > byte_size
      VFS_ERR
    else
      size = min(slice.size, byte_size - offset)
      byte_buffer = FbdevState.buffer.to_unsafe.as(UInt8*) + offset
      # NOTE: use memcpy for faster memory copying
      memcpy(slice.to_unsafe, byte_buffer, size.to_usize)
      size
    end
  end

  def write(slice : Slice, offset : UInt32,
            process : Multiprocessing::Process? = nil) : Int32
    byte_size = FbdevState.buffer.size * sizeof(UInt32)
    if offset > byte_size
      VFS_ERR
    else
      size = min(slice.size, byte_size - offset)
      byte_buffer = FbdevState.buffer.to_unsafe.as(UInt8*) + offset
      # NOTE: use memcpy for faster memory copying
      memcpy(byte_buffer, slice.to_unsafe, size.to_usize)
      size
    end
  end

  def ioctl(request : Int32, data : Void*) : Int32
    case request
    when SC_IOCTL_TIOCGWINSZ
      IoctlHandler.winsize(data, FbdevState.width, FbdevState.height, 1, 1)
    else
      -1
    end
  end

  def read_queue
    nil
  end
end

class FbdevFS < VFS
  def name
    @name.not_nil!
  end

  @next_node : VFS? = nil
  property next_node

  def initialize
    @name = GcString.new "fb0" # TODO
    @root = FbdevFsNode.new self
  end

  def root
    @root.not_nil!
  end
end
