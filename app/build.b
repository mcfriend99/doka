import os
import mime
import .content

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

def create_asset_output(asset, source_dir, output_dir, options) {
  var output_file = os.join_paths(
    output_dir, 
    'assets', 
    asset.replace('/', '_')
  )
  var output_path = os.dir_name(output_file)
  if !os.dir_exists(output_path) {
    os.create_dir(output_path)
  }
  file(os.join_paths(source_dir, asset)).copy(output_file)
  return output_file
}

def build_assets(options, output_dir) {
  var this_assets = get_file_list(options.assets, options.assets)

  var theme_assets_dir = os.join_paths(options.theme_directory, 'assets')
  var theme_assets = get_file_list(theme_assets_dir, theme_assets_dir)

  var map = {}

  for asset in this_assets {
    map[asset] = {
      file: file(create_asset_output(asset, options.assets, output_dir, options)),
      mime: mime.detect_from_name(asset),
    }
  }

  for asset in theme_assets {
    # we won't be builxing overriden asset files.
    if !this_assets.contains(asset) {
      map[asset] = {
        file: file(create_asset_output(asset, theme_assets_dir, output_dir, options)),
        mime: mime.detect_from_name(asset),
      }
    }
  }

  return map
}

def build_endpoints(template, options, output_dir) {
  var map = {}

  for key, value in options.endpoints {
    var template_type = value.get('type', 'page')

    var markdown_file = file(os.join_paths(options.root, value.source + '.md'))
    var html_file = os.join_paths(
      output_dir, 
      'generated', 
      template_type,
      key.replace('/', '_') + '.html'
    )

    var rendered_content = template(
      template_type + '.html',
      content.get_template_vars({path: key}, markdown_file, options)
    )
    
    var output_path = os.dir_name(html_file)
    if !os.dir_exists(output_path) {
      os.create_dir(output_path)
    }
    
    file(html_file, 'w').write(rendered_content)
    map[key] = {
      file: file(html_file),
      mime: 'text/html',
    }
  }

  return map
}

def build_error_page(template, error_code, output_dir, options) {
  var html_file = os.join_paths(
    output_dir, 
    'generated',
    '${error_code}.html'
  )

  var rendered_content = template(
    error_code + '.html',
    content.get_template_vars({path: error_code}, nil, options)
  )
  
  var output_path = os.dir_name(html_file)
  if !os.dir_exists(output_path) {
    os.create_dir(output_path)
  }
  
  file(html_file, 'w').write(rendered_content)

  return {
    file: file(html_file),
    mime: 'text/html',
  }
}

def build(template, options) {
  
  var output_dir = options.cache
  if os.dir_exists(output_dir) {
    os.remove_dir(output_dir, true)
  }
  os.create_dir(output_dir)

  # build sitemap endpoints first so that assets override them. i.e. 
  # if a sitemap shares exactly the same path with an asset, the asset 
  # will be served instead.
  var endpoints = build_endpoints(template, options, output_dir)
  endpoints.extend(build_assets(options, output_dir))

  # build the 404 page.

  return {
    endpoints,
    404: build_error_page(template, 404, output_dir, options)
  }
}
