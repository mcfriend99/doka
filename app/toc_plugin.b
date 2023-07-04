# Based on https://github.com/nagaozen/markdown-it-toc-done-right
# 
# MIT License

# Copyright (c) 2018 Fabio Zendhi Nagao

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


import url
import json

def slugify(x) {
  return url.encode(to_string(x).trim().lower().replace('/\s+/', '-'))
}

def htmlencode(x) {
  return to_string(x).replace('/&/', '&amp;').
                      replace('/"/', '&quot;').
                      replace('/\'/', '&#39;').
                      replace('/</', '&lt;').
                      replace('/>/', '&gt;')
}

def toc_plugin(md, opts) {
  if !opts opts = []
  var options = {
    placeholder: '(\\\$\{toc\}|\[\[?_?toc_?\]?\]|\\\$\<toc(\{[^}]*\})\>)',
    slugify,
    unique_slug_start_index: 1,
    container_class: 'table-of-contents',
    container_id: nil,
    list_class: nil,
    item_class: nil,
    link_class: nil,
    level: 1,
    list_type: 'ul',
    format: nil,
    callback: nil/* @(html, ast) {} */
  }

  options.extend(opts.get(0) or {})

  var ast
  var pattern = '/^' + options.placeholder + '$/i'

  def toc(state, start_line, end_line, silent) {
    var token
    var pos = state.b_marks[start_line] + state.t_shift[start_line]
    var max = state.e_marks[start_line]

    # use whitespace as a line tokenizer and extract the first token
    # to test against the placeholder anchored pattern, rejecting if false
    var line_first_token = max > pos ?  state.src[pos, max].split(' ')[0] : ''
    var match = line_first_token.match(pattern)

    if !match or silent return false

    var inline_options = {}
    if match.length() == 3 {
      inline_options = json.decode(match[2])
    }

    state.line = start_line + 1

    token = state.push('toc_open', 'nav', 1)
    token.markup = ''
    token.map = [start_line, state.line]
    token.inline_options = inline_options

    token = state.push('toc_body', '', 0)
    token.markup = ''
    token.map = [start_line, state.line]
    token.inline_options = inline_options
    token.children = []

    token = state.push('toc_close', 'nav', -1)
    token.markup = ''

    return true
  }

  md.renderer.rules.toc_open = @(tokens, idx, options_, env, renderer) {
    var _options = options.clone()

    if tokens and idx >= 0 {
      var token = tokens[idx]
      _options.extend(token.inline_options)
    }

    var id = _options.container_id ? ' id="${htmlencode(_options.container_id)}"' : ''
    return '<nav${id} class="${htmlencode(_options.container_class)}">'
  }

  md.renderer.rules.toc_close = @(tokens, idx, options_, env, renderer) {
    return '</nav>'
  }

  md.renderer.rules.toc_body = @(tokens, idx, options_, env, renderer) {
    var _options = options.clone()
    if tokens and idx >= 0 {
      var token = tokens[idx]
      _options.extend(token.inline_options)
    }

    var uniques = {}
    def unique(s) {
      var u = s
      var i = _options.unique_slug_start_index
      while uniques.contains(u) u = '${s}-${i++}'
      uniques[u] = true
      return u
    }

    var is_level_selected_number = @(selection) { return @(level) { return level >= selection } }
    var is_level_selected_array = @(selection) { return @(level) { return selection.contains(level) }  }

    var is_level_selected = is_list(_options.level) ?
      is_level_selected_array(_options.level) :
      is_level_selected_number(_options.level)

    def ast2html(tree) {
      var list_class = _options.list_class ? ' class="${htmlencode(_options.list_class)}"' : ''
      var item_class = _options.item_class ? ' class="${htmlencode(_options.item_class)}"' : ''
      var link_class = _options.link_class ? ' class="${htmlencode(_options.link_class)}"' : ''

      if tree.c.length == 0 return ''

      var buffer = ''
      if tree.l == 0 or is_level_selected(tree.l) {
        buffer += ('<${htmlencode(_options.list_type) + list_class}>')
      }
      tree.c.each(@(node) {
        if is_level_selected(node.l) {
          buffer += ('<li${item_class}><a${link_class} href="#${unique(options.slugify(node.n))}">${is_function(_options.format) ? _options.format(node.n, htmlencode) : htmlencode(node.n)}</a>${ast2html(node)}</li>')
        } else {
          buffer += ast2html(node)
        }
      })
      if tree.l == 0 or is_level_selected(tree.l) {
        buffer += '</${htmlencode(_options.list_type)}>'
      }
      return buffer
    }

    return ast2html(ast)
  }

  def headings2ast(tokens) {
    var ast = { l: 0, n: '', c: [] }
    var stack = [ast]

    var i = 0
    iter var i_k = tokens.length(); i < i_k; i++ {
      var token = tokens[i]
      if token.type == 'heading_open' {

        var key = tokens[i + 1].children.filter(@(token) {
          return token.type == 'text' or token.type == 'code_inline'
        }).reduce(@(s, t) {
          return s + t.content
        }, '')

        var node = {
          l: to_number(token.tag[1,]),
          n: key,
          c: []
        }

        if node.l > stack[0].l {
          stack[0].c.append(node)
          stack.insert(node, 0)
        } else if node.l == stack[0].l {
          stack[1].c.append(node)
          stack[0] = node
        } else {
          while node.l <= stack[0].l stack.shift()
          stack[0].c.append(node)
          stack.insert(node, 0)
        }
      }
    }

    return ast
  }

  md.core.ruler.push('generate_toc_ast', @(state) {
    var tokens = state.tokens
    ast = headings2ast(tokens)

    if is_function(options.callback) {
      options.callback(
        md.renderer.rules.toc_open() + md.renderer.rules.toc_body() + md.renderer.rules.toc_close(),
        ast
      )
    }
  })

  md.block.ruler.before('heading', 'toc', toc, {
    alt: ['paragraph', 'reference', 'blockquote']
  })
}
