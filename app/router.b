/* import mime
import os
import .nav
import .content

def router(req, res, config, template) {

  if req.method.upper() == 'GET' {
    # serve assets directly.
    var asset_file = file(os.join_paths(config.assets, config.theme, req.path))
    if asset_file.exists() and !os.is_dir(asset_file.path()) {
      res.set_type(mime.detect_from_name(req.path))
      res.write(asset_file.read())
      return
    }

    # Check for theme asset file as well.
    # 
    # By appearing here, we already allow user to override theme's static files.
    var theme_asset_file = file(os.join_paths(config.theme_directory, 'assets', req.path))
    if theme_asset_file.exists() and !os.is_dir(theme_asset_file.path()) {
      res.set_type(mime.detect_from_name(req.path))
      res.write(theme_asset_file.read())
      return
    }

    var page_source = nav.get_source(config.endpoints, req.path)
    if page_source {
      # serve matching site page
      var markdown_file = file(os.join_paths(config.root, page_source + '.md'))
      if markdown_file.exists() and !os.is_dir(markdown_file.path()) {
        # serve markdown file
        res.write(template(
          'page.html',
          content.get_template_vars(req, markdown_file, config)
        ))
        return
      }
    }
  }

  if(req.method.upper() == 'POST') {
    # handle search requests here...

    # allow the frontend to specify any name for the input in the search form.
    # pick the first input element submitted as the input name.
    # NB: It is already a requirement that, there should only be input in the 
    # request.
    var query_field = req.body.keys()[0]
    var query = req.body.get(query_field)

    # TODO: Complete this once the build cache is active. 
    # We'll be searching from the cache.
  }


  # serve 404.
  res.status = 404
  res.write(
    template('404.html', content.get_template_vars(req, nil, config)) or 
    '404 - Not found'
  )
}
 */