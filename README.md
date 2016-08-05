# Gaspar PDF

Parses PDF tables into HTML / Json / Xml / CSV files without losing data. This gem uses  [pdf-table-extract](https://github.com/ashima/pdf-table-extract).

![Hay PDF, Hay Tabla](https://cloud.githubusercontent.com/assets/445798/17439517/82155610-5af6-11e6-9a3e-cfb0a019b1a1.jpg)

## Installation

Add this line to your application's Gemfile:

    gem 'gaspar-pdf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gaspar-pdf

## Usage

You need to install [pdf-table-extract](https://github.com/5rabbits/pdf-table-extract/releases) on your system to use this gem.

```ruby
require 'gaspar'

# Parse document.pdf to document.html
# This requires that the pdf-table-extract command is present in your PATH.

Gaspar.parse('document.pdf', 'document.html', {
  format: 'table_html'
})

# Available options:
# page - page to parse
# format -  the type of output: [cells_csv,cells_json,cells_xml,table_csv,table_html,table_chtml,table_list]

content = Gaspar.parse_with_content('document.pdf', 'document.html', {
  format: 'table_html'
})

# you can get parsed content
```

Inspired by [Kristin](https://github.com/ricn/kristin)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
