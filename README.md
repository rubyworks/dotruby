# DotRuby (formerly known as Ruby Courtier)

**Univeral Runtime Configuration for Ruby Tools**

[Homepage](http://rubyworks.github.com/dotruby) /
[Report Issue](http://github.com/rubyworks/dotruby/issues) /
[Source Code](http://github.com/rubyworks/dotruby)
( [![Build Status](https://secure.travis-ci.org/rubyworks/dotruby.png)](http://travis-ci.org/rubyworks/dotruby) )


## About

DotRuby is a is multi-tenant runtime configuration system for Ruby tools.
It is designed to facilitate Ruby-based configuration for multiple
tools in a single file, and designed to work whether the tool has
built-in support for DotRuby or not. The syntax is simple, universally
applicable, and... oh yeah, damn clever.

DotRuby can be used with any Ruby-based commandline tool or library utilized by
such tool, where there exists some means of configuring it via a toplevel or global
interface; or the tool has been designed to directly support DotRuby, of course.


## Installation

To use DotRuby with any tool, including those that do not in themsleves have a
built-in dependency on DotRuby, first install the DotRuby library, typically
via RubyGems:

    gem install dotruby

Then add `-rdotruby` to your system's `RUBYOPT` environment variable.

    $ export RUBYOPT='-rdotruby'

You will want to add that to your `.bashrc`, `.profile` or equivalent configuration
script, so it is always available.

To use DotRuby with tools that support DotRuby directly, there is likely nothing
to install. Installing the tool should install `dotruby` via a dependency and
load runtime configurations when the tool is used.


## Instruction

### Configuring

To use DotRuby in a project create a configuration file called `.ruby`.
(Hey, now you know why it has the name, *DotRuby*!). In this file add 
configuration code as you would normally do for a given library. The
only caveat is that all such configurations must be against a constant.

For example, let's say we need to configure RSpec. In the `.ruby` file we can
add the following.

    RSpec.configure do |config|
      config.color_enabled = true
      config.tty = true
      config.formatter = :documentation
    end

This might seems pretty ordinary, but consider that the RSpec library hasn't
necessarily been loaded when this is evaluated! Think about that a bit
and we'll explain how it works below.

For another example, let's demonstrate how we could use this to configure Rake
tasks. Rake is not the most obvious choice, since developers are just as happy
to keep using a Rakefile. That's fine. But using Rake as an example serves to
show that it *can* be done, and also it makes a good tie-in with next example.

    Rake.file do
      desc 'generate yard docs'
      task :yard do
        sh 'yard'
      end
    end

Now when `rake` is run the tasks defined in this configuration will be available.

Getting back to our Rake example, you might wonder why anyone would want to do 
this. That's where the *multi-tenancy* comes into play. Let's add another
configuration.

    title = "MyApp"

    Rake.file do
      desc 'generate yard docs'
      task :yard do
        sh "yard doc --title #{title}"
      end
    end

    QED.config do |c|
       c.title = "#{title} Demos"
    end

Now we have configuration for both the `rake` tool and the `qedoc` tool in
a single file. Thus we gain the advantage of reducing the file count of our 
project while pulling our tool configurations together into one place.
Moreover, these configurations can potentially share settings as demonstrated
here via the `title` local variable.

### Tagging

Some commands don't correspond to their API namespaces. For example, in the 
above example we configured QED's title option. But that is actually of
use when running the `qedoc` command, which belongs to the same library.
We can easily tell DotRuby to expect this by adding a `tag`.

    tag :QED, :command=>'qedoc'

DotRuby's configurations are triggered by three criteria: a constant,
a command and a feature. In the above tag example, the constant is
`QED`, the command is `qedoc` and the feature is not given so it defaults
to the constant name downcased, i.e. `qed`. If need be we can sepcify a
different feature via the `:feature` option.

### Profiles

Sometimes you need to configure a tool with different settings for different
circumstances. If the tool doesn't have built in support for this, DotRuby
provides some convenience methods for handling this via environment variables.

A `profile` block can be used to only run if `ENV['profile']', or as a nice
shortcut `ENV['p']` is set to the given name.

    profile :doc do
      RSpec.configure do |config|
        config.color_enabled = true
        config.tty = true
        config.formatter = :documentation
      end
    end

To be clear why this is just a convenience method, it is essentially the same
as doing:

    if 'doc' === (ENV['profile'] || ENV['p'])
      ...
    end

When utilizing the tool, set the `profile` via an environment variable.

    $ profile=cov qed

Or for additional convenience just `p`:

    $ p=cov qed

### Environments

DotRuby also provided the `environment` convenience method, which is along
the same line but allows any environment variable to be used.

    environment :testing => 'yes' do
      ...
    end

Again, this is just a shortcut for:

    if 'yes' === ENV['testing']
       ...
    end

It is recommended that you use the `profile` instead of `environment` unless their
is specific reason not to do so. This makes it easier for other to utilize, instead
of having to recollect which environment variables where used for what configurations.

### Tweaks

In the Rake example, you might notice that `Rake.file` isn't an official method
of the Rake API. This is called a *tweak* and is built-in with DotRuby. Some
tools that we might wish to use with DotRuby don't have an interface that
suffices, in these cases a tweak can be used to give it one.

If there is a tool you would like to configure with DotRuby, but it doesn't
provided a means for it, and a reasonably simple tweak can make it viable, 
please submit a patch and it will be added to DotRuby. And let the tool creator
knwo about it! Hopefully, in time tool developers will make the tweak unneccesary.

### Importing

**(Comming soon)**

Configurations can also be pulled in from other gems using the `import` command.
For instance, if we wanted to reuse the Rake configurations as defined in
the `QED` gem:

    import :Rake, :from=>'qed'

If a particule profile or environment is needed, these can specified as options.

    import :RSpec, :from=>'rspec', :profile=>'simplecov'

As long as a project includes its `.ruby` file (and any local imported files)
in it's gem package, it's possible to share configurations in this manner.

Generally we want all our configurations stored in a single file, but if need be
the `import` method can be used to place configuration in multiple files.
Simple use a local path `import` method to load them, e.g.

    import './config/*.dotrb'

DotRuby translates the initial dot into a path relative to the file itself,
i.e. `__dir__`. Why can't we leave off the initial dot? If we did import
would work like require and try to load the file from a gem --however,
there is an issue with implementing this that needs to be resolved with 
Ruby itself (autoload), so this feature is on hold for the time being.

### 3rd Paty Support

To support DotRuby, all developers need to do is make sure their tools
have a way of being configured via a toplevel constant.


## Dependencies

### Libraries

DotRuby depends on the [Finder](http://rubyworks.github.com/finder) library
to provide reliable load path and Gem searching. This is used when importing
configurations from other projects. (It's very much a shame Ruby and RubyGems
does not have this kind of functionality built-in.)

### Core Extensions

DotRuby uses two core extensions, `#to_h`, which applies to a few different
classes, and `String#tabto`. These are *copied* from
[Ruby Facets](http://rubyworks.github.com/facets) to ensure a high
standard of interoperability.

Both of these methods have been suggested for inclusion in Ruby proper.
Please head over to Ruby Issue Tracker and add your support.

* http://bugs.ruby-lang.org/issues/749
* http://bugs.ruby-lang.org/issues/6056


## Release Notes

Please see HISTORY.md file.


## Copyrights & Licensing

DotRuby is copyrighted open-source software.

    Copyright (c) 2011 Rubyworks. All rights reserved.

It is modifiable and redistributable in accordance with the **BSD-2-Clause** license.

See LICENSE.txt file for details.
