require 'chef-browser/app'

module ChefBrowser
  class FileContent
    include Linguist::BlobHelper

    attr_accessor :name, :path, :data

    @highlight_options = { encoding: 'utf-8', formatter: 'html', linenos: 'inline' }

    def initialize(name, path, content)
      @name = name
      @path = path
      @data = content
    end

    class << self
      def show_file(file, extname, content)
        markup_files = %w(license contributing testing readme)
        if extname == '.md' || markup_files.include?(file[:name].downcase)
          GitHub::Markup.render('README.md', content)
        else
          file_content = FileContent.new(file.name, file.url, content)
          if file_content.image?
            path = file_content.path
            "<img src = '#{path}'><p></p>"
          elsif file_content.text?
            FileContent.highlight_file(file_content.name, extname, file_content.data)
          end
        end
      end

      def highlight_file(filename, extname, content)
        lexer = (Linguist::Language[extname.gsub(/^\./, '')] ||
                 Linguist::Language.find_by_filename(filename).first ||
                 Linguist::Language[Linguist.interpreter_from_shebang(content)]
                )
        if lexer
          lexer.colorize(content, options: @highlight_options)
        else
          Pygments.highlight(content, lexer: 'text', options: @highlight_options)
        end
      end
    end
  end
end
