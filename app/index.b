import .serve
import .build
import .config

import os
import args

var this_dir = os.cwd()

var parser = args.Parser('doka')

# SERVE
parser.add_command('serve', 'Serve your site locally', {
  short_name: 's',
  action: @(options) {
    serve(config(this_dir, options))
  }
}).add_option('config', 'The site JSON configuration file.', {
  short_name: 'c',
  type: args.STRING,
  # default to `_data/config.json` file
  value: os.join_paths(this_dir, '_data', 'config.json'),
}).add_option('port', 'The port to serve the site on.', {
  short_name: 'p',
  type: args.NUMBER,
  value: 4000,
}).add_option('host', 'The host to serve the site on.', {
  short_name: 'h',
  type: args.STRING,
  value: '127.0.0.1',
}).add_option('dev', 'Serve in dev mode.', {
  short_name: 'd',
})

# BUILD
parser.add_command('build', 'Builds the static site', {
  short_name: 'b',
  action: @(options) {
    build.run(config(this_dir, options))
  }
}).add_option('config', 'The site JSON configuration file.', {
  short_name: 'c',
  type: args.STRING,
  # default to `_data/config.json` file
  value: os.join_paths(this_dir, '_data', 'config.json'),
})

parser.add_command('init', 'Initializes a new doka project', {
  short_name: 'i',
  action: @(options) {}
})

parser.add_command('theme', 'Initializes a new doka theme only project', {
  short_name: 't',
  action: @(options) {}
})

parser.parse()
