## Midwife
A collection of preprocessors for frontend development.

## Install

    $ gem install midwife

## Setup

In Rakefile:

```ruby
require 'midwife'
```

The rest:

    $ rake setup

## Usage

    rake care     # Care for your haml/scss
    rake clean    # Remove any temporary products.
    rake clobber  # Remove any generated file.
    rake listen   # Listen to your haml/scss
    rake setup    # Setup your environment

---

Make an `assets` folder, and drop your haml and scss files in there. Running `rake care` will compile haml and scss files once and drop the artifacts into the `public` fodler. Run `rake listen` will compile each time you touch the files. Run `rackup` to start a web server running on [localhost:9292](http://localhost:9292).