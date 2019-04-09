# mruby-sftp-glob [![Build Status](https://travis-ci.com/appPlant/mruby-sftp-glob.svg?branch=master)](https://travis-ci.com/appPlant/mruby-sftp-glob) [![Build status](https://ci.appveyor.com/api/projects/status/28xa5098sup264pr/branch/master?svg=true)](https://ci.appveyor.com/project/katzer/mruby-sftp-glob/branch/master)

Extension for [mruby-sftp][mruby-sftp] to match (possibly recursively) all directory entries against pattern.

```ruby
SFTP.start('test.rebex.net', 'demo', password: 'password') do |sftp|
  sftp.dir.glob('lib/*.rb') do |entry|
    puts entry.name
  end
end
```

## Installation

Add the line below to your `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
  # ... (snip) ...
  conf.gem 'mruby-sftp-glob'
end
```

Or add this line to your aplication's `mrbgem.rake`:

```ruby
MRuby::Gem::Specification.new('your-mrbgem') do |spec|
  # ... (snip) ...
  spec.add_dependency 'mruby-sftp-glob'
end
```

## Development

Clone the repo:
    
    $ git clone https://github.com/appplant/mruby-sftp-glob.git && cd mruby-sftp-glob/

Compile the source:

    $ rake compile

Run the tests:

    $ rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/appplant/mruby-sftp-glob.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

- Sebastián Katzer, Fa. appPlant GmbH

## License

The mgem is available as open source under the terms of the [MIT License][license].

Made with :yum: in Leipzig

© 2018 [appPlant GmbH][appplant]

[mruby-sftp]: https://github.com/katzer/mruby-sftp
[license]: http://opensource.org/licenses/MIT
[appplant]: www.appplant.de
