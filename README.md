# DotRuby

**Universal Runtime Configuration for Ruby Tools**

[Homepage](http://rubyworks.github.com/dotruby) /
[Report Issue](http://github.com/rubyworks/dotruby/issues) /
[Source Code](http://github.com/rubyworks/dotruby)
( [![Build Status](https://secure.travis-ci.org/rubyworks/dotruby.png)](http://travis-ci.org/rubyworks/dotruby) )


## [About](#about)

DotRuby is a is multi-tenant runtime configuration system for Ruby tools.
It is designed to facilitate Ruby-based configuration for multiple
tools in a single file, and designed to work whether the tool has
built-in support for DotRuby or not. The syntax is simple, universally
applicable, and... oh yeah, damn clever.

DotRuby can be used with any Ruby-based commandline tool or library utilized by
such tool, where there exists some means of configuring it via a toplevel or global
interface; or the tool has been designed to directly support DotRuby, of course.


## [Installation](#installation)

To use DotRuby with any tool, including those that do not in themselves have a
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


## [Instruction](#instruction)

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

Now we have configuration for both the `rake` tool and the `qed` tool in
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
to the constant name downcased, i.e. `qed`. If need be we can specify a
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
know about it! Hopefully, in time tool developers will make the tweak unnecessary.

### Importing

**(Comming soon)**

Configurations can also be pulled in from other gems using the `import` command.
For instance, if we wanted to reuse the Rake configurations as defined in
the `QED` gem:

    import :Rake, :from=>'qed'

If a particular profile or environment is needed, these can specified as options.

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

### Third Party Support

To support DotRuby, all developers have to do is make sure their tools
have a way of being configured via a toplevel namespace constant.

It is also helps when the the library name to be required is the the same
as the library's namespace downcased. When it's not the same a `tag` entry
is needed to tell DotRuby from which feature to expect the constant. For
popular tools that have such a discrepancy, DotRuby provides *tweaks* that
take care of it automatically. But it's always best to follow the general
good practice that the gem name is the same as the lib name which is the same
as the namespace downcased.

Finally a third party tool can take the final step of full support by using 
DotRuby as it preferred means of configuration. In that case, just make 
sure to `require 'dotruby'`.


## [How It Works](#howitworks)

The design of DotRuby is actually quite clever. What it does is proxy all
calls to *virtual constants*, keeping a record of the messages sent to them.
When it is time to apply these configurations, it fins the ones that apply
to the given command and sends the recorded messages on the the real constants.
If those constants haven't been loaded yet, it adds a hook to `require` and 
waits for the matching feature to load, at which time it applies the configuration.
In the way, DotRuby can actually be required before or after the library that
it will configure and it works regardless.

There is an unfortunate caveat here though. Luckily it will rarely be a real issue,
but it is possible for `autoload` to fowl up the works, b/c it does not call out
the standard require method. So there is no way override it and insert the necessary
hook. Again, this is not likely to be a problem, especially if good naming practices
are used, but it a good thing to know just in case you run into some unexpected
behavior.


## [Dependencies](#dependencies)

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


## [Release Notes](#releasenotes)

Please see HISTORY.md file.


## [Copyrights & Licensing](#copyrights)

DotRuby is copyrighted open-source software.

    Copyright (c) 2011 Rubyworks. All rights reserved.

It is modifiable and redistributable in accordance with the **BSD-2-Clause** license.

See LICENSE.txt file for details.
