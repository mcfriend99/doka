import os
import mime
import hash
import .content
import .utils { get_file_list, init_template }
import json

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

def do_asset_build(assets, root, output_dir, options, map) {
  for asset in assets {
    var reader = file(create_asset_output(asset, root, output_dir, options))
    var content = reader.read()

    map[asset] = {
      md: '',
      file: reader.path(),
      title: '',
      headers: {
        'Cache-Control': 'public, max-age=31536000, s-maxage=31536000, immutable', # cache for 1 year
        'Etag': 'W/"${hash.md5(content)}"',
        'Content-Type': mime.detect_from_name(asset),
      },
    }
  }
}

def build_assets(options, output_dir) {
  var this_assets = get_file_list(options.assets, options.assets)

  var theme_assets_dir = os.join_paths(options.theme_directory, 'assets')
  var theme_assets = get_file_list(theme_assets_dir, theme_assets_dir)

  var map = {}

  # build theme assets first to that they can be overwritten by user assets.
  do_asset_build(theme_assets.filter(@(asset) {
    # we won't be building overriden asset files.
    return !this_assets.contains(asset)
  }), theme_assets_dir, output_dir, options, map)

  # the build user assets to allow theme overrides.
  do_asset_build(this_assets, options.assets, output_dir, options, map)

  return map
}

def build_endpoints(template, options, output_dir, target) {
  var map = {}

  for key, value in options.endpoints {
    if target and key != target continue

    var template_type = value.get('type', 'page')

    var markdown_file = file(os.join_paths(options.root, value.source + '.md'))
    var html_file = os.join_paths(
      output_dir, 
      'generated', 
      template_type,
      key.replace('/', '_') + '.html'
    )

    var page = content.get_template_vars({path: key, req: {},}, markdown_file, value, options)
    var rendered_content = template(
      template_type + '.html',
      page
    )
    
    var output_path = os.dir_name(html_file)
    if !os.dir_exists(output_path) {
      os.create_dir(output_path)
    }
    
    file(html_file, 'w').write(rendered_content)

    var reader = file(html_file)
    var content = reader.read()
    map[key] = {
      md: page.page.markdown,
      file: reader.path(),
      title: value.title,
      headers: {},
    }
  }

  return map
}

def build_error_page(template, error_code, output_dir, options) {
  var html_file = os.join_paths(
    output_dir, 
    'errors',
    '${error_code}.html'
  )

  var rendered_content = template(
    error_code + '.html',
    content.get_template_vars({path: error_code}, nil, {}, options)
  )
  
  var output_path = os.dir_name(html_file)
  if !os.dir_exists(output_path) {
    os.create_dir(output_path)
  }
  
  file(html_file, 'w').write(rendered_content)

  var file_handle = file(html_file)
  
  return {
    md: '',
    file: file_handle.path(),
    headers: {},
    title: '',
  }
}

def build(template, options, target) {
  
  var output_dir = options.cache
  if os.dir_exists(output_dir) {
    os.remove_dir(output_dir, true)
  }
  os.create_dir(output_dir)

  # build sitemap endpoints first so that assets override them. i.e. 
  # if a sitemap shares exactly the same path with an asset, the asset 
  # will be served instead.
  var endpoints = build_endpoints(template, options, output_dir, target)
  endpoints.extend(build_assets(options, output_dir))

  # build the 404 page.
  var page_404 = build_error_page(template, 404, output_dir, options)

  var result = {
    endpoints,
    '404': page_404
  }

  if !target {
    file(os.join_paths(output_dir, '_sitemap.json'), 'w').write(json.encode(result, false))
  }

  return result
}

def run(options) {
  echo 'Building Doka project...'
  var tm = init_template(options.theme_directory)
  build(tm.render, options)
  echo 'Doka project successfully built!'
}
