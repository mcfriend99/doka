import .serve
import .build
import .config
import .init

import os
import args

var this_dir = os.cwd()
# default to `_data/config.json` file
var default_config = os.join_paths(this_dir, '_data', 'config.json')

var parser = args.Parser('doka')

# SERVE
parser.add_command('serve', 'Serve your site locally', {
  action: @(options) {
    serve(config(this_dir, options))
  }
}).add_option('config', 'The site JSON configuration file.', {
  short_name: 'c',
  type: args.STRING,
  value: default_config,
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
  action: @(options) {
    build.run(config(this_dir, options))
  }
}).add_option('config', 'The site JSON configuration file.', {
  short_name: 'c',
  type: args.STRING,
  # default to `_data/config.json` file
  value: default_config,
})

# INIT
parser.add_command('init', 'Initializes a new doka project', {
  action: @(options) {
    init.new_app(options)
  }
}).add_option('root', 'The project root directory.', {
  short_name: 'r',
  type: args.STRING,
  value: this_dir,
}).add_option('name', 'The application name - Default: Sample App.', {
  short_name: 'n',
  type: args.STRING,
  value: 'Sample App'
})

# THEME
parser.add_command('add:theme', 'Initializes a new doka theme.', {
  action: @(options) {
    init.new_theme(options.name, this_dir)
  }
}).add_option('name', 'The name of the theme - Default: mynewtheme', {
  short_name: 'n',
  type: args.STRING,
  value: 'mynewtheme'
})

parser.parse()
