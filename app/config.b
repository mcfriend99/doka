import args
import json
import os
import .utils

def config(this_dir, options) {

  # set the default theme
  options.set('theme', 'default')
  # default application name
  options.set('app_name', 'Doka')
  # default homepage title
  options.set('home_title', 'Home')

  var config_file = file(options.config)
  if config_file.exists() {
    var decoded = json.parse(options.config) or {}
    if is_dict(decoded) {
      options.extend(decoded)
    } else if decoded {
      die Exception('Invalid config file!')
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
    options.sitemap = json.parse(sitemap_file.path()) or {}
    if !is_dict(options.sitemap) {
      die Exception('Invalid sitemap at "${sitemap_file.path()}"')
    }
  }

  var theme = options.get('theme', 'default')
  var theme_config_file = file(
    options.get('${theme}_config', os.join_paths(this_dir, '_data', '${theme}.json'))
  )
  if theme_config_file.exists() {
    options.theme_config = json.parse(theme_config_file.path()) or {}
    if !is_dict(options.theme_config) {
      die Exception('Invalid theme configuration file.')
    }
  } else {
    options.theme_config = {}
  }

  # allow reading doka options configured in Nyssa.
  var nyssa_config = os.join_paths(
    os.dir_name(os.dir_name(__file__)),
    'nyssa.json'
  )
  options.doka = json.parse(nyssa_config)

  # auto-generated options
  options.theme_directory = utils.get_theme_path(options)
  options.endpoints = utils.flatten_dict(options.sitemap)

  return options
}

