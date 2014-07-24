require 'chef-browser/app'

module ChefBrowser
  class FileContent
    include Linguist::BlobHelper

    attr_accessor :name, :path, :data

    def initialize(name, path, content)
      @name = name
      @path = path
      @data = content
    end

    class << self
      def show_file(file, extname, content)
        inside = FileContent.new(file.name, file.url, content)
        if inside.image?
          "<img src = '#{inside.path}'>"
        elsif inside.text?
          FileContent.highlight_file(inside.name, extname, inside.data)
        end
      end

      def highlight_file(filename, extname, content)
        lexer = (Linguist::Language[extname.gsub(/^\./, '')] ||
                 Linguist::Language.find_by_filename(filename).first ||
                 Linguist::Language[Linguist.interpreter_from_shebang(content)]
                )
        if lexer.nil?
          Pygments.highlight(content, lexer: 'text', options: { encoding: 'utf-8', formatter: 'html', linenos: 'inline' })
        else
          lexer.colorize(content, options: { encoding: 'utf-8', formatter: 'html', linenos: 'inline' })
        end
      end

      def download_file(url)
        "<a role='button' class='btn btn-default btn-primary' href='#{url}'>Download file</a>"
      end
    end
  end
end
