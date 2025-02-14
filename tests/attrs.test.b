import markdown
import markdown.common.utils as md_utils
import ..app.markdown_plugin.attrs
import ..app.markdown_plugin.attrs.utils

var md = markdown().use(attrs)

describe('markdown attrs init', @{
  it('should not throw when getting initializex', @{
    var md = markdown().use(attrs)
    var src = 'text {.someclass #someid attr=allowed}\n'
    var expected = '<p class="someclass" id="someid" attr="allowed">text</p>\n'
    expect(md.render(src)).to_be(expected)
  })
})

describe('markdown attrs utils', @{
  it('should parse {.class ..css-module #id key=val .class.with.dot}', @{
    var src = '{.red ..mod #head key=val .class.with.dot}'
    var expected = [['class', 'red'], ['css-module', 'mod'], ['id', 'head'], ['key', 'val'], ['class', 'class.with.dot']]
    expect(utils.getAttrs(src, 0)).to_be(expected)
  })

  it('should parse attributes whose are ignored the key chars(\\t,\\n,\\f,\\s,/,>,",\',=) eg: {gt>=true slash/=trace i\\td "q\\fnu e\'r\\ny"=}', @{
    var src = '{gt>=true slash/=trace i\td "q\fu\ne\'r\ny"=}'
    var expected = [['gt', 'true'], ['slash', 'trace'], ['id', ''], ['query', '']]
    expect(utils.getAttrs(src, 0)).to_be(expected)
  })

  it('should throw an error while calling `hasDelimiters` with an invalid `where` param', @{
    expect(@{ return utils.hasDelimiters(0) }).to_throw()
    expect(@{ return utils.hasDelimiters('') }).to_throw()
    expect(@{ return utils.hasDelimiters(nil) }).to_throw()
    expect(@{ return utils.hasDelimiters() }).to_throw()
    expect(@{ return utils.hasDelimiters('center')('has {#test} delimiters') }).to_throw()
  })

  it('should escape html entities(&,<,>,") eg: <a href="?a&b">TOC</a>', @{
    var src = '<a href="a&b">TOC</a>'
    var expected = '&lt;a href=&quot;a&amp;b&quot;&gt;TOC&lt;/a&gt;'
    expect(md_utils.escape_html(src)).to_be(expected)
  })

  it('should keep the original input which is not contains(&,<,>,") char(s) eg: |a|b|', @{
    var src = '|a|b|'
    var expected = '|a|b|'
    expect(md_utils.escape_html(src)).to_be(expected)
  })
})

