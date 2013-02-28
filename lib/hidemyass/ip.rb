# http://hidemyass.com masks the IP addresses
# with decoy CSS classes and styles so it's hard to read them.
#
# Let's emulate what our browser does in order to get the real address.
module HideMyAss
  class IP

    attr_accessor :decoys, :address
    TAGS = %w(span div text).freeze

    def initialize(encoded_address)
      # Select decoy CSS classes: those which result in a hidden element
      @decoys = encoded_address.css("style").text.split("\n").
        select {|style| style =~ /none/}

      # Find enclosing IP elements
      elements = encoded_address.children

      # Process elements and get rid of those with decoy classes
      elements = decode(elements)

      # Finally grab enclosing elements content, which is the real IP
      @address = elements.map(&:content).join
      self
    end

    # Receives an array of elements
    # and returns another without invisibles.
    def decode(elements)
      elements.each do |element|

        # Remove elements with CSS style "none"
        if !TAGS.include?(element.name) || (element["style"] && element["style"] =~ /none/)
          element.children.remove

        # Get rid of decoy children
        elsif element["class"]
          decoys.each do |decoy|
            element.children.remove if decoy.include?(element["class"])
          end
        end
      end

      elements
    end

    # Make sure the IP has a valid format.
    def valid?
      address.split(".").reject(&:empty?).size == 4
    end

    def inspect
      "#<#{self.class}> @address=#{address}>"
    end

  end # IP
end # HideMyAss