import json
import os
import template
import .functions

def flatten_dict(items) {
  return items.reduce(@(data, item, key) {
    data.set(key, item)
    
    var children = item.get('children')
    if children {
      data.extend(flatten_dict(children))
    }

    return data
  }, {})
}

def get_file_list(root_dir, main_root) {
  if os.dir_exists(root_dir) {
    return os.read_dir(root_dir).filter(@(f) { 
      return !f.starts_with('.')
    }).reduce(@(list, file) {
      var full_path = os.join_paths(root_dir, file)
      if os.dir_exists(full_path) {
        list.extend(get_file_list(full_path, main_root))
      } else {
        list.append(full_path[main_root.length(),])
      }
      return list
    }, [])
  }
  return []
}

def init_template(theme_path) {
  var tm = template()
  tm.set_root(theme_path)

  # register functions that can be reused by theme authors.
  tm.register_function('blank', functions.blank)
  tm.register_function('search_text', functions.search_query)

  return tm
}

def get_theme_path(options) {
  var theme_path = os.join_paths(os.cwd(), 'themes', options.theme)
  if !os.dir_exists(theme_path) {
    theme_path = os.join_paths(
      os.dir_name(os.dir_name(__file__)), 
      'themes', options.theme
    )

    if !os.dir_exists(theme_path) {
      raise Exception('Theme "${options.theme}" not found!')
    }
  }

  return theme_path
}