describe('markdown attrs render', @{
  var src, expected

  it('should add attributes when {} in end of last inline', @{
    src = 'some text {with=attrs}'
    expected = '<p with="attrs">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not add attributes when it has too many delimiters {{}}', @{
    src = 'some text {{with=attrs}}'
    expected = '<p>some text {{with=attrs}}</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add attributes when {} in last line', @{
    src = 'some text\n{with=attrs}'
    expected = '<p with="attrs">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add classes with {.class} dot notation', @{
    src = 'some text {.green}'
    expected = '<p class="green">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add css-modules with {..css-module} double dot notation', @{
    src = 'some text {..green}'
    expected = '<p css-module="green">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add identifiers with {#id} hashtag notation', @{
    src = 'some text {#section2}'
    expected = '<p id="section2">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support classes, css-modules, identifiers and attributes in same {}', @{
    src = 'some text {attr=lorem .class ..css-module #id}'
    expected = '<p attr="lorem" class="class" css-module="css-module" id="id">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support attributes inside " {attr="lorem ipsum"}', @{
    src = 'some text {attr="lorem ipsum"}'
    expected = '<p attr="lorem ipsum">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add classes in same class attribute {.c1 .c2} -> class="c1 c2"', @{
    src = 'some text {.c1 .c2}'
    expected = '<p class="c1 c2">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add css-modules in same css-modules attribute {..c1 ..c2} -> css-module="c1 c2"', @{
    src = 'some text {..c1 ..c2}'
    expected = '<p css-module="c1 c2">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add nested css-modules {..c1.c2} -> css-module="c1.c2"', @{
    src = 'some text {..c1.c2}'
    expected = '<p css-module="c1.c2">some text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support empty inline tokens', @{
    src = ' 1 | 2 \n --|-- \n a | '
    expect(@{ md.render(src) }).not().to_throw()  # should not crash / throw error
  })

  it('should add classes to inline elements', @{
    src = 'paragraph **bold**{.red} asdf'
    expected = '<p>paragraph <strong class="red">bold</strong> asdf</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not add classes to inline elements with too many {{}}', @{
    src = 'paragraph **bold**{{.red}} asdf'
    expected = '<p>paragraph <strong>bold</strong>{{.red}} asdf</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should only remove last {}', @{
    src = '{{.red}'
    expected = '<p class="red">{</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add classes for list items', @{
    src = '- item 1{.red}\n- item 2'
    expected = '<ul>\n'
    expected += '<li class="red">item 1</li>\n'
    expected += '<li>item 2</li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add classes in nested lists', @{
    src =  '- item 1{.a}\n'
    src += '  - nested item {.b}\n'
    src += '  {.c}\n'
    src += '    1. nested nested item {.d}\n'
    src += '    {.e}\n'
    # Adding class to top ul not supported
    #    src += '{.f}'
    #    expected = '<ul class="f">\n'
    expected = '<ul>\n'
    expected += '<li class="a">item 1\n'
    expected += '<ul class="c">\n'
    expected += '<li class="b">nested item\n'
    expected += '<ol class="e">\n'
    expected += '<li class="d">nested nested item</li>\n'
    expected += '</ol>\n'
    expected += '</li>\n'
    expected += '</ul>\n'
    expected += '</li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should work with nested inline elements', @{
    src = '- **bold *italics*{.blue}**{.green}'
    expected = '<ul>\n'
    expected += '<li><strong class="green">bold <em class="blue">italics</em></strong></li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add class to inline code block', @{
    src = 'bla `click()`{.c}'
    expected = '<p>bla <code class="c">click()</code></p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not trim unrelated white space', @{
    src = '- **bold** text {.red}'
    expected = '<ul>\n'
    expected += '<li class="red"><strong>bold</strong> text</li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not create empty attributes', @{
    src = 'text { .red }'
    expected = '<p class="red">text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add attributes to ul when below last bullet point', @{
    src = '- item1\n- item2\n{.red}'
    expected = '<ul class="red">\n<li>item1</li>\n<li>item2</li>\n</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add classes for both last list item and ul', @{
    src = '- item{.red}\n{.blue}'
    expected = '<ul class="blue">\n'
    expected += '<li class="red">item</li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should add class ul after a "softbreak"', @{
    src = '- item\n{.blue}'
    expected = '<ul class="blue">\n'
    expected += '<li>item</li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should ignore non-text "attr-like" text after a "softbreak"', @{
    src = '- item\n*{.blue}*'
    expected = '<ul>\n'
    expected += '<li>item\n<em>{.blue}</em></li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should work with ordered lists', @{
    src = '1. item\n{.blue}'
    expected = '<ol class="blue">\n'
    expected += '<li>item</li>\n'
    expected += '</ol>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should work with typography enabled', @{
    src = 'text {key="val with spaces"}'
    expected = '<p key="val with spaces">text</p>\n'
    var res = md.set({ typographer: true }).render(src)
    expect(res).to_be(expected)
  })

  it('should support code blocks', @{
    src = '```{.c a=1 #ii}\nfor i in range(10):\n```'
    expected = '<pre><code class="c" a="1" id="ii">for i in range(10):\n</code></pre>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support code blocks with language defined', @{
    src = '```python {.c a=1 #ii}\nfor i in range(10):\n```'
    expected = '<pre><code class="c language-python" a="1" id="ii">for i in range(10):\n</code></pre>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support blockquotes', @{
    src = '> quote\n{.c}'
    expected = '<blockquote class="c">\n<p>quote</p>\n</blockquote>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support tables', @{
    src = '| h1 | h2 |\n'
    src += '| -- | -- |\n'
    src += '| c1 | c1 |\n'
    src += '\n'
    src += '{.c}'
    expected = '<table class="c">\n'
    expected += '<thead>\n'
    expected += '<tr>\n'
    expected += '<th>h1</th>\n'
    expected += '<th>h2</th>\n'
    expected += '</tr>\n'
    expected += '</thead>\n'
    expected += '<tbody>\n'
    expected += '<tr>\n'
    expected += '<td>c1</td>\n'
    expected += '<td>c1</td>\n'
    expected += '</tr>\n'
    expected += '</tbody>\n'
    expected += '</table>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should apply attributes to the last column of tables', @{
    src = '| title | title {.title-primar} |\n'
    src += '| :---: | :---: |\n'
    src += '| text | text {.text-primar} |\n'
    src += '| text {.text-primary} | text |\n'
    src += '\n'
    src += '{.c}'
    expected = '<table class="c">\n'
    expected += '<thead>\n'
    expected += '<tr>\n'
    expected += '<th style="text-align:center">title</th>\n'
    expected += '<th style="text-align:center" class="title-primar">title</th>\n'
    expected += '</tr>\n'
    expected += '</thead>\n'
    expected += '<tbody>\n'
    expected += '<tr>\n'
    expected += '<td style="text-align:center">text</td>\n'
    expected += '<td style="text-align:center" class="text-primar">text</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td style="text-align:center" class="text-primary">text</td>\n'
    expected += '<td style="text-align:center">text</td>\n'
    expected += '</tr>\n'
    expected += '</tbody>\n'
    expected += '</table>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should calculate table\'s colspan and/or rowspan', @{
    src = '| A | B | C | D |\n'
    src += '| -- | -- | -- | -- |\n'
    src += '| 1 | 11 | 111 | 1111 {rowspan=3} |\n'
    src += '| 2 {colspan=2 rowspan=2} | 22 | 222 | 2222 |\n'
    src += '| 3 | 33 | 333 | 3333 |\n'
    src += '\n'
    src += '{border=1}\n'
    src += '| A |\n'
    src += '| -- |\n'
    src += '| 1 {colspan=3}|\n'
    src += '| 2 |\n'
    src += '| 3 |\n'
    src += '\n'
    src += '{border=2}\n'
    src += '| A | B | C |\n'
    src += '| -- | -- | -- |\n'
    src += '| 1 {rowspan=2}| 11 | 111 |\n'
    src += '| 2 {rowspan=2}| 22 | 222 |\n'
    src += '| 3 | 33 | 333 |\n'
    src += '\n'
    src += '{border=3}\n'
    src += '| A | B | C | D |\n'
    src += '| -- | -- | -- | -- |\n'
    src += '| 1 {colspan=2}| 11 {colspan=3} | 111| 1111 |\n'
    src += '| 2 {rowspan=2} | 22 {colspan=2} | 222 | 2222 |\n'
    src += '| 3 | 33 {colspan=4} | 333 | 3333 |\n'
    src += '\n'
    src += '{border=4}'

    expected = '<table border="1">\n'
    expected += '<thead>\n'
    expected += '<tr>\n'
    expected += '<th>A</th>\n'
    expected += '<th>B</th>\n'
    expected += '<th>C</th>\n'
    expected += '<th>D</th>\n'
    expected += '</tr>\n'
    expected += '</thead>\n'
    expected += '<tbody>\n'
    expected += '<tr>\n'
    expected += '<td>1</td>\n'
    expected += '<td>11</td>\n'
    expected += '<td>111</td>\n'
    expected += '<td rowspan="3">1111</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td colspan="2" rowspan="2">2</td>\n'
    expected += '<td>22</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td>3</td>\n'
    expected += '</tr>\n'
    expected += '</tbody>\n'
    expected += '</table>\n'
    expected += '<table border="2">\n'
    expected += '<thead>\n'
    expected += '<tr>\n'
    expected += '<th>A</th>\n'
    expected += '</tr>\n'
    expected += '</thead>\n'
    expected += '<tbody>\n'
    expected += '<tr>\n'
    expected += '<td colspan="3">1</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td>2</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td>3</td>\n'
    expected += '</tr>\n'
    expected += '</tbody>\n'
    expected += '</table>\n'
    expected += '<table border="3">\n'
    expected += '<thead>\n'
    expected += '<tr>\n'
    expected += '<th>A</th>\n'
    expected += '<th>B</th>\n'
    expected += '<th>C</th>\n'
    expected += '</tr>\n'
    expected += '</thead>\n'
    expected += '<tbody>\n'
    expected += '<tr>\n'
    expected += '<td rowspan="2">1</td>\n'
    expected += '<td>11</td>\n'
    expected += '<td>111</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td rowspan="2">2</td>\n'
    expected += '<td>22</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td>3</td>\n'
    expected += '<td>33</td>\n'
    expected += '</tr>\n'
    expected += '</tbody>\n'
    expected += '</table>\n'
    expected += '<table border="4">\n'
    expected += '<thead>\n'
    expected += '<tr>\n'
    expected += '<th>A</th>\n'
    expected += '<th>B</th>\n'
    expected += '<th>C</th>\n'
    expected += '<th>D</th>\n'
    expected += '</tr>\n'
    expected += '</thead>\n'
    expected += '<tbody>\n'
    expected += '<tr>\n'
    expected += '<td colspan="2">1</td>\n'
    expected += '<td colspan="3">11</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td rowspan="2">2</td>\n'
    expected += '<td colspan="2">22</td>\n'
    expected += '<td>222</td>\n'
    expected += '</tr>\n'
    expected += '<tr>\n'
    expected += '<td>3</td>\n'
    expected += '<td colspan="2">33</td>\n'
    expected += '</tr>\n'
    expected += '</tbody>\n'
    expected += '</table>\n'
    
    expect(md.render(src)).to_be(expected)
  })

  it('should support nested lists', @{
    src =  '- item\n'
    src += '  - nested\n'
    src += '  {.red}\n'
    src += '\n'
    src += '{.blue}\n'
    expected = '<ul class="blue">\n'
    expected += '<li>item\n'
    expected += '<ul class="red">\n'
    expected += '<li>nested</li>\n'
    expected += '</ul>\n'
    expected += '</li>\n'
    expected += '</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support images', @{
    src =  '![alt](img.png){.a}'
    expected = '<p><img src="img.png" alt="alt" class="a"></p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not apply inside `code{.red}`', @{
    src =  'paragraph `code{.red}`'
    expected = '<p>paragraph <code>code{.red}</code></p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not apply inside item lists with trailing `code{.red}`', @{
    src = '- item with trailing `code = {.red}`'
    expected = '<ul>\n<li>item with trailing <code>code = {.red}</code></li>\n</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not apply inside item lists with trailing non-text, eg *{.red}*', @{
    src = '- item with trailing *{.red}*'
    expected = '<ul>\n<li>item with trailing <em>{.red}</em></li>\n</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should work with multiple inline code blocks in same paragraph', @{
    src = 'bla `click()`{.c} blah `release()`{.cpp}'
    expected = '<p>bla <code class="c">click()</code> blah <code class="cpp">release()</code></p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support {} curlies with length == 3', @{
    src = 'text {1}'
    expected = '<p 1="">text</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should do nothing with empty classname {.}', @{
    src = 'text {.}'
    expected = '<p>text {.}</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should do nothing with empty id {#}', @{
    src = 'text {#}'
    expected = '<p>text {#}</p>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support horizontal rules ---{#id}', @{
    src = '---{#id}'
    expected = '<hr id="id">\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support multiple classes for <hr>', @{
    src = '--- {.a .b}'
    expected = '<hr class="a b">\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should not crash on {#ids} in front of list items', @{
    src = '- {#ids} [link](./link)'
    expected = '<ul>\n<li>{#ids} <a href="./link">link</a></li>\n</ul>\n'
    expect(md.render(src)).to_be(expected)
  })

  it('should support empty quoted attrs', @{
    src = '![](https:#example.com/image.jpg){class="" height="100" width=""}'
    expected = '<p><img src="https:#example.com/image.jpg" alt="" class="" height="100" width=""></p>\n'
    expect(md.render(src)).to_be(expected)
  })
})
