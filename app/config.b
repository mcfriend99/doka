import args
import json
import os

def config(this_dir, options) {

  /* # var this_dir = os.cwd()

  # parse cli arguments
  var parser = args.Parser('doka')

  # config file
  parser.add_option('config', 'The site JSON configuration file.', {
    short_name: 'c',
    type: args.STRING,
    # default to `_data/config.json` file
    value: os.join_paths(this_dir, '_data', 'config.json'),
  })

  # port
  parser.add_option('port', 'The port to serve the site on.', {
    short_name: 'p',
    type: args.NUMBER,
    value: 4000,
  })

  # host
  parser.add_option('host', 'The host to serve the site on.', {
    short_name: 'h',
    type: args.STRING,
    value: '127.0.0.1',
  })

  var options =  parser.parse().options */

  # set the default theme
  options.set('theme', 'default')
  # default application name
  options.set('app_name', 'Doka')
  # default homepage title
  options.set('home_title', 'Home')

  # nav configuration
  options.set('nav_class', 'menu-list')
  options.set('nav_item_class', '')
  options.set('nav_link_class', '')
  options.set('nav_section_class', '')
  options.set('active_nav_class', 'is-active')

  var config_file = file(options.config)
  if config_file.exists() {
    var config_content = config_file.read().trim()

    if config_content {
      var decoded = json.decode(config_content)
      if is_dict(decoded) {
        options.extend(decoded)
      } else if decoded {
        die Exception('Invalid config file!')
      }
    }
  }

  # default root is `src` subdirectory of the current working directory
  if !options.get('root') {
    options.set('root', os.join_paths(this_dir, 'src'))
  }

  # default asset directory is `assets` subdirectory of the current working directory
  if !options.get('assets') {
    options.set('assets', os.join_paths(this_dir, 'assets'))
  }
  
  # default output directory is `_site` subdirectory of the current working directory.
  if !options.get('cache') {
    options.set('cache', os.join_paths(this_dir, '_cache'))
  }

  var sitemap_file = file(
    options.get('sitemap', os.join_paths(this_dir, '_data', 'sitemap.json'))
  )
  if !sitemap_file.exists() {
    # unset the sitemap if it does not exist.
    options.set('sitemap', nil)
  } else {
    var sitemap_content = sitemap_file.read().trim()
    var sitemap_exception = Exception('Invalid sitemap at "${sitemap_file.path()}"')

    if sitemap_content {
      options.sitemap = json.decode(sitemap_content)
      if !is_dict(options.sitemap) {
        die sitemap_exception
      }
    } else {
      die sitemap_exception
    }
  }

  var theme = options.get('theme', 'default')
  var theme_config_file = file(
    options.get('${theme}_config', os.join_paths(this_dir, '_data', '${theme}.json'))
  )
  if theme_config_file.exists() {
    var theme_config_content = theme_config_file.read().trim()

    if theme_config_content {
      options.theme_config = json.decode(theme_config_content)
      if !is_dict(options.theme_config) {
        die Exception('Invalid theme configuration file.')
      }
    } else {
      options.theme_config = {}
    }
  } else {
    options.theme_config = {}
  }

  # allow reading doka options configured in Nyssa.
  var nyssa_config = os.join_paths(
    os.dir_name(os.dir_name(__file__)),
    'nyssa.json'
  )
  options.doka = json.decode(file(nyssa_config).read())

  return options
}

