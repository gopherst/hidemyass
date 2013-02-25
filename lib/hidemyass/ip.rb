# HideMyAss masks real IPs with CSS classes
# in order to prevent crawlers from grabbing them.
#
# Here we emulate what our browser does
# so we can get the real IP addresses.

module HideMyAss
  class IP
    attr_accessor :decoys, :address

    VALID_TAGS = %w(span div text).freeze

    def initialize(encoded_address)
      # Select decoy CSS classes: those which result in a hidden element
      @decoys = encoded_address.css("style").text.split("\n").
        select {|style| style =~ /none/}

      # Find enclosing IP elements
      elements = encoded_address.children

      # Process elements and get rid of those with decoy classes
      decode(elements)

      # Finally grab enclosing elements content, which is the real IP
      @address = elements.map(&:content).join
      self
    end

    # Receives an array of elements
    # and removes those that are invisible.
    def decode(elements)
      elements.each do |element|
        if !VALID_TAGS.include?(element.name) || (element["style"] && element["style"] =~ /none/)
          element.children.remove
        elsif element["class"]
          decoys.each { |decoy| element.children.remove if decoy.include?(element["class"]) }
        end
      end
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