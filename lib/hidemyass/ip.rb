module HideMyAss
  class IP
    
    attr_accessor :decoys, :address
    
    VALID_TAGS = %w(span div text).freeze
    
    def initialize(encoded_address)
      @decoys  = encoded_address.css("style").text.split("\n").select {|style| style =~ /none/}
      elements = encoded_address.children
      decode(elements)
      @address = elements.map(&:content).join
      
      self
    end
    
    def decode(elements)
      elements.each do |element|
        if !VALID_TAGS.include?(element.name) || (element["style"] && element["style"] =~ /none/)
          element.children.remove
        elsif element["class"]
          decoys.each { |decoy| element.children.remove if decoy.include?(element["class"]) }
        end
      end
    end
    
    def valid?
      address.split(".").reject(&:empty?).size == 4
    end
    
    def inspect
      "#<#{self.class}> @address=#{address}>"
    end
    
  end # IP
end # HideMyAss