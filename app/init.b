import os
import json

def new_app(options) {
  var root = options.root, 
      name = options.get('name', os.base_name(options.root))

  # snapshot original root for use in feedback message.
  var the_root = root.trim(), this_dir = os.cwd()
  
  if the_root.starts_with(this_dir) {
    the_root = the_root[this_dir.length(),].ltrim('/').ltrim('\\').trim()
  } else if !the_root.ends_with('/') {
    the_root += '/'
  }

  if !os.dir_exists(root) {
    os.create_dir(root, 0c777, true)
  }

  root = os.real_path(root)

  # create _data directory
  var data_dir = os.join_paths(root, '_data')
  if !os.dir_exists(data_dir) {
    os.create_dir(data_dir, 0c777, true)
  }

  # create configuration file
  var config_file = os.join_paths(data_dir, 'config.json')
  if !file(config_file).exists() {
    file(config_file, 'w').write(json.encode({
      app_name: name,
      search_page: '/search',
      theme: 'default',
    }, false))
  }

  # create sitemap
  var sitemap_file = os.join_paths(data_dir, 'sitemap.json')
  if !file(sitemap_file).exists() {
    file(sitemap_file, 'w').write(json.encode({
      '/': {
        source: 'index',
        title: 'Home'
      },
    }, false))
  }

  # create src directory
  var src_dir = os.join_paths(root, 'src')
  if !os.dir_exists(src_dir) {
    os.create_dir(src_dir, 0c777, true)
  }

  # create sample source file
  var sample_source_file = os.join_paths(src_dir, 'index.md')
  if !file(sample_source_file).exists() {
    file(sample_source_file, 'w').write('# ${name}\n\nThis is a simple demo page to show you the power of Doka.')
  }

  var is_in_current_dir = the_root == '' or the_root == '.' or the_root == './'
  if is_in_current_dir the_root = ''

  if !is_in_current_dir {
    echo 'New Doka project successfully initialized at `${the_root}`.'
  } else {
    echo 'New Doka project successfully initialized at current directory.'
  }
  echo 'Navigate to the directory and run your application using the commands below.'
  echo ''

  if !is_in_current_dir{
    echo '  cd "${the_root}"'
  }

  echo '  doka serve --dev'
  echo ''
  echo 'Modify the file `${the_root}src/index.md` to get started.'
}

def new_theme(name, root) {
  var theme_path = os.join_paths(root, 'themes', name)

  if os.dir_exists(theme_path) {
    die Exception('Theme with same name "${name}" might already be initialized!')
  }

  # create the required directories
  os.create_dir(os.join_paths(theme_path, '_data'), 0c777, true)
  os.create_dir(os.join_paths(theme_path, 'assets'), 0c777, true)

  var empty_html = @(title) {
    return  '<!DOCTYPE html>\n' +
            '<html lang="en">\n' +
            '<head>\n' +
            '  <meta charset="UTF-8">\n' +
            '  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n' +
            '  <title>${title}</title>\n' +
            '  <link rel="stylesheet" href="/style.css">\n' +
            '</head>\n' +
            '<body>\n' +
            '  <h1>{{ config.app_name }}</h1>\n' +
            '  <div>{{ navs.main }}</div>\n' +
            '  <div>{{ page.content }}</div>\n' +
            '</body>\n' +
            '</html>\n'
  }

  # create the reqired files
  file(os.join_paths(theme_path, '_data', 'config.json'), 'w').write('{}')
  file(os.join_paths(theme_path, 'assets', 'style.css'), 'w').write('/* Create your styling here */\n')
  file(os.join_paths(theme_path, '404.html'), 'w').write(empty_html('Not Found'))
  file(os.join_paths(theme_path, 'page.html'), 'w').write(empty_html('{{ page.title }}'))
  file(os.join_paths(theme_path, 'search.html'), 'w').write(empty_html('{{ page.title }}'))

  echo 'New theme "${name}" successfully created at `${theme_path}`.'
}
