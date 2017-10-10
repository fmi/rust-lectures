class Code
  def self.highlight(code, lexer: :rust)
    Pygments.highlight(code, lexer: lexer)
  end
end
