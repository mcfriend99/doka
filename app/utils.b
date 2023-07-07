import json
import os

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
