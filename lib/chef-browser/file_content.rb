require 'chef-browser/app'

module ChefBrowser
  class FileContent
    include Linguist::BlobHelper

    attr_accessor :name, :path, :data

    HIGHLIGHT_OPTIONS = { encoding: 'utf-8', formatter: 'html', linenos: 'inline' }
    MARKUP_FILES = %w(license contributing testing readme)

    def initialize(name, path, content)
      @name = name
      @path = path
      @data = content
    end

    class << self
      def show_file(file)
        content = FileContent.new(file.name, file.url, open(file.url).read)
        extname = File.extname(file.name).downcase
        if extname == '.md' || MARKUP_FILES.include?(file[:name].downcase)
          GitHub::Markup.render('README.md', content.data)
        else
          text_or_image(content, extname)
        end
      end

      def text_or_image(content, extname)
        if content.image?
          show_graphic_file(content)
        elsif content.text?
          show_text_file(content, extname)
        end
      end

      def show_graphic_file(content)
        path = content.path
        "<img src = '#{path}'><p></p>"
      end

      def show_text_file(content, extname)
        FileContent.highlight_file(content.name, extname, content.data)
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
