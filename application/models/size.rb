class Size < Sequel::Model
  def self.get_size(size_id)
    where(id: size_id).get(:size) || ""
  end

  def self.get_all_size_names() 
    sizes = []
    Size.all().each do |size|
      sizes.append(size.size)
    end
    return sizes
  end

  def self.get_id(size)
    id = self.first(size: size).id

    return -1 unless id
    id
  end
end
