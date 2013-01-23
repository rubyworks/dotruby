# DotRuby - Universal Runtime Configuration for Ruby Tools
#
# Q. What if a program needs to be configured, but it does not provide
# an interface via a constant? For example, what if it uses a global
# variable?
#
# A. Most likely the program has a toplevel namespace module. You
# can always call module_eval to handle it if there is no other means.
# You ccould alos define a *make-shift* extension method on it that does
# the dirty deed. If there is no such module, just make a *make-shift*
# module for it too.
#
#    module ProgramWithoutNamespace
#      def self.configure(settings)
#        $dirty_program_settings = settings
#      end
#    end
#
# We call this *tweaking*.

require 'dotruby/api'

DotRuby.configure!

# DotRuby Copyright (c) 2012 Rubyworks. All rights reserved. (BSD-2-Clause License)
