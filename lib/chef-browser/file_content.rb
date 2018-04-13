# frozen_string_literal: true

require 'chef-browser/app'

module ChefBrowser
  class FileContent
    include Linguist::BlobHelper

    attr_accessor :name, :path, :data

    HIGHLIGHT_OPTIONS = { encoding: 'utf-8', formatter: 'html', linenos: 'inline' }.freeze
    MARKUP_FILES = %w[license contributing testing readme].freeze

    def initialize(name, path, content)
      @name = name
      @path = path
      @data = content
    end

    class << self
      def show_file(file, uri_options = {})
        content = FileContent.new(file.name, file.url, open(file.url, uri_options).read)
        extname = File.extname(file.name).downcase
        if extname == '.md' || MARKUP_FILES.include?(file[:name].downcase)
          GitHub::Markup.render('README.md', content.data)
        else
          if content.image?
            # Unfortunately, this has to be handled by file.erb
            'image'
          elsif content.text?
            FileContent.highlight_file(content.name, extname, content.data)
          end
        end
      end

      def highlight_file(filename, extname, content)
        lexer = (Linguist::Language[extname.gsub(/^\./, '')] ||
                 Linguist::Language.find_by_filename(filename).first ||
                 Linguist::Language[Linguist.interpreter_from_shebang(content)]
                )
        if lexer
          lexer.colorize(content, options: HIGHLIGHT_OPTIONS)
        else
          Pygments.highlight(content, lexer: 'text', options: HIGHLIGHT_OPTIONS)
        end
      end
    end
  end
end
