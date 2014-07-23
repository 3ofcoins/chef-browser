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
      def show(file, extname, content)
        inside = FileContent.new(file.name, file.url, content)
        if inside.image?
          "<img src = '#{inside.path}'>"
        elsif inside.text?
          FileContent.highlight_file(inside.name, extname, inside.data)
        else
          # download
        end
      end

      def highlight_file(filename, extname, content)
        lexer = (Linguist::Language[extname.gsub(/^\./, '')] ||
                 Linguist::Language.find_by_filename(filename).first)
        if lexer.nil?
          "<pre>#{content}</pre>"
        else
          lexer.colorize(content, options: { encoding: 'utf-8', formatter: 'html', linenos: 'inline' })
        end
      end
    end
  end
end
