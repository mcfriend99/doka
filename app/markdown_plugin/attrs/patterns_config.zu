/**
 * If a pattern matches the token stream,
 * then run transform.
 */

import .utils
import json


def patterns_config() {
  var __hr = '/^ {0,3}[-*_]{3,} ?\{[^\}]/'

  return [
    {
      /**
       * ```python {.cls}
       * for i in range(10):
       *     print(i)
       * ```
       */
      name: 'fenced code blocks',
      tests: [
        {
          shift: 0,
          block: true,
          info: utils.hasDelimiters('end')
        }
      ],
      transform: @(tokens, i, _) {
        var token = tokens[i]
        var start = utils.last_index_of(token.info, '{')
        var attrs = utils.getAttrs(token.info, start)
        utils.addAttrs(attrs, token)
        token.info = utils.removeDelimiter(token.info)
      }
    }, 
    {
      /**
       * bla `click()`{.c} ![](img.png){.d}
       *
       * differs from 'inline attributes' as it does
       * not have a closing tag (nesting: -1)
       */
      name: 'inline nesting 0',
      tests: [
        {
          shift: 0,
          type: 'inline',
          children: [
            {
              shift: -1,
              type: @(str) {
                return str == 'image' or str == 'code_inline'
              }
            }, 
            {
              shift: 0,
              type: 'text',
              content: utils.hasDelimiters('start')
            }
          ]
        }
      ],

      /**
       * @param {!number} j
       */
      transform: @(tokens, i, j) {
        var token = tokens[i].children[j]
        var endChar = token.content.index_of('}')
        var attrToken = tokens[i].children[j - 1]
        var attrs = utils.getAttrs(token.content, 0)
        utils.addAttrs(attrs, attrToken)
        if token.content.length() == (endChar + 1) {
          tokens[i].children.remove_at(j)
        } else {
          token.content = token.content[endChar + 1]
        }
      }
    }, 
    {
      /**
       * | h1 |
       * | -- |
       * | c1 |
       *
       * {.c}
       */
      name: 'tables',
      tests: [
        {
          # var this token be i, such that for-loop continues at
          # next token after tokens.splice
          shift: 0,
          type: 'table_close'
        }, 
        {
          shift: 1,
          type: 'paragraph_open'
        }, 
        {
          shift: 2,
          type: 'inline',
          content: utils.hasDelimiters('only')
        }
      ],
      transform: @(tokens, i, _) {
        var token = tokens[i + 2]
        var tableOpen = utils.getMatchingOpeningToken(tokens, i)
        var attrs = utils.getAttrs(token.content, 0)
        # add attributes
        utils.addAttrs(attrs, tableOpen)
        # remove <p>{.c}</p>
        (0..3).loop(@{
          tokens.remove_at(i + 1)
        })
      }
    }, 
    {
      /**
       * | A | B |
       * | -- | -- |
       * | 1 | 2 |
       *
       * | C | D |
       * | -- | -- |
       *
       * only `| A | B |` sets the colsnum metadata
       */
      name: 'tables thead metadata',
      tests: [
        {
          shift: 0,
          type: 'tr_close',
        }, 
        {
          shift: 1,
          type: 'thead_close'
        }, 
        {
          shift: 2,
          type: 'tbody_open'
        }
      ],
      transform: @(tokens, i, _) {
        var tr = utils.getMatchingOpeningToken(tokens, i)
        var th = tokens[i - 1]
        var colsnum = 0
        var n = i
        while n-- and n > 0 {
          if tokens[n] == tr {
            tokens[n - 1].meta = tokens[n + 2].meta ? tokens[n + 2].meta.clone() : {}
            tokens[n - 1].meta.extend({ colsnum })
            break
          }
          colsnum += to_number(tokens[n].level == th.level and tokens[n].type == th.type) >> 0
        }

        tokens[i + 2].meta = tokens[i + 2].meta ? tokens[i + 2].meta.clone() : {}
        tokens[i + 2].meta.extend({ colsnum })
      }
    }, 
    {
      /**
       * | A | B | C | D |
       * | -- | -- | -- | -- |
       * | 1 | 11 | 111 | 1111 {rowspan=3} |
       * | 2 {colspan=2 rowspan=2} | 22 | 222 | 2222 |
       * | 3 | 33 | 333 | 3333 |
       */
      name: 'tables tbody calculate',
      tests: [
        {
          shift: 0,
          type: 'tbody_close',
          hidden: false
        }
      ],
      /**
       * @param {number} i index of the tbody ending
       */
      transform: @(tokens, i, _) {
        /** index of the tbody beginning */
        var idx = i - 2
        while (idx > 0 and 'tbody_open' != tokens[idx--].type){}

        var calc = tokens[idx].meta.colsnum >> 0
        if calc < 2 { 
          return 
        }

        var level = tokens[i].level + 2
        iter var n = idx; n < i; n++ {
          if tokens[n].level > level { 
            continue 
          }

          var token = tokens[n]
          var rows = token.hidden ? 0 : to_number(token.attr_get('rowspan') or '0') >> 0
          var cols = token.hidden ? 0 : to_number(token.attr_get('colspan') or '0') >> 0

          if rows > 1 {
            var colsnum = calc - (cols > 0 ? cols : 1)

            iter var k = n, num = rows; k < i and num > 1; k++ {
              if 'tr_open' == tokens[k].type {
                tokens[k].meta = tokens[k].meta ? tokens[k].meta.clone() : {}
                if tokens[k].meta and tokens[k].meta.colsnum {
                  colsnum -= 1
                }

                tokens[k].meta.colsnum = colsnum
                num--
              }
            }
          }

          if 'tr_open' == token.type and token.meta and token.meta.colsnum {
            var max = token.meta.colsnum
            iter var k = n, num = 0; k < i; k++ {
              if 'td_open' == tokens[k].type {
                num += 1
              } else if 'tr_close' == tokens[k].type {
                break
              }

              # automatically populate token[k].hidden if its not yet 
              # populated when num > max.
              num > max and (tokens[k].hidden or hidden(tokens[k]))
            }
          }

          if cols > 1 {
            /** @type {number[]} index of one row's children */
            var one = []
            /** last index of the row's children */
            var end = n + 3
            /** number of the row's children */
            var num = calc

            iter var k = n; k > idx; k-- {
              if 'tr_open' == tokens[k].type {
                num = tokens[k].meta and tokens[k].meta.colsnum or num
                break
              } else if 'td_open' == tokens[k].type {
                one.insert(k, 0)
              }
            }

            iter var k = n + 2; k < i; k++ {
              if 'tr_close' == tokens[k].type {
                end = k
                break
              } else if 'td_open' == tokens[k].type {
                one.append(k)
              }
            }

            var off = one.index_of(n)
            var real = num - off
            real = min(real, cols)
            cols > real and token.attr_set('colspan', real + '')

            var one_slice = num + 1 - calc - real
            iter var k = one[one_slice >= 0 ? one_slice : one.length() + one_slice,][0]; k < end; k++ {
              tokens[k].hidden or hidden(tokens[k])
            }
          }
        }
      }
    }, 
    {
      /**
       * *emphasis*{.with attrs=1}
       */
      name: 'inline attributes',
      tests: [
        {
          shift: 0,
          type: 'inline',
          children: [
            {
              shift: -1,
              nesting: -1  # closing inline tag, </em>{.a}
            }, 
            {
              shift: 0,
              type: 'text',
              content: utils.hasDelimiters('start')
            }
          ]
        }
      ],
      /**
       * @param {!number} j
       */
      transform: @(tokens, i, j) {
        var token = tokens[i].children[j]
        var content = token.content
        var attrs = utils.getAttrs(content, 0)
        var openingToken = utils.getMatchingOpeningToken(tokens[i].children, j - 1)
        utils.addAttrs(attrs, openingToken)
        token.content = content[content.index_of('}') + 1,]
      }
    }, 
    {
      /**
       * - item
       * {.a}
       */
      name: 'list softbreak',
      tests: [
        {
          shift: -2,
          type: 'list_item_open'
        }, 
        {
          shift: 0,
          type: 'inline',
          children: [
            {
              position: -2,
              type: 'softbreak'
            }, 
            {
              position: -1,
              type: 'text',
              content: utils.hasDelimiters('only')
            }
          ]
        }
      ],
      /**
       * @param {!number} j
       */
      transform: @(tokens, i, j) {
        var token = tokens[i].children[j]
        var content = token.content
        var attrs = utils.getAttrs(content, 0)
        var ii = i - 2
        while (ii - 1 >= 0 and tokens[ii - 1] and
          tokens[ii - 1].type != 'ordered_list_open' and
          tokens[ii - 1].type != 'bullet_list_open') { ii--; }
        utils.addAttrs(attrs, tokens[ii - 1])
        tokens[i].children = tokens[i].children[,-2]
      }
    }, 
    {
      /**
       * - nested list
       *   - with double \n
       *   {.a} <-- apply to nested ul
       *
       * {.b} <-- apply to root <ul>
       */
      name: 'list double softbreak',
      tests: [
        {
          # var this token be i = 0 so that we can erase
          # the <p>{.a}</p> tokens below
          shift: 0,
          type: @(str) {
            return str == 'bullet_list_close' or str == 'ordered_list_close'
          }
        }, 
        {
          shift: 1,
          type: 'paragraph_open'
        }, 
        {
          shift: 2,
          type: 'inline',
          content: utils.hasDelimiters('only'),
          children: @(arr) { return arr.length() == 1 }
        }, 
        {
          shift: 3,
          type: 'paragraph_close'
        }
      ],
      transform: @(tokens, i, _) {
        var token = tokens[i + 2]
        var content = token.content
        var attrs = utils.getAttrs(content, 0)
        var openingToken = utils.getMatchingOpeningToken(tokens, i)
        utils.addAttrs(attrs, openingToken)
        (0..3).loop(@{
          tokens.remove_at(i + 1)
        })
      }
    }, 
    {
      /**
       * - end of {.list-item}
       */
      name: 'list item end',
      tests: [
        {
          shift: -2,
          type: 'list_item_open'
        }, 
        {
          shift: 0,
          type: 'inline',
          children: [
            {
              position: -1,
              type: 'text',
              content: utils.hasDelimiters('end')
            }
          ]
        }
      ],
      /**
       * @param {!number} j
       */
      transform: @(tokens, i, j) {
        var token = tokens[i].children[j]
        var content = token.content
        var attrs = utils.getAttrs(content, utils.last_index_of(content, '{'))
        utils.addAttrs(attrs, tokens[i - 2])
        var trimmed = content[,utils.last_index_of(content, '{')]
        token.content = trimmed[-1] != ' ' ? trimmed : trimmed[,-1]
      }
    }, 
    {
      /**
       * something with softbreak
       * {.cls}
       */
      name: '\n{.a} softbreak then curly in start',
      tests: [
        {
          shift: 0,
          type: 'inline',
          children: [
            {
              position: -2,
              type: 'softbreak'
            }, 
            {
              position: -1,
              type: 'text',
              content: utils.hasDelimiters('only')
            }
          ]
        }
      ],
      /**
       * @param {!number} j
       */
      transform: @(tokens, i, j) {
        var token = tokens[i].children[j]
        var attrs = utils.getAttrs(token.content, 0)
        # find last closing tag
        var ii = i + 1
        while (tokens.get(ii + 1) and tokens[ii + 1].nesting == -1) { ii++; }
        var openingToken = utils.getMatchingOpeningToken(tokens, ii)
        utils.addAttrs(attrs, openingToken)
        tokens[i].children = tokens[i].children[,-2]
      }
    }, 
    {
      /**
       * horizontal rule --- {#id}
       */
      name: 'horizontal rule',
      tests: [
        {
          shift: 0,
          type: 'paragraph_open'
        },
        {
          shift: 1,
          type: 'inline',
          children: @(arr) { return arr.length() == 1 },
          content: @(str) { return str.match(__hr) != false },
        },
        {
          shift: 2,
          type: 'paragraph_close'
        }
      ],
      transform: @(tokens, i, _) {
        var token = tokens[i]
        token.type = 'hr'
        token.tag = 'hr'
        token.nesting = 0
        var content = tokens[i + 1].content
        var start = utils.last_index_of(content, '{')
        var attrs = utils.getAttrs(content, start)
        utils.addAttrs(attrs, token)
        token.markup = content
        (0..2).loop(@{
          tokens.remove_at(i + 1)
        })
      }
    }, 
    {
      /**
       * end of {.block}
       */
      name: 'end of block',
      tests: [
        {
          shift: 0,
          type: 'inline',
          children: [
            {
              position: -1,
              content: utils.hasDelimiters('end'),
              type: @(t) { return t != 'code_inline' and t != 'math_inline' }
            }
          ]
        }
      ],
      /**
       * @param {!number} j
       */
      transform: @(tokens, i, j) {
        var token = tokens[i].children[j]
        var content = token.content
        var attrs = utils.getAttrs(content, utils.last_index_of(content, '{'))
        var ii = i + 1
        do {
          if tokens[ii] and tokens[ii].nesting == -1 { 
            break; 
          }
        } while ii++ - 1 < tokens.length()
        var openingToken = utils.getMatchingOpeningToken(tokens, ii)
        utils.addAttrs(attrs, openingToken)
        var trimmed = content[0, utils.last_index_of(content, '{')]
        token.content = !trimmed or trimmed[-1] != ' ' ? trimmed : trimmed[,-1]
      }
    }
  ]
}

/**
 * Hidden table's cells and them inline children,
 * specially cast inline's content as empty
 * to prevent that escapes the table's box model
 * 
 * @see https://github.com/markdown-it/markdown-it/issues/639
 * @param {import('.').Token} token
 */
def hidden(token) {
  token.hidden = true
  token.children and token.children.each(@(t) {
    t.content = ''
    hidden(t)
  })
}
