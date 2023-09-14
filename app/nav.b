import .utils

def get_from_sitemap(sitemap, path, name) {
  var entry = sitemap.get(path)
  if entry {
    return entry[name]
  }
  return ''
}

def get_nth_endpoint(sitemap, path, index) {
  var keys = sitemap.keys()
  var current_index = keys.index_of(path)

  if current_index > -1 {
    var required_index = current_index + index
    if required_index >= 0 and required_index < keys.length() {
      var map_key = keys[required_index]
      var map = sitemap[map_key]
      map.link = map_key
      return map
    }
  }

  return nil
}

def get_title(sitemap, path) {
  return get_from_sitemap(sitemap, path, 'title')
}

def get_source(sitemap, path) {
  return get_from_sitemap(sitemap, path, 'source')
}

def create_navigation(data, current_path, config) {
  var ul_class = config.theme_config.get('nav_class', '')
  var li_class = config.theme_config.get('nav_item_class', '')
  var a_class = config.theme_config.get('nav_link_class', '')
  var section_class = config.theme_config.get('nav_section_class', '')
  var active_class = config.theme_config.get('active_nav_class', '')

  var result = '<ul class="${ul_class}">'

  for path, www in data {
    if path == current_path {
      result += '<li class="${li_class} ${active_class}">'
    } else {
      result += '<li class="${li_class}">'
    }

    var children = www.get('children', nil)
    var href = www.source ? ' href="${path}"' : ''
    
    if children {
      result += '<a class="${a_class}"${href}>${www.get("title")}</a>'

      result += create_navigation(children, current_path, config)
    } else {
      result += '<a class="${a_class}"${href}>${www.get("title")}</a>'
    }

    result += '</li>'
  }

  return result + '</ul>'
}

def create_subnav(sitemap, path, config) {
  var map = sitemap.get(path)
  if map {
    # if it's an index.md or index.markdown file...
    if map.source.split('/')[-1].lower() == 'index' {
      map = map.get('children')
      if map {
        return create_navigation(map, path, config)
      }
    }
  }

  return nil
}
