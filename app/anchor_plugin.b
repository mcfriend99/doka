import url

def slugify(s) {
  return url.encode(to_string(s).trim().case_fold().replace('/\s+/', '-'))
}

var tokens_filter = ['text', 'code_inline']

def get_tokens_text(tokens) {
  return ''.join(
    tokens.
      filter(@(t) { return tokens_filter.contains(t.type) }).
      map(@(t) { return t.content })
  )
}

def unique_slug(slug, slugs, start_index) {
  var uniq = slug
  var i = start_index

  while slugs.contains(uniq) {
    uniq = '${slug}-${i}'
    i++
  }

  slugs[uniq] = true
  return uniq
}

var default_options = {
  level: 1,
  slugify,
  unique_slug_start: 1,
  tab_index: '-1',
  get_tokens_text,
}

var is_level_selected_number = @(selection) { return @(level) { return level >= selection } }
var is_level_selected_array = @(selection) { return @(level) { return selection.contains(level) }  }

def anchor_plugin(md, options) {
  var opts = default_options.clone()
  if options opts.extend(options)

  md.core.ruler.push('anchor', @(state) {
    var slugs = {}
    var tokens = state.tokens

    var is_level_selected = is_list(opts.level) ?
      is_level_selected_array(opts.level) :
      is_level_selected_number(opts.level)

    iter var idx = 0; idx < tokens.length(); idx++ {
      var token = tokens[idx]

      if token.type != 'heading_open' {
        continue
      }

      if !is_level_selected(to_number(token.tag[1,])) {
        continue
      }

      # Aggregate the next token children text.
      var title = opts.get_tokens_text(tokens[idx + 1].children)

      var slug = token.attr_get('id')

      if slug == nil {
        slug = unique_slug(opts.slugify(title), slugs, opts.unique_slug_start)
      } else {
        slug = unique_slug(slug, slugs, opts.unique_slug_start)
      }

      token.attr_set('id', slug)
      
      if opts.tab_index != false {
        token.attr_set('tabindex', '${opts.tab_index}')
      }

      # A permalink renderer could modify the `tokens` array so
      # make sure to get the up-to-date index on each iteration.
      idx = tokens.index_of(token)
    }
  })
}
