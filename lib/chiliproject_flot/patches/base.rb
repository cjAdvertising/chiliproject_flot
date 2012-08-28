# encoding: utf-8

module ChiliprojectFlot
  module Patches

    # Public: Base patch module abstracting common features.
    module Base

      # Public: Fetch the target class to patch.
      #
      # Returns Class target class.
      # Raises NotImplementedError if not implemented.
      def target
        raise NotImplementedError
      end

      # Public: Determine whether the target has been patched.
      #
      # Returns Boolean if the target has already been patched.
      def patched?
        target.included_modules.include? self
      end

      # Public: Apply the patch if it hasn't been already applied.
      #
      # Returns nothing.
      def patch
        patch! unless patched?
      end

      # Public: Apply the patch without checking whether it's been applied.
      #
      # Returns nothing.
      def patch!
        target.send :include, self
      end

      # Public: Include instance method module when a patch module is included.
      #
      # Returns nothing.
      def included(base)
        base.send :include, self::InstanceMethods
      end
    end
  end
end
