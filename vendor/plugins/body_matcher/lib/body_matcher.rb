require 'hpricot'

##
# The BodyMatcher is the module which makes it all happen.  To 
# enable body matching, just include this module in your TestCase class:
#
#   class Test::Unit::TestCase
#     include BodyMatcher
#
#     self.use_transactional_fixtures = true
#     self.use_instantiated_fixtures  = false
#   end
# 
module BodyMatcher
  class Matcher
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }

    def initialize(body) #:nodoc:
      @body = body
      @doc  = Hpricot(body)
    end

    ## 
    # Finds a specific element:
    #   body['#login']
    #
    # Raises an exception if that element is not found.
    def [](*args)
      return @body[*args] if args.size > 1
      elements = @doc.search(args.first)
      raise "Element(s) matching #{search} not found." if elements.empty?
      elements.map! { |e| Element.new(e) }
      elements.size == 1 ? elements.first : elements
    end

    def method_missing(*args, &block)
      @body.send(*args, &block)
    end
  end

  class Element
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }

    def initialize(element) #:nodoc:
      @element = element
      @text    = element.inner_text
    end

    ##
    # Accesses an attribute of an element:
    #   body['#name_field']['value']
    def [](attribute)
      @element[attribute]
    end

    ##
    # Returns a hash of the element's attributes.
    #   body['#name_field'].attributes
    def attributes
      @element.attributes
    end

    def method_missing(*args, &block) #:nodoc:
      @text.send(*args, &block)
    end
  end

  def self.included(base) #:nodoc:
    require 'hpricot'

    alias_body = proc do
      alias_method :real_rails_body, :body
      def body
        Matcher.new(real_rails_body) 
      end
    end

    ActionController::TestResponse.class_eval &alias_body
    Test::Unit::TestCase.class_eval           &alias_body

    alias_match = lambda do
      alias_method :test_spec_match, :match
      def match(target)
        test_spec_match target.is_a?(Regexp) ? target : %r(#{target})
      end
    end

    if defined? Test::Spec
      Test::Spec::ShouldNot.class_eval &alias_match
      Test::Spec::Should.class_eval    &alias_match
    end
  end
end
