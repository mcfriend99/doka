import os
import mime
import hash
import .content
import .utils { get_file_list }

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
      file: reader,
      content: content,
      title: '',
      md: '',
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

    var page = content.get_template_vars({path: key, req: {},}, markdown_file, options)
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
      file: reader,
      content: content,
      md: markdown_file.read(),
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
    content.get_template_vars({path: error_code}, nil, options)
  )
  
  var output_path = os.dir_name(html_file)
  if !os.dir_exists(output_path) {
    os.create_dir(output_path)
  }
  
  file(html_file, 'w').write(rendered_content)

  var file_handle = file(html_file)
  return {
    file: file_handle,
    content: file_handle.read(),
    headers: {},
    title: '',
    md: '',
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
