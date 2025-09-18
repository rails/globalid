class GlobalID
  # Mix `GlobalID::Identification` into any model with a `#find(id)` class
  # method. Support is automatically included in Active Record.
  #
  #   class Person
  #     include ActiveModel::Model
  #     include GlobalID::Identification
  #
  #     attr_accessor :id
  #
  #     def self.find(id)
  #       new id: id
  #     end
  #
  #     def ==(other)
  #       id == other.try(:id)
  #     end
  #   end
  #
  #   person_gid = Person.find(1).to_global_id
  #   # => #<GlobalID ...
  #   person_gid.uri
  #   # => #<URI ...
  #   person_gid.to_s
  #   # => "gid://app/Person/1"
  #   GlobalID::Locator.locate person_gid
  #   # => #<Person:0x007fae94bf6298 @id="1">
  module Identification

    # Returns the Global ID of the model.
    #
    #   model = Person.new id: 1
    #   global_id = model.to_global_id
    #   global_id.model_class # => Person
    #   global_id.model_id # => "1"
    #   global_id.to_param # => "Z2lkOi8vYm9yZGZvbGlvL1BlcnNvbi8x"
    def to_global_id(options = {})
      GlobalID.create(self, options)
    end
    alias to_gid to_global_id

    # Returns the Global ID parameter of the model.
    #
    #   model = Person.new id: 1
    #   model.to_gid_param # => ""Z2lkOi8vYm9yZGZvbGlvL1BlcnNvbi8x"
    def to_gid_param(options = {})
      to_global_id(options).to_param
    end

    # Returns the Signed Global ID of the model.
    # Signed Global IDs ensure that the data hasn't been tampered with.
    #
    #   model = Person.new id: 1
    #   signed_global_id = model.to_signed_global_id
    #   signed_global_id.model_class # => Person
    #   signed_global_id.model_id # => "1"
    #   signed_global_id.to_param # => "BAh7CEkiCGdpZAY6BkVUSSIiZ2..."
    #
    # ==== Expiration
    #
    # Signed Global IDs can expire some time in the future. This is useful if
    # there's a resource people shouldn't have indefinite access to, like a
    # share link.
    #
    #   expiring_sgid = Document.find(5).to_sgid(expires_in: 2.hours, for: 'sharing')
    #   # => #<SignedGlobalID:0x008fde45df8937 ...>
    #   # Within 2 hours...
    #   GlobalID::Locator.locate_signed(expiring_sgid.to_s, for: 'sharing')
    #   # => #<Document:0x007fae94bf6298 @id="5">
    #   # More than 2 hours later...
    #   GlobalID::Locator.locate_signed(expiring_sgid.to_s, for: 'sharing')
    #   # => nil
    #
    # In Rails, an auto-expiry of 1 month is set by default.
    #
    # You need to explicitly pass `expires_in: nil` to generate a permanent
    # SGID that will not expire,
    #
    #   never_expiring_sgid = Document.find(5).to_sgid(expires_in: nil)
    #   # => #<SignedGlobalID:0x008fde45df8937 ...>
    #
    #   # Any time later...
    #   GlobalID::Locator.locate_signed never_expiring_sgid
    #   # => #<Document:0x007fae94bf6298 @id="5">
    #
    # It's also possible to pass a specific expiry time
    #
    #   explicit_expiring_sgid = SecretAgentMessage.find(5).to_sgid(expires_at: Time.now.advance(hours: 1))
    #   # => #<SignedGlobalID:0x008fde45df8937 ...>
    #
    #   # 1 hour later...
    #   GlobalID::Locator.locate_signed explicit_expiring_sgid.to_s
    #   # => nil
    #
    # Note that an explicit `:expires_at` takes precedence over a relative `:expires_in`.
    #
    # ==== Purpose
    #
    # You can even bump the security up some more by explaining what purpose a
    # Signed Global ID is for. In this way evildoers can't reuse a sign-up
    # form's SGID on the login page. For example.
    #
    #   signup_person_sgid = Person.find(1).to_sgid(for: 'signup_form')
    #   # => #<SignedGlobalID:0x007fea1984b520
    #   GlobalID::Locator.locate_signed(signup_person_sgid.to_s, for: 'signup_form')
    #   => #<Person:0x007fae94bf6298 @id="1">
    def to_signed_global_id(options = {})
      SignedGlobalID.create(self, options)
    end
    alias to_sgid to_signed_global_id

    # Returns the Signed Global ID parameter.
    #
    #   model = Person.new id: 1
    #   model.to_sgid_param # => "BAh7CEkiCGdpZAY6BkVUSSIiZ2..."
    def to_sgid_param(options = {})
      to_signed_global_id(options).to_param
    end

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      # Build a Global ID from the given object.
      #
      # If the object responds to `to_global_id` it will return the result of that call.
      #   Person.build_global_id(Person.find(1)) # => #<GlobalID:0x000000012b7dcea0 @uri=#<URI::GID gid://app/Person/1>>
      # If the object is a string or an integer, it will build a GlobalID using that object.
      #   Person.build_global_id(1) # => #<GlobalID:0x000000012b7dcea0 @uri=#<URI::GID gid://app/Person/1>>
      # If the object is not a string or an integer, it will raise an ArgumentError.
      #   Person.build_global_id(Person) # => ArgumentError: Can't build a Global ID for Class
      #
      # An app is required to create a GlobalID. Pass the :app option or set the default GlobalID.app.
      def build_global_id(obj, options = {})
        return obj.to_global_id(options) if obj.respond_to?(:to_global_id)
        raise ArgumentError, "Can't build a Global ID for #{obj.class}" unless obj.is_a?(String) || obj.is_a?(Integer)

        struct = Struct.new(:id, :class).new(id: obj, class: self )
        return GlobalID.create(struct, options)
      end

      # Build a Signed Global ID from the given object.
      #
      # If the object responds to `to_signed_global_id` it will return the result of that call.
      #   Person.build_signed_global_id(Person.find(1)) # => <SignedGlobalID:0x008fde45df8937 ...>
      # If the object is a string or an integer, it will build a GlobalID using that object.
      #   Person.build_signed_global_id(1) # => <SignedGlobalID:0x008fde45df8937 ...>
      # If the object is not a string or an integer, it will raise an ArgumentError.
      #   Person.build_signed_global_id(Person) # => ArgumentError: Can't build a Signed Global ID for Class
      #
      # An app is required to create a SignedGlobalID. Pass the :app option or set the default GlobalID.app.
      def build_signed_global_id(obj, options = {})
        return obj.to_signed_global_id(options) if obj.respond_to?(:to_signed_global_id)
        raise ArgumentError, "Can't build a Signed Global ID for #{obj.class}" unless obj.is_a?(String) || obj.is_a?(Integer)

        struct = Struct.new(:id, :class).new(id: obj, class: self )
        SignedGlobalID.create(struct, options)
      end
    end
  end
end
