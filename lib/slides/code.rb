class Code
  def self.highlight(code)
    formatter = Rouge::Formatters::HTML.new
    formatter = Rouge::Formatters::HTMLLinewise.new(formatter)
    formatter = Rouge::Formatters::HTMLPygments.new(formatter)

    lexer = Rouge::Lexers::Rust.new
    formatter.format(lexer.lex(code))
  end
end
