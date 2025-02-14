def extract_var(name, options) {
  var arg_list = name.split('.'), base = options

  # the -1 here is to make sure we don't capture the last item
  for arg in arg_list {
    var default_return = '%(${name})' # return the original string.

    if !is_dict(base) and !is_list(base) {
      return default_return
    }

    if is_list(base) {
      if !arg.match('/^\d+(\.\d+)?$/') {
        return default_return
      }

      arg = to_number(arg)
      if arg < 0 or !base.length() > arg {
        return default_return
      }
    }

    base = base[arg]
  }

  return base
}

def vars(md, options) {
  def vars(state, silent) {
    var start = state.pos
    var max = state.pos_max
    var found = false, escaped = false

    if state.src[state.pos] != '%' 
      return false
    if state.pos + 1 >= state.src.length() or state.src[state.pos + 1] != '(' 
      return false

    if silent return false
    if start + 1 >= max return false
      
    # honor %% escapes.
    if state.pos > 0 and state.src[state.pos - 1] == '%' {
      state.pos++
      escaped = true
    }

    state.pos = start + 2

    while state.pos < max {
      if state.src[state.pos] == ')' {
        found = true
        break
      }
  
      state.pos++
    }

    if !found or start + 2 >= state.pos {
      state.pos = start
      return false
    }

    var content = state.src[start + 2, state.pos]

    if content.match('/[^a-zA-Z0-9_.]/') {
      state.pos = start
      return false
    }
    
    if escaped {
      state.pending += '(' + content
    } else {
      state.pending += extract_var(content, options)
      state.pos += 1
    }
    return true
  }

  md.inline.ruler.before('text', 'vars', vars, {
    alt: [],
  })
}