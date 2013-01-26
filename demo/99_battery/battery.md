# Battery

## Basic example

Given a `.ruby` file containing:

    Example.configure do
      $result = "Example configured!"
    end

When we run the command:

    $ example

Which requires the file `example.rb`.

Then the result should contain:

    Example configured!

